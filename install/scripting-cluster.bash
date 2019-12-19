# what is turned on
kubectl api-resources |grep true

# names of namespaces

kubectl get ns



# exporting objects from k8s  cluster

# for a single namespace in single yaml file 
kubectl get deploy,sts,svc,configmap,secret -n default -o yaml --export > default.yaml


# for a single namespace (here = sandbox) in multiple yaml files 

kubectl config set-context --current --namespace=sandbox

for n in $(kubectl get -o=name pvc,configmap,serviceaccount,secret,ingress,service,deployment,statefulset,hpa,job,cronjob)
do
    mkdir -p $(dirname $n)
    kubectl get -o=yaml --export $n > $n.yaml
done

### loop per every namespace except kube-system 
for ns in $(kubectl get -o=name ns |grep -v kube | sed 's/namespace\///g')
do
  mkdir -p $ns
  echo "Processing namespace $ns:"
  for n in $(kubectl get -o=name -n $ns pvc,configmap,serviceaccount,secret,ingress,service,deployment,statefulset,hpa,job,cronjob)
  do
    mkdir -p $(dirname "$ns/$n")
    kubectl get -o=yaml --export $n -n $ns > "$ns/$n.yaml"
    echo "Processing file $ns/$n.yaml:->>>"
  done
done


# next try 

kubectl config set-context --current --namespace=sandbox
 for n in $(kubectl get -o=name pvc,configmap,ingress,service,secret,deployment,statefulset,hpa,job,cronjob | grep -v 'secret/default-token'); 
do  kubectl get -o=yaml --export $n > $(dirname $n)_$(basename $n).yaml; done



