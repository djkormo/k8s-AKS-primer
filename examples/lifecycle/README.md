Lifecycle of Pod in Kubernetes cluster

#### Based on https://medium.com/@Alibaba_Cloud/pod-lifecycle-container-lifecycle-hooks-and-restartpolicy-ab57f8e3ff35



![Lifecycle of Pod](kubernetes-pod-life-cycle.jpg)


```console 
kubectl create ns cycle 
```
<pre>
namespace/cycle created
</pre>

```console 
$ kubectl config set-context --current --namespace=cycle
```
<pre>
Context "docker-desktop" modified.
</pre>


```console
kubectl config view | grep namespace:
```
<pre>
    namespace: cycle
</pre>



[mylifecyclepod-1](mylifecyclepod-1.yaml "mylifecyclepod-1")

```console
kubectl apply -f mylifecyclepod-1.yaml
```
<pre>
pod/myapp-pod created
</pre>

.....

DEMO  
....

```console 
kubectl delete/myapp-pod 
```
<pre>
pod "myapp-pod" deleted
</pre>


[mylifecyclepod-2](mylifecyclepod-2.yaml "mylifecyclepod-2")

```console
kubectl apply -f mylifecyclepod-2.yaml
```
<pre>
pod/myapp-pod created
</pre>
.....

DEMO  
....

```console 
kubectl delete/myapp-pod 
```
<pre>
pod "myapp-pod" deleted
</pre>

[mylifecyclepod-3](mylifecyclepod-3.yaml "mylifecyclepod-3")


```console
kubectl apply -f mylifecyclepod-3.yaml
```
<pre>
pod/myapp-pod created
</pre>

.....

DEMO  
....

```console 
kubectl delete/myapp-pod 
```
<pre>
pod "myapp-pod" deleted
</pre>

[mylifecyclepod-4](mylifecyclepod-4.yaml "mylifecyclepod-4")

```console
kubectl apply -f mylifecyclepod-4.yaml
```
<pre>
pod/myapp-pod created
</pre>

.....

DEMO  
....

```console 
kubectl delete/myapp-pod 
```
<pre>
pod "myapp-pod" deleted
</pre>

[mylifecyclepod-5](mylifecyclepod-5.yaml "mylifecyclepod-5")

```console
kubectl apply -f mylifecyclepod-5.yaml
```
<pre>
pod/myapp-pod created
</pre>


.....

DEMO  
....

```console 
kubectl delete/myapp-pod 
```
<pre>
pod "myapp-pod" deleted
</pre>


[mylifecyclepod-6](mylifecyclepod-6.yaml "mylifecyclepod-6")

```console
kubectl apply -f mylifecyclepod-6.yaml
```
<pre>
pod/myapp-pod created
</pre>


.....

DEMO  
....

```console 
kubectl delete/myapp-pod 
```
<pre>
pod "myapp-pod" deleted
</pre>



[mylifecyclepod-7](mylifecyclepod-7.yaml "mylifecyclepod-7")

```console
kubectl apply -f mylifecyclepod-7.yaml
```
<pre>
pod/myapp-pod created
</pre>


.....

DEMO  
....

```console 
kubectl delete/myapp-pod 
```
<pre>
pod "myapp-pod" deleted
</pre>


```console
kubectl delete ns cycle 
```
<pre>
namespace "cycle" deleted
</pre>


Literature
https://medium.com/@Alibaba_Cloud/pod-lifecycle-container-lifecycle-hooks-and-restartpolicy-ab57f8e3ff35
https://dzone.com/articles/kubernetes-lifecycle-of-a-pod


