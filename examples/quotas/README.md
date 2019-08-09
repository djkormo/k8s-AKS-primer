## Using quotas and pod resource limits


### Create namespace for application

```console
kubectl create namespace my-app
```

## Creating quotas per application namespace

```console
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

### applying quotas to namespace

```console
kubectl apply -f ./quotas.yaml --namespace=my-app

```
<pre>
resourcequota/compute-resources created
</pre>

### Creating limit ranges for pods in namespace

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

```console
 kubectl apply -f ./limit-mem-cpu-container.yaml --namespace=my-app
```
<pre>
kubectl apply -f ./limit-mem-cpu-container.yaml --namespace=my-app
</pre>

```console
kubectl describe limitrange --namespace=my-app
```
<pre>
Namespace:  my-app
Type        Resource  Min   Max   Default Request  Default Limit  Max Limit/Request Ratio
----        --------  ---   ---   ---------------  -------------  -----------------------
Container   memory    50Mi  1Gi   101Mi            200Mi          -
Container   cpu       50m   800m  100m             200m           -
</pre>


```console
kubectl describe namespace my-app |grep "Resource Quotas" -A9
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


#### Changing context to my-app namespace 

###### Get current context
```console
kubectl config current-context
```
<pre>
aks-simple5129
</pre>

##### Change to dedicated namespace
```console
kubectl config set-context --current --namespace=my-app
```
<pre>
Context "aks-simple5129" modified.
</pre>


##### Deploying sample applications

```console
kubectl apply -f ./pod-1.yaml
```

##### without default limit  in limitrange

<pre>
Error from server (Forbidden): error when creating "./pod-1.yaml": pods "pod-quota-1" is forbidden: failed quota: compute-resources: must specify limits.cpu,limits.memory,requests.cpu,requests.memory
</pre>
#### with defaults
<pre>
pod/pod-quota-1 created
</pre>

```console
kubectl get pod pod-quota-1 --namespace=my-app
```
<pre>
NAME          READY   STATUS    RESTARTS   AGE
pod-quota-1   1/1     Running   0          8s
</pre>

```console
kubectl get resourcequota compute-resources --namespace=my-app --output=yaml
```

<pre>
spec:
  hard:
    limits.cpu: "2"
    limits.memory: 2Gi
    pods: "20"
    requests.cpu: "1"
    requests.memory: 1Gi
    requests.nvidia.com/gpu: "3"
status:
  hard:
    limits.cpu: "2"
    limits.memory: 2Gi
    pods: "20"
    requests.cpu: "1"
    requests.memory: 1Gi
    requests.nvidia.com/gpu: "3"
  used:
    limits.cpu: 200m
    limits.memory: 200Mi
    pods: "1"
    requests.cpu: 100m
    requests.memory: 100Mi
    requests.nvidia.com/gpu: "0"
</pre>
```console
kubectl apply -f ./pod-2.yaml
```
<pre>
pod/pod-quota-2 created
</pre>

```console
kubectl get pod pod-quota-2 --namespace=my-app
```

<pre>
NAME          READY   STATUS    RESTARTS   AGE
pod-quota-2   1/1     Running   0          32s
</pre>


```console
kubectl get resourcequota compute-resources --namespace=my-app --output=yaml
```

<pre>
  used:
    limits.cpu: "1"
    limits.memory: 1224Mi
    pods: "2"
    requests.cpu: 500m
    requests.memory: 800Mi
    requests.nvidia.com/gpu: "0"
</pre>

```console
kubectl apply -f ./pod-3.yaml
```
<pre>
Error from server (Forbidden): error when creating "./pod-3.yaml": pods "pod-quota-3" is forbidden: exceeded quota: compute-resources, requested: limits.memory=1000Mi,requests.cpu=800m,requests.memory=1000Mi, used: limits.memory=1224Mi,requests.cpu=500m,requests.memory=800Mi, limited: limits.memory=2Gi,requests.cpu=1,requests.memory=1Gi

</pre>

```console
kubectl apply -f ./pod-4.yaml
```
<pre>
Error from server (Forbidden): error when creating "./pod-4.yaml": pods "pod-quota-4" is forbidden: maximum cpu usage per Container is 800m, but limit is 1.
</pre>
