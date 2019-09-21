helm init


MINIKUBE_IP=$(minikube ip)
DOMAIN=$MINIKUBE_IP.nip.io

# cleanup
kubectl get crd|grep monitoring.coreos|awk '{print $1}'|xargs kubectl delete crd


helm install \
    stable/prometheus-operator \
    --name prom \
    --version 6.11.0 \
    -f values.yaml \
    --set alermanager.ingress.hosts[0]=am.$DOMAIN \
    --set alermanager.externalUrl=http://am.$DOMAIN \
    --set grafana.ingress.hosts[0]=grafana.$DOMAIN \
    --set prometheus.ingress.hosts[0]=prom.$DOMAIN \
    --set kubeEtcd.endpoints[0]=$MINIKUBE_IP

# adapter
helm install \
    --name promadapt \
    stable/prometheus-adapter \
    --set prometheus.url=http://prom-prometheus-operator-prometheus.default.svc

