# DISCLAIMER - based on https://www.hashicorp.com/blog/injecting-vault-secrets-into-kubernetes-pods-via-a-sidecar

## Kubernetes part - configure from pod
## i.e.
### kubectl exec -ti vault-0 sh

## also
## export VAULT_TOKEN=<ROOT_TOKEN>

cat <<EOF > /home/vault/app-policy.hcl
path "secret*" {
  capabilities = ["read"]
}
EOF

vault policy write app /home/vault/app-policy.hcl


vault auth enable kubernetes

vault write auth/kubernetes/config \
   token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
   kubernetes_host=https://${KUBERNETES_PORT_443_TCP_ADDR}:443 \
   kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt


# allow access from all namespaces with 'app' sa only
vault write auth/kubernetes/role/myapp \
   bound_service_account_names=app \
   bound_service_account_namespaces='*' \
   policies=app \
   ttl=1h

# not enabled by default?
vault secrets enable -path=secret kv

#$ create secret

vault kv put secret/helloworld username=foobaruser password=foobarbazpass


## Application part

kubectl apply -f krazy-cow.yaml


## WAIT and verify - no

kubectl iexec krazy-cow -- ls -l /vault/secrets


## patch deployment - add annotations

kubectl patch deployment krazy-cow --patch "$(cat krazy-cow-patch.yaml)"

## verify - a sidecar contner has been added to the app pod

## list content of secrets 
kubectl iexec krazy-cow -- ls -l /vault/secrets
kubectl iexec krazy-cow -- cat /vault/secrets/helloworld

## change template - use 'user:pass' template
kubectl patch deployment krazy-cow --patch "$(cat krazy-cow-patch2.yaml)"
