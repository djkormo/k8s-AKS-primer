Installing wordpress in multiple pods with autoscaler (hpa)

Let's create wordpress-multi-hpa namespace

```console
kubectl apply -f wordpress-namespace.yaml 
```
<pre>
namespace/wordpress-multi-hpa created
</pre>

Switching to our namespace as our default
```console
kubectl config set-context --current --namespace=wordpress-multi-hpa

```
<pre>
Context "***" modified.
</pre>

Deploying credentials (config map)
```console
kubectl apply -f wordpress-configmap.yaml -n wordpress-multi-hpa
```
<pre>
configmap/wordpress-multi-hpa-config created
</pre>
Setting namespace quotas
```console
kubectl apply -f wordpress-namespace-quotas.yaml -n wordpress-multi-hpa
```
<pre>
resourcequota/compute-resources created
</pre>
```console
kubectl describe ns wordpress-multi-hpa
```
<pre>
Name:         wordpress-multi-hpa
Labels:       <none>
Annotations:  kubectl.kubernetes.io/last-applied-configuration:
                {"apiVersion":"v1","kind":"Namespace","metadata":{"annotations":{},"name":"wordpress-multi-hpa"}}
Status:       Active

Resource Quotas
 Name:                    compute-resources
 Resource                 Used  Hard
 --------                 ---   ---
 limits.cpu               0     4
 limits.memory            0     4Gi
 pods                     0     15
 requests.cpu             0     2
 requests.memory          0     2Gi
 requests.nvidia.com/gpu  0     0

No resource limits.
</pre>

Deploying mysql part

```console
kubectl apply -f mysql-deployment.yaml  -n wordpress-multi-hpa
```
<pre>
deployment.extensions/wordpress-multi-hpa-mysql created
</pre>


Creating service for mysql database pod

```console
kubectl apply -f mysql-service.yaml  -n wordpress-multi-hpa
```
<pre>
service/wordpress-multi-hpa-mysql-service created
</pre>

Deploying frontend part (apache and php)

```console
kubectl apply -f wordpress-deployment.yaml -n wordpress-multi-hpa
```
<pre>
deployment.extensions/wordpress-multi-hpa created
</pre>

...and service for frontend

```console
kubectl apply -f wordpress-service.yaml -n wordpress-multi-hpa
```
<pre>
service/wordpress-multi-hpa-service created
</pre>


Let's create autoscale rules for HPA


```console
kubectl apply -f wordpress-autoscaler.yaml -n wordpress-multi-hpa

```
<pre>
horizontalpodautoscaler.autoscaling/wordpress-hpa created
</pre>


```console
kubectl get hpa -n wordpress-multi-hpa
```

<pre>
NAME            REFERENCE                        TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
wordpress-hpa   Deployment/wordpress-multi-hpa   0%/10%    1         10        1          37s
</pre>

Before load test

```console
kubectl top pods -n wordpress-multi-hpa
```
<pre>
NAME                                         CPU(cores)   MEMORY(bytes)   
wordpress-multi-hpa-764b567bbc-zwm5q         1m           19Mi
wordpress-multi-hpa-mysql-69db7f9897-krwgp   1m           196Mi
</pre>

```console
kubectl top nodes -n wordpress-multi-hpa
```
<pre>
NAME                       CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%   
aks-nodepool1-36820653-0   315m         16%    1442Mi          67%
aks-nodepool1-36820653-1   120m         6%     1572Mi          73% 
</pre>
```console
kubectl run load-generator-$RANDOM --generator=run-pod/v1 \
  --namespace=wordpress-multi-hpa \
  --limits="cpu=200m,memory=100Mi" \
  --requests="cpu=100m,memory=50Mi" \
  --rm -i --tty --image busybox -- sh
```

Inside pod run endless loop 
```console
while true; do wget -O- http://wordpress-multi-hpa-service:80/; done
```


Using the same by with apache benchmark (ab)



```console
kubectl run  -i --rm --restart=Never  --image=mocoso/apachebench \
-n wordpress-multi-hpa load-generator-$RANDOM -- bash \
-c "ab   -n 10000 -c 100 -k   http://wordpress-multi-hpa-service:80/"
```
<pre>

</pre>

