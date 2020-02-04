#### Imagine that you have simple two nodes cluster
```console
kubectl get nodes
```
<pre>
NAME                       STATUS   ROLES   AGE   VERSION
aks-nodepool1-16191604-0   Ready    agent   32d   v1.14.5
aks-nodepool1-16191604-1   Ready    agent   32d   v1.14.5
</pre>


Let's  apply our deployment.


At the beginning create new namespace for failure tests.

```console
kubectl create namespace failure
```

<pre>
namespace/failure created
</pre>

```console
kubectl apply -f my-failure-app-deployment.yaml -n failure
```

<pre>
deployment.apps/my-failure-app created
</pre>

```console
kubectl get all -n failure
```

<pre>
NAME                                  READY   STATUS    RESTARTS   AGE
pod/my-failure-app-5b784b5746-2nsmd   1/1     Running   0          2m1s
pod/my-failure-app-5b784b5746-sm2qm   1/1     Running   0          2m1s

NAME                             READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/my-failure-app   2/2     2            2           2m1s

NAME                                        DESIRED   CURRENT   READY   AGE
replicaset.apps/my-failure-app-5b784b5746   2         2         2       2m1s
</pre>

Now we would like to know on what nodes are deployed our pods

Let's try with filtering our pods in dedicated failure namespace

```console
kubectl get pods -l app=my-failure-app -n failure
```
<pre>
NAME                              READY   STATUS    RESTARTS   AGE
my-failure-app-5b784b5746-2nsmd   1/1     Running   0          3m25s
my-failure-app-5b784b5746-sm2qm   1/1     Running   0          3m25s
</pre>

```console
kubectl get pods -l app=my-failure-app -n failure -o wide
```
<pre>
NAME                              READY   STATUS    RESTARTS   AGE     IP            NODE                       NOMINATED NODE   READINESS GATES
my-failure-app-5b784b5746-2nsmd   1/1     Running   0          5m33s   10.244.1.52   aks-nodepool1-16191604-0   <none>
        <none>
my-failure-app-5b784b5746-sm2qm   1/1     Running   0          5m33s   10.244.1.51   aks-nodepool1-16191604-0   <none>
        <none>
</pre>

Here I have both pods on the same node. Let's shutdown the node-0.
Stop the corresponding VM aks-nodepool1-16191604-0.
<pre>
Stopping virtual machine 'aks-nodepool1-16191604-0'...
...

</pre>

After few minutes

```console
kubectl get nodes
```

<pre>
NAME                       STATUS     ROLES   AGE   VERSION
aks-nodepool1-16191604-0   NotReady   agent   32d   v1.14.5
aks-nodepool1-16191604-1   Ready      agent   32d   v1.14.5
</pre>

```console
kubectl get pods -l app=my-failure-app -n failure -o wide
```

<pre>
NAME                              READY   STATUS    RESTARTS   AGE   IP            NODE                       NOMINATED NODE   READINESS GATES
my-failure-app-5b784b5746-2nsmd   1/1     Running   0          14m   10.244.1.52   aks-nodepool1-16191604-0   <none>           <none>
my-failure-app-5b784b5746-sm2qm   1/1     Running   0          14m   10.244.1.51   aks-nodepool1-16191604-0   <none>           <none>
</pre>

Kubernetes still doesnt know that pods node aks-nodepool1-16191604-0 are out of service

After few minutes
<pre>
NAME                              READY   STATUS        RESTARTS   AGE   IP            NODE                       NOMINATED NODE   READINESS GATES
my-failure-app-5b784b5746-2nsmd   1/1     Terminating   0          17m   10.244.1.52   aks-nodepool1-16191604-0   <none>           <none>
my-failure-app-5b784b5746-7jrdw   1/1     Running       0          46s   10.244.0.53   aks-nodepool1-16191604-1   <none>           <none>
my-failure-app-5b784b5746-sm2qm   1/1     Terminating   0          17m   10.244.1.51   aks-nodepool1-16191604-0   <none>           <none>
my-failure-app-5b784b5746-twc45   1/1     Running       0          46s   10.244.0.52   aks-nodepool1-16191604-1   <none>           <none>
</pre>

Look at new running pods on ks-nodepool1-16191604-1 node.

The old instances on node aks-nodepool1-16191604-0 are  terminating .... terminating ... forever. Why ?


Now turn on aks-nodepool1-16191604-0 VM.
<pre>
Starting virtual machine 'aks-nodepool1-16191604-0'...
</pre>

```console
kubectl get nodes
```

<pre>
NAME                       STATUS   ROLES   AGE   VERSION
aks-nodepool1-16191604-0   Ready    agent   32d   v1.14.5
aks-nodepool1-16191604-1   Ready    agent   32d   v1.14.5
</pre>

```console
kubectl get pods -l app=my-failure-app -n failure -o wide
```

<pre>
NAME                              READY   STATUS    RESTARTS   AGE     IP            NODE                       NOMINATED NODE   READINESS GATES
my-failure-app-5b784b5746-7jrdw   1/1     Running   0          7m37s   10.244.0.53   aks-nodepool1-16191604-1   <none>           <none>
my-failure-app-5b784b5746-twc45   1/1     Running   0          7m37s   10.244.0.52   aks-nodepool1-16191604-1   <none>           <none>
</pre>

Our terminating pods are missing, Why ?

Literature:
https://medium.com/google-cloud/fine-tuning-a-kubernetes-cluster-187d79370fd9

https://fatalfailure.wordpress.com/2016/06/10/improving-kubernetes-reliability-quicker-detection-of-a-node-down/




Create cluster with tree nodes

```console
kubectl get nodes 
```
<pre>
NAME                       STATUS   ROLES   AGE     VERSION
aks-nodepool1-36820653-0   Ready    agent   6d23h   v1.17.0
aks-nodepool1-36820653-1   Ready    agent   6d23h   v1.17.0
aks-nodepool1-36820653-2   Ready    agent   9m18s   v1.17.0
</pre>

```console
kubectl top nodes
```
<pre>
aks-nodepool1-36820653-0   207m         10%    1149Mi          53%       
aks-nodepool1-36820653-1   105m         5%     918Mi           42%
aks-nodepool1-36820653-2   88m          4%     893Mi           41%
</pre>

```
kubectl get nodes -o json |jq ".items[] | {name:.metadata.name} + .status.capacity"
```
```json
{
  "name": "aks-nodepool1-36820653-0",
  "attachable-volumes-azure-disk": "4",
  "cpu": "2",
  "ephemeral-storage": "101445900Ki",
  "hugepages-1Gi": "0",
  "hugepages-2Mi": "0",
  "memory": "4017572Ki",
  "pods": "30"
}
{
  "name": "aks-nodepool1-36820653-1",
  "attachable-volumes-azure-disk": "4",
  "cpu": "2",
  "ephemeral-storage": "101445900Ki",
  "hugepages-1Gi": "0",
  "hugepages-2Mi": "0",
  "memory": "4017572Ki",
  "pods": "30"
}
{
  "name": "aks-nodepool1-36820653-2",
  "attachable-volumes-azure-disk": "4",
  "cpu": "2",
  "ephemeral-storage": "101445900Ki",
  "hugepages-1Gi": "0",
  "hugepages-2Mi": "0",
  "memory": "4017260Ki",
  "pods": "30"
}
```

```console
kubectl top pods --all-namespaces
```
<pre>
NAMESPACE     NAME                                                  CPU(cores)   MEMORY(bytes)   
kube-system   calico-node-52rdb                                     19m          18Mi
kube-system   calico-node-lzpvf                                     17m          48Mi
kube-system   calico-node-tnjzz                                     17m          44Mi
kube-system   calico-typha-7d6f9f5d9d-trtrp                         4m           19Mi
kube-system   calico-typha-horizontal-autoscaler-6fd8df4754-9j2kk   1m           7Mi
kube-system   coredns-6c9b65c6cd-fwtlw                              3m           10Mi
kube-system   coredns-autoscaler-546d886ffc-8m5rn                   1m           7Mi
kube-system   dashboard-metrics-scraper-867cf6588-wkwhl             1m           9Mi
kube-system   kube-proxy-7dhkv                                      1m           16Mi
kube-system   kube-proxy-jhg25                                      1m           15Mi
kube-system   kube-proxy-km8hl                                      1m           16Mi
kube-system   kubernetes-dashboard-7f7676f7b5-m2n25                 1m           13Mi
kube-system   metrics-server-75b8b88d6b-pxpv8                       1m           12Mi
kube-system   omsagent-58fcb                                        4m           82Mi
kube-system   omsagent-gvddg                                        7m           76Mi
kube-system   omsagent-rs-59565d87d7-smbvd                          6m           81Mi
kube-system   omsagent-zsr7d                                        6m           78Mi
kube-system   tunnelfront-588bf4cb9d-sgp7f                          82m          8Mi
</pre>


Create namespace failure

```
kubectl create ns failure
```
<pre>
namespace/failure created
</pre>
```
kubectl config set-context --current --namespace=failure
```
<pre>
Context "***" modified.
</pre>

set limit on namespace

Create ResourceQuota
```console
kubectl apply -f quotas.yaml
```
<pre>
resourcequota/compute-resources created
</pre>

```
kubectl describe resourcequota
```
<pre>
Name:                    compute-resources
Namespace:               failure
Resource                 Used   Hard      
--------                 ----   ----      
limits.cpu               400m   4
limits.memory            200Mi  4Gi       
pods                     2      40        
requests.cpu             100m   2
requests.memory          100Mi  2Gi       
requests.nvidia.com/gpu  0      0
</pre>
```
kubectl apply -f limit-mem-cpu-container.yaml
```
<pre> 
limitrange/limit-mem-cpu-per-container created
</pre>
```console
kubectl describe ns failure
```
<pre>
Name:         failure
Labels:       <none>
Annotations:  <none>
Status:       Active

Resource Quotas
 Name:                    compute-resources
 Resource                 Used    Hard
 --------                 ---     ---
 limits.cpu               2400m   4
 limits.memory            1200Mi  4Gi
 pods                     22      40
 requests.cpu             1100m   2
 requests.memory          500Mi   2Gi
 requests.nvidia.com/gpu  0       0

Resource Limits
 Type       Resource  Min   Max    Default Request  Default Limit  Max Limit/Request Ratio
 ----       --------  ---   ---    ---------------  -------------  -----------------------
 Container  cpu       50m   200m   50m              100m           -
 Container  memory    50Mi  200Gi  50Mi             100Mi          -
</pre>




Install  kube-ops-view 

```console
kubectl apply -f kube-web-view -n failure
```
<pre>
serviceaccount/kube-ops-view created
clusterrole.rbac.authorization.k8s.io/kube-ops-view created
clusterrolebinding.rbac.authorization.k8s.io/kube-ops-view created
deployment.apps/kube-ops-view created
deployment.apps/kube-ops-view-redis created
service/kube-ops-view-redis created
service/kube-ops-view created
</pre>

kubectl port-forward svc/kube-ops-view 8080:80
Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080

Browse at:


http://localhost:8080



Let deploy two applications




Wordsmith (three different pods) and Php-hello (one dirrefent pod)





kubectl apply -f php-hello-deployment.yaml



