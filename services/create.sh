kubectl create ns tns1
kubens tns1
kubectl create deployment nginx --image=nginx
kubectl expose deploy nginx --port=80 --target-port=80
kubectl create svc externalname extname --external-name cloudowski.com

kubectl create service clusterip headless --clusterip="None"

kubectl create ns tns2
kubectl create deployment nginx --image=nginx -n tns2
kubectl expose deploy nginx --port=80 --target-port=80 -n tns2
kubectl create service clusterip nginx-tns2 --clusterip="None" -n tns1

cat << EOF |kubectl apply -f-

kind: "Endpoints"
apiVersion: "v1"
metadata:
    name: "nginx-tns2"
subsets:
- addresses:
    - ip: "100.71.52.55"  # ClusterIP of the ngninx service in tns namespace
  ports:
    - port: 80
      name: "nginx"
EOF
