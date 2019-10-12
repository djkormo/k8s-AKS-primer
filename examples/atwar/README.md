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

#### What are limits of our nodes 


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

# Note: 4000m cores is the total cores in one node
alias cpualloc="util | grep % | awk '{print \$1}' | awk '{ sum += \$1 } END { if (NR > 0) { result=(sum**4000); printf result/NR \"%\n\" } }'"

# Note: 1600MB is the total cores in one node
alias memalloc='util | grep % | awk '\''{print $3}'\'' | awk '\''{ sum += $1 } END { if (NR > 0) { result=(sum*100)/(NR*1600); printf result/NR "%\n" } }'\'''


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


### Create RecourceQuota per namespace

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

### let's try to see information about quotas in failter namespace
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

#### Applying dafault limits and requests per  container in our namespace
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


### Once again lets see information about our namespace
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


### Here we have our environment ready to make some experiments.


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
pod/nginx-64cccc97fb-gsw7t   1/1     Running   0          69s
pod/nginx-64cccc97fb-kdszb   1/1     Running   0          69s
pod/nginx-64cccc97fb-lf6k6   1/1     Running   0          69s
pod/nginx-64cccc97fb-m7wds   1/1     Running   0          69s
pod/nginx-64cccc97fb-mvjqw   1/1     Running   0          4m21s
pod/nginx-64cccc97fb-p6xx2   1/1     Running   0          4m21s
pod/nginx-64cccc97fb-pf4ws   1/1     Running   0          69s
pod/nginx-64cccc97fb-rq7jx   1/1     Running   0          4m21s
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
