cmd=${1:-start}

cd /tmp/istio-1.3.4

if [ $cmd = "start" ];then
    kubectl label namespace default istio-injection=enabled
    kubectl apply -f \
        samples/bookinfo/platform/kube/bookinfo.yaml\
,samples/bookinfo/networking/destination-rule-all.yaml\
,samples/bookinfo/networking/bookinfo-gateway.yaml

elif [ $cmd = "stop" ];then
    kubectl label namespace default istio-injection-
    kubectl delete -f \
        samples/bookinfo/platform/kube/bookinfo.yaml\
,samples/bookinfo/networking/destination-rule-all.yaml\
,samples/bookinfo/networking/bookinfo-gateway.yaml

fi



