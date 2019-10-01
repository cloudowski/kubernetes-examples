CHARTDIR=/tmp/vault-helm

git clone https://github.com/hashicorp/vault-helm $CHARTDIR


DNSDOMAIN="$(minikube ip).nip.io"

helm install --values vault-values.yaml --name vault \
    --set server.ingress.hosts[0].host=vault.${DNSDOMAIN} \
    $CHARTDIR

echo http://vault.${DNSDOMAIN}

