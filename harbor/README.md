# Harbor registry

```
kubectl create ns drone
kubens drone

DNSDOMAIN="$(minikube ip).nip.io"
export HARBOR=harbor.${DNSDOMAIN}

helm repo add harbor https://helm.goharbor.io

helm install --name harbor harbor/harbor --values harbor-values.yaml \
    --set expose.ingress.hosts.core=harbor.${DNSDOMAIN} \
    --set expose.ingress.hosts.notary=notary.${DNSDOMAIN} \
    --set externalURL=https://harbor.${DNSDOMAIN} 




echo "User/login: admin/Harbor12345 @ https://${HARBOR}"
```


## Import cert

Import harbor CA as trusted CA to Docker

```
curl -k https://$HARBOR/api/systeminfo/getcert | minikube ssh "sudo mkdir -p /etc/docker/certs.d/$HARBOR && sudo tee /etc/docker/certs.d/$HARBOR/ca.crt"
```

## Test

```
eval $(minikube docker-env)

docker login $HARBOR -uadmin -pHarbor12345
docker tag drone/drone:1.2 $HARBOR/library/drone
docker push $HARBOR/library/drone
```
