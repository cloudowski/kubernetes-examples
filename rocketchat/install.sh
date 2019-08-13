helm init


RC_HOST=chat.$(minikube ip).nip.io

helm install stable/rocketchat --name chat -f values.yaml \
    --set host=$RC_HOST

echo $RC_HOST

# fix svc
kubectl get --export -o yaml svc chat-mongodb|sed -e 's|name: chat-mongodb|name: chat-rocketchat-mongodb|'|kubectl apply -f-
