# Drone with Gogs on Minikube

* Create dedicated namespace

```
kubectl create ns drone
kubens drone

DNSDOMAIN="$(minikube ip).nip.io"
```

* Install gogs

```
helm install --name gogs incubator/gogs --values gogs-values.yaml \
    --set service.gogs.serverDomain=git.${DNSDOMAIN} \
    --set service.gogs.serverRootUrl=http://git.${DNSDOMAIN} \
    --set service.ingress.hosts[0]=git.${DNSDOMAIN} 
```

#export NODE_PORT=$(kubectl get --namespace drone -o jsonpath="{.spec.ports[0].nodePort}" services gogs-gogs)
#GOGS_URL="http://$(minikube ip):$NODE_PORT/"

* Install drone 

```
GOGS_URL="http://git.${DNSDOMAIN}"
echo $GOGS_URL
helm install --name drone stable/drone --values drone-values.yaml \
    --set server.host=drone.${DNSDOMAIN} \
    --set ingress.hosts[0]=drone.${DNSDOMAIN} \
    --set sourceControl.provider=gogs \
    --set sourceControl.gogs.server=${GOGS_URL}
```

* Create gogs `root` user

```
GOGS_POD=$(kubectl get pod -lapp=gogs-gogs --no-headers|awk '{print $1}')
kubectl exec   -ti $GOGS_POD -- env USER=git ./gogs admin create-user --name root --password root --email root@example.com --admin
```

* Add secrets

```
drone secret add --name registry_user --data admin root/krazy-cow
drone secret add --name registry_pass --data Harbor12345 root/krazy-cow
drone secret ls
drone secret add --name registry --data harbor.$DNSDOMAIN root/krazy-cow
drone secret add --name repo --data library/krazy-cow root/krazy-cow
```
