
## Running your first Kubernetes cluster on Azure. Deploying first application.


### create resource group 
```console
az group create --name myAKSCluster --location northeurope
```

### create first k8s cluster  with one node
```console
az aks create --resource-group myAKSCluster --name myAKSCluster --node-count 1 --enable-addons monitoring --generate-ssh-keys
```

### installing kubectl  , only for first time
```console
az aks install-cli
```
### getting credentials from k8s server
```console
az aks get-credentials --resource-group myAKSCluster --name myAKSCluster
```

### checking context
```console
kubectl config current-context
```
##### myAKSCluster

### see all nodes
```console
kubectl get nodes
```

##### NAME                       STATUS   ROLES   AGE   VERSION
##### aks-nodepool1-27090461-0   Ready    agent   15m   v1.9.11


### opening dashboard
```console
az aks browse --resource-group myAKSCluster --name myAKSCluster
```

#### In case of troubles with seeing objects from dashboard
```console
kubectl create -f https://raw.githubusercontent.com/djkormo/ContainersSamples/master/Kubernetes/AKS/kube-dashboard-access.yaml
```


### running  first sample app
```console
kubectl apply -f https://raw.githubusercontent.com/Azure-Samples/azure-voting-app-redis/master/azure-vote-all-in-one-redis.yaml
```
##### deployment.apps/azure-vote-back created
##### service/azure-vote-back created
##### deployment.apps/azure-vote-front created
##### service/azure-vote-front created

### see all pods
```console
kubectl get pods
```
##### NAME                                READY   STATUS              RESTARTS   AGE
##### azure-vote-back-655476c7f7-hbg86    1/1     Running             0          2m49s
##### azure-vote-front-764cff8457-74v7g   0/1     ContainerCreating   0          2m49s


### see all deployments
```console
kubectl get deployments
```
##### NAME               DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
##### azure-vote-back    1         1         1            1           3m59s
##### azure-vote-front   1         1         1            0           3m59s


### see all services 
```console
kubectl get services 
```

##### NAME               TYPE           CLUSTER-IP     EXTERNAL-IP       PORT(S)        AGE
##### azure-vote-back    ClusterIP      10.0.79.19     <none>            6379/TCP       3m16s
##### azure-vote-front   LoadBalancer   10.0.124.211   137.116.230.107   80:30102/TCP   3m15s
##### kubernetes         ClusterIP      10.0.0.1       <none>            443/TCP        18m


### Show service details for  frontend
```console
kubectl describe services azure-vote-front
```

##### Name:                     azure-vote-front
##### Namespace:                default
##### Labels:                   <none>
##### Annotations:              kubectl.kubernetes.io/last-applied-configuration:
#####                            {"apiVersion":"v1","kind":"Service","metadata":{"annotations":{},"name":"azure-vote-front","namespace":"default"},"spec":{"ports":[{
##### "port"...
##### Selector:                 app=azure-vote-front
##### Type:                     LoadBalancer
##### IP:                       10.0.124.211
##### LoadBalancer Ingress:     137.116.230.107
##### Port:                     <unset>  80/TCP
##### TargetPort:               80/TCP
##### NodePort:                 <unset>  30102/TCP
##### Endpoints:                10.244.0.10:80
##### Session Affinity:         None
##### External Traffic Policy:  Cluster
##### Events:
#####  Type    Reason                Age   From                Message
#####  ----    ------                ----  ----                -------
#####  Normal  EnsuringLoadBalancer  20m   service-controller  Ensuring load balancer
#####
#####  Normal  EnsuredLoadBalancer   19m   service-controller  Ensured load balancer
  
  
### Run your application at 137.116.230.107
  
http://137.116.230.107:80



