helm repo add gitlab https://charts.gitlab.io/
helm repo update

GL_HOST=gitlab.$(minikube ip).nip.io

#helm install stable/rocketchat --name chat -f values.yaml \
helm install --name gitlab gitlab gitlab/gitlab -f gitlab-values.yaml \
  --timeout 600 \
    --set global.hosts.domain=$GL_HOST \
    --set global.edition=ce 

echo $GL_HOST


kubectl get secret gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo
