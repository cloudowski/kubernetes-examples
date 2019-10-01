helm repo add codecentric https://codecentric.github.io/helm-charts


DNSDOMAIN="$(minikube ip).nip.io"

# Kubernetes
helm install --values values.yaml --name keycloak \
    --set keycloak.ingress.hosts[0]=login.${DNSDOMAIN} \
    codecentric/keycloak

echo https://login.${DNSDOMAIN}

