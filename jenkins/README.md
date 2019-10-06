# Jenkins with Gitea

```
helm init

sleep 20

kubectl create ns jenkins

kubectl apply -f casc/ -n jenkins

JENKINS_HOST=jenkins.$(minikube ip).nip.io

helm install --namespace jenkins -n jenkins stable/jenkins -f jenkins-values.yaml \
    --set master.ingress.hostName=$JENKINS_HOST --version 1.6.0


sleep 20

# add deployer

kubectl create sa deployer -n jenkins
kubectl create rolebinding jenkins-deployer-edit --clusterrole=edit --serviceaccount=jenkins:deployer -n jenkins
kubectl create clusterrolebinding jenkins-deployer-admin --clusterrole=cluster-admin --serviceaccount=jenkins:deployer

kubectl create secret generic jenkins-docker-creds  --from-file=.dockerconfigjson=/Users/tomasz/.docker/config.json.plain  --type=kubernetes.io/dockerconfigjson -n jenkins

echo http://$JENKINS_HOST
```
