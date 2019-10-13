## Kubernetes at War on Azure


### First, let's create simple AKS cluster with tree nodes

bash ./deploy_AKS_to_Azure.bash

### It takes about  15-20 minutes to start 


```console
kubectl get nodes
```
<pre>
NAME                       STATUS   ROLES   AGE    VERSION
aks-nodepool1-16191604-0   Ready    agent   115s   v1.15.3
aks-nodepool1-16191604-1   Ready    agent   117s   v1.15.3
aks-nodepool1-16191604-2   Ready    agent   2m6s   v1.15.3
</pre>


### Display all namespaces

```console
kubectl get namespaces # or ns 
```

<pre>
NAME              STATUS   AGE
default           Active   12m
kube-node-lease   Active   12m
kube-public       Active   12m
kube-system       Active   12m
</pre>

#### What are the limits of our nodes 


```console
kubectl describe  node aks-nodepool1-16191604-2 |grep Capacity -A15
```
<pre>
Capacity:
 attachable-volumes-azure-disk:  4
 cpu:                            2
 ephemeral-storage:              101584140Ki
 hugepages-1Gi:                  0
 hugepages-2Mi:                  0
 memory:                         4017084Ki
 pods:                           110
Allocatable:
 attachable-volumes-azure-disk:  4
 cpu:                            1900m
 ephemeral-storage:              93619943269
 hugepages-1Gi:                  0
 hugepages-2Mi:                  0
 memory:                         2200508Ki
 pods:                           110
</pre>


```console bash

alias util='kubectl get nodes | grep node | awk '\''{print $1}'\'' | xargs -I {} sh -c '\''echo   {} ; kubectl describe node {} | grep Allocated -A 5 | grep -ve Event -ve Allocated -ve percent -ve -- ; echo '\'''

# Note: 2000m cores is the total cores in one node
alias cpualloc="util | grep % | awk '{print \$1}' | awk '{ sum += \$1 } END { if (NR > 0) { result=(sum**2000); printf result/NR \"%\n\" } }'"

# Note: 2000MB is the total cores in one node
alias memalloc='util | grep % | awk '\''{print $3}'\'' | awk '\''{ sum += $1 } END { if (NR > 0) { result=(sum*100)/(NR*2000); printf result/NR "%\n" } }'\'''


util
cpualloc
memalloc

```

<pre>
$ util
aks-nodepool1-16191604-0
  Resource                       Requests     Limits
  cpu                            175m (9%)    150m (7%)
  memory                         225Mi (10%)  600Mi (27%)

aks-nodepool1-16191604-1
  Resource                       Requests     Limits
  cpu                            275m (14%)   150m (7%)
  memory                         295Mi (13%)  770Mi (35%)

aks-nodepool1-16191604-2
  Resource                       Requests     Limits
  cpu                            515m (27%)   400m (21%)
  memory                         669Mi (31%)  1770Mi (82%)

$ cpualloc
0%

$ memalloc
0%
</pre>


### let's create new namespace for our experiments

```console
kubectl create ns failure
```
<pre>
namespace/failure created
</pre>


```console
kubectl get ns
```
<pre>
default           Active   23m
failure           Active   8s
kube-node-lease   Active   23m
kube-public       Active   23m
kube-system       Active   23m
</pre>

```console
kubectl describe ns failure
```
<pre>
$ kubectl describe ns failure
Name:         failure
Labels:       <none>
Annotations:  <none>
Status:       Active

No resource quota.

No resource limits.
</pre>


### Create Resource quota per namespace

```yaml
cat <<EOF > quotas.yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-resources
spec:
  hard:
    pods: "20"
    requests.cpu: "1"
    requests.memory: 1Gi
    limits.cpu: "2"
    limits.memory: 2Gi
    requests.nvidia.com/gpu: 3
EOF
```

```console
kubectl apply -f ./quotas.yaml --namespace=failure
```
<pre>
resourcequota/compute-resources created
</pre>


### Let's switch to failure namespace as our new default namespace


###### Get current context
```console
kubectl config current-context
```
<pre>
aks-simple20191023
</pre>

##### Change to dedicated namespace
```console
kubectl config set-context --current --namespace=failure
```
<pre>
Context "aks-simple20191023" modified.
</pre>

### Let's try to see information about quotas in failure namespace
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
 Resource                 Used  Hard
 --------                 ---   ---
 limits.cpu               0     2
 limits.memory            0     2Gi
 pods                     0     20
 requests.cpu             0     1
 requests.memory          0     1Gi
 requests.nvidia.com/gpu  0     3

No resource limits.
</pre>


### Creating limit ranges for containers in namespace

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: limit-mem-cpu-per-container
spec:
  limits:
  - max:
      cpu: "800m"
      memory: "1Gi"
    min:
      cpu: "50m"
      memory: "50Mi"
    default:
      cpu: "200m"
      memory: "200Mi"
    defaultRequest:
      cpu: "100m"
      memory: "100Mi"
    type: Container
```

#### Applying default limits and requests per container in our namespace
```console
 kubectl apply -f ./limit-mem-cpu-container.yaml --namespace=failure
```
<pre>
limitrange/limit-mem-cpu-per-container created
</pre>

```console
kubectl describe limitrange --namespace=failure
```
<pre>
Name:       limit-mem-cpu-per-container
Namespace:  failure
Type        Resource  Min   Max   Default Request  Default Limit  Max Limit/Request Ratio
----        --------  ---   ---   ---------------  -------------  -----------------------
Container   cpu       50m   800m  100m             200m           -
Container   memory    50Mi  1Gi   100Mi            200Mi          -
</pre>


```console
kubectl describe namespace failure |grep "Resource Quotas" -A9
```

<pre>
Resource Quotas
 Name:                    compute-resources
 Resource                 Used  Hard
 --------                 ---   ---
 limits.cpu               0     2
 limits.memory            0     2Gi
 pods                     0     20
 requests.cpu             0     1
 requests.memory          0     1Gi
 requests.nvidia.com/gpu  0     3
</pre>


### Once again let's see the information about our namespace
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
 Resource                 Used  Hard
 --------                 ---   ---
 limits.cpu               0     2
 limits.memory            0     2Gi
 pods                     0     20
 requests.cpu             0     1
 requests.memory          0     1Gi
 requests.nvidia.com/gpu  0     3

Resource Limits
 Type       Resource  Min   Max   Default Request  Default Limit  Max Limit/Request Ratio
 ----       --------  ---   ---   ---------------  -------------  -----------------------
 Container  memory    50Mi  1Gi   100Mi            200Mi          -
 Container  cpu       50m   800m  100m             200m           -
</pre>

------------------------------------------------------------------
## Here we have our environment ready to make some experiments.
------------------------------------------------------------------


### Lets' create simple  deployment
```console
kubectl run nginx --image=nginx:latest --replicas=4
```
<pre>
kubectl run --generator=deployment/apps.v1 is DEPRECATED and will be removed in a future version. Use kubectl run --generator=run-pod/v1 or kubectl create instead.
deployment.apps/nginx created
</pre>

```console
kubectl get all --namespace=failure
```

<pre>
NAME                         READY   STATUS    RESTARTS   AGE
pod/nginx-64cccc97fb-mvjqw   1/1     Running   0          74s
pod/nginx-64cccc97fb-p6xx2   1/1     Running   0          74s
pod/nginx-64cccc97fb-rq7jx   1/1     Running   0          74s
pod/nginx-64cccc97fb-wnkxw   1/1     Running   0          74s

NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx   4/4     4            4           74s

NAME                               DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-64cccc97fb   4         4         4       74s

</pre>

### Scale it to 25 instances
```console
kubectl scale deployment nginx --replicas=25
```
<pre>
deployment.extensions/nginx scaled
</pre>

```console
kubectl get all --namespace=failure
```
<pre>
NAME                         READY   STATUS    RESTARTS   AGE
pod/nginx-64cccc97fb-28b9z   1/1     Running   0          69s
...
pod/nginx-64cccc97fb-wnkxw   1/1     Running   0          4m21s


NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx   10/25   10           10          4m22s

NAME                               DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-64cccc97fb   25        10        10      4m22s
</pre>

### Whats is going on ? We have only 10 instances ....

### Let's look at resources in our namespac

```console
kubectl describe namespace failure
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
 limits.cpu               2       2
 limits.memory            2000Mi  2Gi
 pods                     10      20
 requests.cpu             1       1
 requests.memory          1000Mi  1Gi
 requests.nvidia.com/gpu  0       3

Resource Limits
 Type       Resource  Min   Max   Default Request  Default Limit  Max Limit/Request Ratio
 ----       --------  ---   ---   ---------------  -------------  -----------------------
 Container  cpu       50m   800m  100m             200m           -
 Container  memory    50Mi  1Gi   100Mi            200Mi          -
</pre>

### Lets' try to change default limits and request  in  failure namespace

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: limit-mem-cpu-per-container
spec:
  limits:
  - max:
      cpu: "400m"
      memory: "500Mi"
    min:
      cpu: "25m"
      memory: "25Mi"
    default:
      cpu: "50m"
      memory: "50Mi"
    defaultRequest:
      cpu: "30m"
      memory: "30Mi"
    type: Container
```

```console
kubectl apply -f ./limit-mem-cpu-container-less.yaml --namespace=failure
```
<pre>
limitrange/limit-mem-cpu-per-container configured
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
 limits.cpu               2       2
 limits.memory            2000Mi  2Gi
 pods                     10      20
 requests.cpu             1       1
 requests.memory          1000Mi  1Gi
 requests.nvidia.com/gpu  0       3

Resource Limits
 Type       Resource  Min   Max    Default Request  Default Limit  Max Limit/Request Ratio
 ----       --------  ---   ---    ---------------  -------------  -----------------------
 Container  cpu       25m   400m   30m              50m            -
 Container  memory    25Mi  500Mi  30Mi             50Mi           -
</pre>

```console
kubectl get rs
```
<pre>
NAME               DESIRED   CURRENT   READY   AGE
nginx-64cccc97fb   25        10        10      16m
</pre>

```console
kubectl describe rs
```
<pre>
...
  Warning  FailedCreate      17m (x6 over 17m)  replicaset-controller  (combined from similar events): Error creating:
pods "nginx-64cccc97fb-h7v7m" is forbidden: exceeded quota: compute-resources, requested: limits.cpu=200m,limits.memory=200Mi,requests.cpu=100m,requests.memory=100Mi, used: limits.cpu=2,limits.memory=2000Mi,requests.cpu=1,requests.memory=1000Mi, limited: limits.cpu=2,limits.memory=2Gi,requests.cpu=1,requests.memory=1Gi
...
</pre>

### Nothing happened ? Only 10 instances are running?

### Let's try to delete and recreate deployment 

```console
kubectl delete deployment nginx
```

<pre>
deployment.extensions "nginx" deleted
</pre>

```console
kubectl run nginx --image=nginx:latest --replicas=20
```
<pre>
kubectl run --generator=deployment/apps.v1 is DEPRECATED and will be removed in a future version. Use kubectl run --generator=run-pod/v1 or kubectl create instead.
deployment.apps/nginx created
</pre>

```console
kubectl get all
```
<pre>
NAME                         READY   STATUS    RESTARTS   AGE
pod/nginx-64cccc97fb-287ng   1/1     Running   0          75s
...
pod/nginx-64cccc97fb-z4744   1/1     Running   0          75s

NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx   20/20   20           20          75s

NAME                               DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-64cccc97fb   20        20        20      75s

</pre>

### Now we are happy
```console
kubectl describe namespace failure
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
 limits.cpu               1       2
 limits.memory            1000Mi  2Gi
 pods                     20      20
 requests.cpu             600m    1
 requests.memory          600Mi   1Gi
 requests.nvidia.com/gpu  0       3

Resource Limits
 Type       Resource  Min   Max    Default Request  Default Limit  Max Limit/Request Ratio
 ----       --------  ---   ---    ---------------  -------------  -----------------------
 Container  cpu       25m   400m   30m              50m            -
 Container  memory    25Mi  500Mi  30Mi             50Mi           -
</pre>


### before deleting whole deployment... Let's chck what is QoS Class
```console
kubectl describe pod nginx-64cccc97fb-287ng  |grep "QoS Class" -A20
```

<pre>
QoS Class:       Burstable
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:
  Type    Reason     Age   From                               Message
  ----    ------     ----  ----                               -------
  Normal  Scheduled  10m   default-scheduler                  Successfully assigned failure/nginx-64cccc97fb-287ng to aks-nodepool1-16191604-2
  Normal  Pulling    10m   kubelet, aks-nodepool1-16191604-2  Pulling image "nginx:latest"
  Normal  Pulled     10m   kubelet, aks-nodepool1-16191604-2  Successfully pulled image "nginx:latest"
  Normal  Created    10m   kubelet, aks-nodepool1-16191604-2  Created container nginx
  Normal  Started    10m   kubelet, aks-nodepool1-16191604-2  Started container nginx
</pre>

```console
 kubectl describe pod nginx-64cccc97fb-287ng  |grep "Limits" -A5
 ```
 <pre>
    Limits:
      cpu:     50m
      memory:  50Mi
    Requests:
      cpu:        30m
      memory:     30Mi
</pre>

```console
kubectl delete deployment nginx
```
<pre>
deployment.extensions "nginx" deleted
<pre>

```console
kubectl get all
```
<pre>
No resources found.
</pre>

```console
kubectl run nginx --image=nginx:latest --replicas=15  --requests='cpu=50m,memory=50Mi' \
 --limits='cpu=50m,memory=50Mi'
```

<pre>
kubectl run --generator=deployment/apps.v1 is DEPRECATED and will be removed in a future version. Use kubectl run --generator=run-pod/v1 or kubectl create instead.
deployment.apps/nginx created
</pre>


### Instead of using kubectl run we should use yaml files


```console
kubectl get all
```
<pre>
NAME                         READY   STATUS    RESTARTS   AGE
pod/nginx-5d796d5bd4-2h7lk   1/1     Running   0          49s
...
pod/nginx-5d796d5bd4-zzld9   1/1     Running   0          49s

NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx   15/15   15           15          49s

NAME                               DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-5d796d5bd4   15        15        15      49s

</pre>

### Now we have Guaranteed QoS Class

```bash
POD_NAME=$(kubectl get pods -o jsonpath={.items[0].metadata.name})
kubectl describe pod $POD_NAME |grep "QoS Class" -A20
kubectl describe pod $POD_NAME |grep "Limits" -A5
```
<pre>
QoS Class:       Guaranteed
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:
  Type    Reason     Age   From                               Message
  ----    ------     ----  ----                               -------
  Normal  Scheduled  10m   default-scheduler                  Successfully assigned failure/nginx-5d796d5bd4-2h7lk to aks-nodepool1-16191604-0
  Normal  Pulling    10m   kubelet, aks-nodepool1-16191604-0  Pulling image "nginx:latest"
  Normal  Pulled     10m   kubelet, aks-nodepool1-16191604-0  Successfully pulled image "nginx:latest"
  Normal  Created    10m   kubelet, aks-nodepool1-16191604-0  Created container nginx
  Normal  Started    10m   kubelet, aks-nodepool1-16191604-0  Started container nginx

    Limits:
      cpu:     50m
      memory:  50Mi
    Requests:
      cpu:        50m
      memory:     50Mi
<pre>


### Let's look how are pod are scheduled on our nodes
```console
kubectl get pods -o wide
# or
kubectl get pod -o=custom-columns=NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName
```
<pre>
NAME                     STATUS    NODE
nginx-5d796d5bd4-2h7lk   Running   aks-nodepool1-16191604-0
..
nginx-5d796d5bd4-8thdf   Running   aks-nodepool1-16191604-1
nginx-5d796d5bd4-8x5nv   Running   aks-nodepool1-16191604-0
..
nginx-5d796d5bd4-mftdw   Running   aks-nodepool1-16191604-1
nginx-5d796d5bd4-mjz72   Running   aks-nodepool1-16191604-2
..
nginx-5d796d5bd4-zzld9   Running   aks-nodepool1-16191604-1
</pre>

### Now we are going to shutdown on of the VMs , for example  aks-nodepool1-16191604-2

### Before

$ kubectl get nodes
NAME                       STATUS   ROLES   AGE   VERSION
aks-nodepool1-16191604-0   Ready    agent   93m   v1.15.3
aks-nodepool1-16191604-1   Ready    agent   93m   v1.15.3
aks-nodepool1-16191604-2   Ready    agent   93m   v1.15.3

```console
kubectl get pod -o=custom-columns=NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName | grep aks-nodepool1-16191604-2
```
<pre>
nginx-5d796d5bd4-4nlqb   Running   aks-nodepool1-16191604-2
nginx-5d796d5bd4-6xgp7   Running   aks-nodepool1-16191604-2
nginx-5d796d5bd4-mjz72   Running   aks-nodepool1-16191604-2
nginx-5d796d5bd4-rpxr9   Running   aks-nodepool1-16191604-2
</pre>

### Stopping virtual machine 'aks-nodepool1-16191604-2'...

## Shut down VM aks-nodepool1-16191604-2 

### After 

#
kubectl get nodes
NAME                       STATUS     ROLES   AGE   VERSION
aks-nodepool1-16191604-0   Ready      agent   99m   v1.15.3
aks-nodepool1-16191604-1   Ready      agent   99m   v1.15.3
aks-nodepool1-16191604-2   NotReady   agent   99m   v1.15.3


#### Kubernetes stil doesnt know that pods node aks-nodepool1-16191604-0 are out of service
```console
kubectl get pod -o=custom-columns=NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName | grep aks-nodepool1-16191604-2
```
<pre>
nginx-5d796d5bd4-4nlqb   Running   aks-nodepool1-16191604-2
nginx-5d796d5bd4-6xgp7   Running   aks-nodepool1-16191604-2
nginx-5d796d5bd4-mjz72   Running   aks-nodepool1-16191604-2
nginx-5d796d5bd4-rpxr9   Running   aks-nodepool1-16191604-2
</pre>

### Let's us stop next VM  aks-nodepool1-16191604-1  after 5  minutes then aks-nodepool1-16191604-2

```console
Stopping virtual machine 'aks-nodepool1-16191604-1'...
```

$ kubectl get nodes
NAME                       STATUS     ROLES   AGE    VERSION
aks-nodepool1-16191604-0   Ready      agent   107m   v1.15.3
aks-nodepool1-16191604-1   NotReady   agent   107m   v1.15.3
aks-nodepool1-16191604-2   NotReady   agent   107m   v1.15.3


### After 5 minutes  of shuting down aks-nodepool1-16191604-2  we can see terminating pods

<pre>
kubectl get pods -o wide
NAME                     READY   STATUS        RESTARTS   AGE    IP            NODE                       NOMINATED NODE
 READINESS GATES
nginx-5d796d5bd4-2h7lk   1/1     Running       0          37m    10.244.2.17   aks-nodepool1-16191604-0   <none>
 <none>
nginx-5d796d5bd4-2xmzl   1/1     Running       0          7m6s   10.244.2.25   aks-nodepool1-16191604-0   <none>
 <none>
nginx-5d796d5bd4-4nlqb   1/1     Terminating   0          37m    10.244.0.18   aks-nodepool1-16191604-2   <none>
 <none>
nginx-5d796d5bd4-58wnm   1/1     Running       0          7m6s   10.244.2.23   aks-nodepool1-16191604-0   <none>
 <none>
nginx-5d796d5bd4-6xgp7   1/1     Terminating   0          37m    10.244.0.20   aks-nodepool1-16191604-2   <none>
 <none>
nginx-5d796d5bd4-8thdf   1/1     Running       0          37m    10.244.1.19   aks-nodepool1-16191604-1   <none>
 <none>
nginx-5d796d5bd4-8x5nv   1/1     Running       0          37m    10.244.2.18   aks-nodepool1-16191604-0   <none>
 <none>
nginx-5d796d5bd4-dbwc2   1/1     Running       0          37m    10.244.2.15   aks-nodepool1-16191604-0   <none>
 <none>
nginx-5d796d5bd4-gcc6j   1/1     Running       0          37m    10.244.1.16   aks-nodepool1-16191604-1   <none>
 <none>
nginx-5d796d5bd4-gfzjg   1/1     Running       0          37m    10.244.1.15   aks-nodepool1-16191604-1   <none>
 <none>
nginx-5d796d5bd4-gmmkd   1/1     Running       0          37m    10.244.2.19   aks-nodepool1-16191604-0   <none>
 <none>
nginx-5d796d5bd4-jg2zv   1/1     Running       0          7m6s   10.244.1.22   aks-nodepool1-16191604-1   <none>
 <none>
nginx-5d796d5bd4-k825p   1/1     Running       0          7m6s   10.244.1.23   aks-nodepool1-16191604-1   <none>
 <none>
nginx-5d796d5bd4-mftdw   1/1     Running       0          37m    10.244.1.18   aks-nodepool1-16191604-1   <none>
 <none>
nginx-5d796d5bd4-mjz72   1/1     Terminating   0          37m    10.244.0.17   aks-nodepool1-16191604-2   <none>
 <none>
nginx-5d796d5bd4-mvmtf   1/1     Running       0          37m    10.244.2.16   aks-nodepool1-16191604-0   <none>
 <none>
nginx-5d796d5bd4-rpxr9   1/1     Terminating   0          37m    10.244.0.19   aks-nodepool1-16191604-2   <none>
 <none>
nginx-5d796d5bd4-txrsb   1/1     Running       0          37m    10.244.2.14   aks-nodepool1-16191604-0   <none>
 <none>
nginx-5d796d5bd4-zzld9   1/1     Running       0          37m    10.244.1.17   aks-nodepool1-16191604-1   <none>
 <none>

</pre>

#### terminating forever

### What is going on ?
```console
kubectl get pods -o wide |wc -l
````
<pre>
20
</pre>
### Do you remember limits of pods per our namespace ?


### after next 5 minutes of shuting down  aks-nodepool1-16191604-1 

```console
kubectl get pods -o wide |wc -l
```
<pre>
25
</pre>

```console
kubectl get pods -o wide
```
<pre>
NAME                     READY   STATUS        RESTARTS   AGE     IP            NODE                       NOMINATED NODE   READINESS GATES
nginx-5d796d5bd4-2h7lk   1/1     Running       0          43m     10.244.2.17   aks-nodepool1-16191604-0   <none>           <none>
nginx-5d796d5bd4-2xmzl   1/1     Running       0          13m     10.244.2.25   aks-nodepool1-16191604-0   <none>           <none>
nginx-5d796d5bd4-4nlqb   1/1     Terminating   0          43m     10.244.0.18   aks-nodepool1-16191604-2   <none>           <none>
nginx-5d796d5bd4-58wnm   1/1     Running       0          13m     10.244.2.23   aks-nodepool1-16191604-0   <none>           <none>
nginx-5d796d5bd4-6xgp7   1/1     Terminating   0          43m     10.244.0.20   aks-nodepool1-16191604-2   <none>           <none>
nginx-5d796d5bd4-6xgqj   1/1     Running       0          4m35s   10.244.2.31   aks-nodepool1-16191604-0   <none>           <none>
nginx-5d796d5bd4-8thdf   1/1     Terminating   0          43m     10.244.1.19   aks-nodepool1-16191604-1   <none>           <none>
nginx-5d796d5bd4-8x5nv   1/1     Running       0          43m     10.244.2.18   aks-nodepool1-16191604-0   <none>           <none>
nginx-5d796d5bd4-dbwc2   1/1     Running       0          43m     10.244.2.15   aks-nodepool1-16191604-0   <none>           <none>
nginx-5d796d5bd4-g82tz   1/1     Running       0          4m35s   10.244.2.32   aks-nodepool1-16191604-0   <none>           <none>
nginx-5d796d5bd4-gcc6j   1/1     Terminating   0          43m     10.244.1.16   aks-nodepool1-16191604-1   <none>           <none>
nginx-5d796d5bd4-gfzjg   1/1     Terminating   0          43m     10.244.1.15   aks-nodepool1-16191604-1   <none>           <none>
nginx-5d796d5bd4-gmmkd   1/1     Running       0          43m     10.244.2.19   aks-nodepool1-16191604-0   <none>           <none>
nginx-5d796d5bd4-jg2zv   1/1     Terminating   0          13m     10.244.1.22   aks-nodepool1-16191604-1   <none>           <none>
nginx-5d796d5bd4-jk778   1/1     Running       0          4m35s   10.244.2.29   aks-nodepool1-16191604-0   <none>           <none>
nginx-5d796d5bd4-k825p   1/1     Terminating   0          13m     10.244.1.23   aks-nodepool1-16191604-1   <none>           <none>
nginx-5d796d5bd4-mftdw   1/1     Terminating   0          43m     10.244.1.18   aks-nodepool1-16191604-1   <none>           <none>
nginx-5d796d5bd4-mhwm8   1/1     Running       0          4m35s   10.244.2.33   aks-nodepool1-16191604-0   <none>           <none>
nginx-5d796d5bd4-mjz72   1/1     Terminating   0          43m     10.244.0.17   aks-nodepool1-16191604-2   <none>           <none>
nginx-5d796d5bd4-mvmtf   1/1     Running       0          43m     10.244.2.16   aks-nodepool1-16191604-0   <none>           <none>
nginx-5d796d5bd4-rpxr9   1/1     Terminating   0          43m     10.244.0.19   aks-nodepool1-16191604-2   <none>           <none>
nginx-5d796d5bd4-txrsb   1/1     Running       0          43m     10.244.2.14   aks-nodepool1-16191604-0   <none>           <none>
nginx-5d796d5bd4-vxdqn   1/1     Running       0          4m35s   10.244.2.30   aks-nodepool1-16191604-0   <none>           <none>
nginx-5d796d5bd4-zzld9   1/1     Terminating   0          43m     10.244.1.17   aks-nodepool1-16191604-1   <none>           <none>
</pre>


#### The pods from -1 and -2 node are terminating forever.


### Let's start our VMs
<pre>
Successfully started virtual machine 'aks-nodepool1-16191604-1'.
Successfully started virtual machine 'aks-nodepool1-16191604-2'.
</pre>

```console
kubectl get nodes
```

</pre>
NAME                       STATUS   ROLES   AGE    VERSION
aks-nodepool1-16191604-0   Ready    agent   122m   v1.15.3
aks-nodepool1-16191604-1   Ready    agent   122m   v1.15.3
aks-nodepool1-16191604-2   Ready    agent   123m   v1.15.3
</pre>


```console
kubectl get pod -o=custom-columns=NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName
```
<pre>
NAME                     STATUS    NODE
nginx-5d796d5bd4-2h7lk   Running   aks-nodepool1-16191604-0
nginx-5d796d5bd4-2xmzl   Running   aks-nodepool1-16191604-0
nginx-5d796d5bd4-58wnm   Running   aks-nodepool1-16191604-0
nginx-5d796d5bd4-6xgqj   Running   aks-nodepool1-16191604-0
nginx-5d796d5bd4-7v7gj   Running   aks-nodepool1-16191604-0
nginx-5d796d5bd4-8rrst   Running   aks-nodepool1-16191604-0
nginx-5d796d5bd4-8x5nv   Running   aks-nodepool1-16191604-0
nginx-5d796d5bd4-dbwc2   Running   aks-nodepool1-16191604-0
nginx-5d796d5bd4-g82tz   Running   aks-nodepool1-16191604-0
nginx-5d796d5bd4-gmmkd   Running   aks-nodepool1-16191604-0
nginx-5d796d5bd4-jk778   Running   aks-nodepool1-16191604-0
nginx-5d796d5bd4-mhwm8   Running   aks-nodepool1-16191604-0
nginx-5d796d5bd4-mvmtf   Running   aks-nodepool1-16191604-0
nginx-5d796d5bd4-txrsb   Running   aks-nodepool1-16191604-0
nginx-5d796d5bd4-vxdqn   Running   aks-nodepool1-16191604-0
</pre>

### All pods are now running on node -0

```console
util
```
<pre>
aks-nodepool1-16191604-0
  Resource                       Requests      Limits
  cpu                            1365m (71%)   1150m (60%)
  memory                         1489Mi (69%)  2690Mi (125%)

aks-nodepool1-16191604-1
  Resource                       Requests     Limits
  cpu                            175m (9%)    150m (7%)
  memory                         225Mi (10%)  600Mi (27%)

aks-nodepool1-16191604-2
  Resource                       Requests     Limits
  cpu                            175m (9%)    150m (7%)
  memory                         225Mi (10%)  600Mi (27%)

</pre>

### Now we have unfortunately unbalanced  nodes consumed resorces 


```console
kubectl get deployment
```

<pre>
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
nginx   15/15   15           15          54m
</pre>
```console
kubectl get deployment -o yaml --export  > nginx-deployment.yaml
```
</pre>
Flag --export has been deprecated, This flag is deprecated and will be removed in future.
</pre>
```console
kubectl delete -f ./nginx-deployment.yaml
```
<pre>
deployment.extensions "nginx" deleted
</pre>

```console
kubectl apply -f ./nginx-deployment.yaml
```
<pre>
deployment.extensions/nginx created
</pre>

```console
kubectl get pod -o=custom-columns=NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName
```
<pre>
NAME                     STATUS    NODE
nginx-5d796d5bd4-528tn   Running   aks-nodepool1-16191604-1
nginx-5d796d5bd4-5tcdc   Running   aks-nodepool1-16191604-1
nginx-5d796d5bd4-6cb5j   Running   aks-nodepool1-16191604-0
nginx-5d796d5bd4-b4cxj   Running   aks-nodepool1-16191604-1
nginx-5d796d5bd4-d75nz   Running   aks-nodepool1-16191604-2
nginx-5d796d5bd4-drt65   Running   aks-nodepool1-16191604-2
nginx-5d796d5bd4-dz2wc   Running   aks-nodepool1-16191604-1
nginx-5d796d5bd4-g55dm   Running   aks-nodepool1-16191604-1
nginx-5d796d5bd4-l7trq   Running   aks-nodepool1-16191604-1
nginx-5d796d5bd4-lxptm   Running   aks-nodepool1-16191604-0
nginx-5d796d5bd4-m27xl   Running   aks-nodepool1-16191604-0
nginx-5d796d5bd4-m2df4   Running   aks-nodepool1-16191604-2
nginx-5d796d5bd4-r8fjd   Running   aks-nodepool1-16191604-0
nginx-5d796d5bd4-rwblp   Running   aks-nodepool1-16191604-2
nginx-5d796d5bd4-tkngp   Running   aks-nodepool1-16191604-2
</pre>

### At the end delete our toys
```console
kubectl delete ns failure
```
<pre>
namespace "failure" deleted
</pre>
```console
kubectl top node
```
<pre>
NAME                       CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
aks-nodepool1-16191604-0   165m         8%     1163Mi          54%
aks-nodepool1-16191604-1   50m          2%     465Mi           21%
aks-nodepool1-16191604-2   48m          2%     468Mi           21%
</pre>

### That's all folks
