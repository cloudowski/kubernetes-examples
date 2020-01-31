

# create a db instance
helm install --name mydb \
  --set postgresqlPassword=secretpassword,postgresqlDatabase=mydatabase \
  --set service.type=NodePort,service.nodePort=32543 \
    stable/postgresql

vault secrets enable database

# configure db connection - static password
vault write database/config/postgresql \
        plugin_name=postgresql-database-plugin \
        allowed_roles=readonly \
        connection_url=postgresql://postgres:secretpassword@$(minikube ip):32543/postgres?sslmode=disable

# configure db connection with password rotatin
vault write database/config/postgresql \
        plugin_name=postgresql-database-plugin \
        allowed_roles='*' \
        connection_url="postgresql://{{username}}:{{password}}@$(minikube ip):32543/postgres?sslmode=disable" \
        username=postgres password=secretpassword

# TODO verify

# rotate root (postgres) password
vault write -force database/rotate-root/postgresql

# create a role

cat << EOF > /tmp/vault-postgres.sql
CREATE ROLE "{{name}}" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';
GRANT SELECT ON ALL TABLES IN SCHEMA public TO "{{name}}";
EOF


vault write database/roles/readonly db_name=postgresql \
        creation_statements=@/tmp/vault-postgres.sql \
        default_ttl=30s max_ttl=60s


cat << EOF > /tmp/postgres-policy.hcl
path "database/creds/readonly" {
  capabilities = [ "read" ]
}
EOF

vault policy write dbapps /tmp/postgres-policy.hcl

# allow access from all namespaces with 'app' sa only - add dbapps policy
vault write auth/kubernetes/role/myapp \
   bound_service_account_names=app \
   bound_service_account_namespaces='*' \
   policies=app,dbapps \
   ttl=1h

# enable auditing to stdout - makes it easier to observer dynamic creds generation and renewal
vault audit enable file file_path=stdout prefix='AUDIT: '

# test
## get token with app policy

APP_TOKEN=$(vault token create -policy="dbapps" -field=token)

VAULT_TOKEN="$APP_TOKEN" vault read database/creds/readonly


# add app

kubectl apply -f krazy-cow.yaml
kubectl patch deployment krazy-cow --patch "$(cat krazy-cow-patch3.yaml)"

# list all leases
curl -s -H "X-Vault-Token: $VAULT_TOKEN" --request LIST http://vault.$(minikube ip).nip.io/v1/sys/leases/lookup/database/creds/readonly|jq '.data.keys'

## STATIC passwords


cat << EOF > /tmp/vault-static-postgres.sql
ALTER USER "{{name}}" WITH PASSWORD '{{password}}';
EOF

vault write database/static-roles/myapps \
        db_name=postgresql \
        rotation_statements=@/tmp/vault-static-postgres.sql \
        username="vault-myapps" \
        rotation_period=86400
