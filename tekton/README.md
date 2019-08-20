# Install tekton

```
kubectl apply --filename https://storage.googleapis.com/tekton-releases/latest/release.yaml
```

# s2i java

```
kubectl apply -f https://raw.githubusercontent.com/openshift/pipelines-catalog/master/s2i-java-11/s2i-java-11-task.yaml
kubectl apply -f https://raw.githubusercontent.com/openshift/pipelines-catalog/master/s2i-java-8/s2i-java-8-task.yaml

kubectl create secret generic docker-creds \
 --from-file=.dockerconfigjson=/Users/tomasz/.docker/config.json.plain \
 --type=kubernetes.io/dockerconfigjson

cat << EOF | kubectl apply -f-
apiVersion: v1
kind: ServiceAccount
metadata:
  name: s2i-pipeline
secrets:
  - name: docker-creds
EOF

kubectl create rolebinding tekton-s2i --serviceaccount=default:s2i-pipeline --clusterrole=edit

kubectl apply -f s2i-java/petclinic-s2i-java8-taskrun.yaml
tkn taskrun logs -f s2i-java8-taskrun
```

# Dashboard

```
kubectl apply --filename https://github.com/tektoncd/dashboard/releases/download/v0.1.0/release.yaml
```
