CHARTDIR=/tmp/vault-helm

git clone https://github.com/hashicorp/vault-helm $CHARTDIR


DNSDOMAIN="$(minikube ip).nip.io"

helm install --values vault-values.yaml --name vault \
    --set server.ingress.hosts[0].host=vault.${DNSDOMAIN} \
    $CHARTDIR

echo http://vault.${DNSDOMAIN}


cat << EOF
====================

To start using you need to initialize vault instance first - execute the following commands from vault-0 pod

vault operator init

DON'T FORGET to Write down somewhere the generated root token!

Use 3 of 5 generated unseal keys to unseal the vault:

vault operator unseal
vault operator unseal
vault operator unseal

Then from your workstation set the following vairables to operate vault:

export VAULT_ADDR=http://vault.${DNSDOMAIN}
export VAULT_TOKEN=<ROOT_TOKEN_GENERATED_DURING_INIT>

EOF
