# Drone with Gitea on Minikube

* Create dedicated namespace

```
kubectl create ns drone
kubens drone

DNSDOMAIN="$(minikube ip).nip.io"
```

* Install gitea

```
CHARTDIR=/tmp/gitea-helm-chart
git clone https://github.com/jfelten/gitea-helm-chart $CHARTDIR

# fix database path
sed -i "" -e 's|= data/gitea.db|= /data/gitea.db|' $CHARTDIR/templates/gitea/gitea-config.yaml

helm install --values gitea-values.yaml --name gitea \
    --set service.http.externalHost=gitea.${DNSDOMAIN} \
    $CHARTDIR

```
* Install drone 

```
GIT_URL="http://gitea.${DNSDOMAIN}"
echo $GIT_URL
helm install --name drone stable/drone --values drone-values.yaml \
    --set server.host=drone.${DNSDOMAIN} \
    --set ingress.hosts[0]=drone.${DNSDOMAIN} \
    --set sourceControl.provider=gitea \
    --set sourceControl.gitea.server=${GIT_URL}
```

* Create gogs `root` user

```
GITEA_POD=$(kubectl get pod -lapp=gitea-gitea --no-headers|awk '{print $1}')
kubectl exec   -ti $GITEA_POD -- su git -c '/app/gitea/gitea admin create-user --username root --password root --email root@example.com --admin'
```

* Add secrets

```
drone secret add --allow-pull-request --name registry_user --data admin root/krazy-cow
drone secret add --allow-pull-request --name registry_pass --data Harbor12345 root/krazy-cow
drone secret add --allow-pull-request --name registry --data harbor.$DNSDOMAIN root/krazy-cow
drone secret add --allow-pull-request --name repo --data library/krazy-cow root/krazy-cow
# kubeconfig
drone secret add --allow-pull-request --name kubeconfig --data @/tmp/kube root/krazy-cow
```

