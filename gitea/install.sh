CHARTDIR=/tmp/gitea-helm-chart

git clone https://github.com/jfelten/gitea-helm-chart $CHARTDIR


DNSDOMAIN="$(minikube ip).nip.io"

# fix database path
sed -i "" -e 's|= data/gitea.db|= /data/gitea.db|' $CHARTDIR/templates/gitea/gitea-config.yaml

# Kubernetes
helm install --values gitea-values.yaml --name gitea \
    --set service.http.externalHost=gitea.${DNSDOMAIN} \
    $CHARTDIR

# OpenShift version
oc adm policy add-scc-to-user anyuid -z default
helm template --values gitea-values.yaml --name gitea \
    --set service.http.externalHost=gitea.${DNSDOMAIN} \
    $CHARTDIR | oc apply -f-

echo http://gitea.${DNSDOMAIN}

GITEA_POD=$(kubectl get pod -lapp=gitea-gitea --no-headers|awk '{print $1}')
kubectl exec -ti $GITEA_POD -- su git -c '/app/gitea/gitea admin create-user --username root --password root --email root@example.com --admin'

# Set webhook in repo for jenkins to http://JENKINS_URL/gitea-webhook/post
