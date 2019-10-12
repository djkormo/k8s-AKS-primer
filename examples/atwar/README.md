## Kubernetes at War on Azure


### First, let's create simple AKS cluster with tree nodes

bash ./deploy_AKS_to_Azure.bash

### It takes about  15-20 minutes to start 


```console
kubectl get nodes
```
<pre>

</pre>


#### What are limits of our nodes 

```console
kubectl get namespaces # or ns 
```

<pre>

</pre>

### let's create new namespace for our experiments

```console
kubectl create ns failure
```
<pre>

</pre>

```console
kubectl get ns
```

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
kubeclt apply -f quotas --namespace=failure
```
<pre>
resourcequota/compute-resources created
</pre>


### Let's switch to failure namespace as our new default namespace


```console

```


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

</pre>

```console
kubectl describe limitrange --namespace=failure
```
<pre>
Namespace:  failure
Type        Resource  Min   Max   Default Request  Default Limit  Max Limit/Request Ratio
----        --------  ---   ---   ---------------  -------------  -----------------------
Container   memory    50Mi  1Gi   101Mi            200Mi          -
Container   cpu       50m   800m  100m             200m           -
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


### Here we have our environment ready to make  some experiments.


