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
sleep 20
oc rsh deploy/gitea-gitea chmod 777 /data

echo http://gitea.${DNSDOMAIN}

# create a user

GITEA_POD=$(kubectl get pod -lapp=gitea-gitea --no-headers|awk '{print $1}')
kubectl exec -ti $GITEA_POD -- su git -c '/app/gitea/gitea admin create-user --username root --password root --email root@example.com --admin'

# create a repo - curl version
curl -H "Content-Type: application/json" -X POST -d '{"name": "testrepo"}' --url http://root:root@gitea.${DNSDOMAIN}/api/v1/user/repos
curl -H "Content-Type: application/json" -X POST -d '{"username": "myorg"}' --url http://root:root@gitea.${DNSDOMAIN}/api/v1/orgs

# create a repo - HTTPie
http -a root:root POST http://root:root@gitea.${DNSDOMAIN}/api/v1/user/repos name=testrepo
http -a root:root POST http://root:root@gitea.${DNSDOMAIN}/api/v1/orgs username=testorg

# Set webhook in repo for jenkins to http://JENKINS_URL/gitea-webhook/post
