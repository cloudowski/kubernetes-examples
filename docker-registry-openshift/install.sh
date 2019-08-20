# path to clone repo with official helm charts
CHARTDIR=//Users/tomasz/projects/lvo/charts

#DNSDOMAIN="$(minikube ip).nip.io"
DNSDOMAIN="$(minishift ip).nip.io"

helm template -f values.yaml --name reg \
    --set ingress.hosts[0]=reg.${DNSDOMAIN} \
    $CHARTDIR/stable/docker-registry|oc apply -f-

echo http://reg.${DNSDOMAIN}
echo "User/pass for auth: admin/admin"


# allow anyuid scc policy
oc adm policy add-scc-to-user anyuid -z default

# create docker registry secret
oc create secret docker-registry dockreg --docker-server=reg.$(minishift ip).nip.io:80 --docker-username=admin --docker-password=admin --docker-email=admin@example.com

# link builder - optional?
#oc secrets link builder dockreg

#minishift config set insecure-registry reg.192.168.99.167.nip.io:80

# PHP app sample

oc new-app --name phpapp https://github.com/openshift/django-ex

# change type, output AND pushsecret
oc patch bc phpapp -p '{"spec": { "output": {"pushSecret": {"name": "dockreg"}, "to": {"kind": "DockerImage", "name": "reg.192.168.99.173.nip.io:80/phpapp"}}}}'
