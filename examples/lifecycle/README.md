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
kubectl config set-context --current --namespace=cycle
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



[mylifecyclepod-1 : mylifecyclepod-1 : sleep 6](mylifecyclepod-1.yaml")

```console
kubectl apply -f mylifecyclepod-1.yaml
```
<pre>
pod/myapp-pod created
</pre>

.....
```console
kubectl get po -w
```
<pre>
NAME        READY   STATUS    RESTARTS   AGE
myapp-pod   1/1     Running   0          8s
myapp-pod   0/1     Completed   0          11s
myapp-pod   1/1     Running     1          15s
myapp-pod   0/1     Completed   1          22s
myapp-pod   0/1     CrashLoopBackOff   1          34s
myapp-pod   1/1     Running            2          38s
myapp-pod   0/1     Completed          2          43s
myapp-pod   0/1     CrashLoopBackOff   2          59s
myapp-pod   1/1     Running            3          74s
myapp-pod   0/1     Completed          3          81s

</pre>

```console
kubectl describe pod/myapp-pod 
```
<pre>
Name:               myapp-pod
Namespace:          cycle
Priority:           0
PriorityClassName:  <none>
Node:               docker-desktop/192.168.65.3
Start Time:         Fri, 27 Dec 2019 20:01:10 +0100
Labels:             app=myapp
Annotations:        kubectl.kubernetes.io/last-applied-configuration:
                      {"apiVersion":"v1","kind":"Pod","metadata":{"annotations":{},"labels":{"app":"myapp"},"name":"myapp-pod","namespace":"cycle"},"spec":{"con...
Status:             Running
IP:                 10.1.1.50
Containers:
  myapp-container:
    Container ID:  docker://9102c743a7816b3369a3dd33d4bcb395a65a1f0b8028ffd93ec71a51762d0f4e
    Image:         busybox
    Image ID:      docker-pullable://busybox@sha256:6915be4043561d64e0ab0f8f098dc2ac48e077fe23f488ac24b665166898115a
    Port:          <none>
    Host Port:     <none>
    Command:
      sh
      -c
      echo The Pod is running && sleep 6
    State:          Waiting
      Reason:       CrashLoopBackOff
    Last State:     Terminated
      Reason:       Completed
      Exit Code:    0
      Started:      Fri, 27 Dec 2019 20:03:25 +0100
      Finished:     Fri, 27 Dec 2019 20:03:31 +0100
    Ready:          False
    Restart Count:  4
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-67fwc (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             False
  ContainersReady   False
  PodScheduled      True
Volumes:
  default-token-67fwc:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-67fwc
    Optional:    false
QoS Class:       BestEffort
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:
  Type     Reason     Age                  From                     Message
  ----     ------     ----                 ----                     -------
  Normal   Scheduled  3m6s                 default-scheduler        Successfully assigned cycle/myapp-pod to docker-desktop
  Normal   Created    112s (x4 over 3m2s)  kubelet, docker-desktop  Created container myapp-container
  Normal   Started    112s (x4 over 3m2s)  kubelet, docker-desktop  Started container myapp-container
  Warning  BackOff    67s (x7 over 2m44s)  kubelet, docker-desktop  Back-off restarting failed container
  Normal   Pulling    54s (x5 over 3m5s)   kubelet, docker-desktop  Pulling image "busybox"
  Normal   Pulled     51s (x5 over 3m2s)   kubelet, docker-desktop  Successfully pulled image "busybox"
</pre>
....

```console 
kubectl delete/myapp-pod 
```
<pre>
pod "myapp-pod" deleted
</pre>


[mylifecyclepod-2 : restartPolicy: Never , exit 1](mylifecyclepod-2.yaml "mylifecyclepod-2")

```console
kubectl apply -f mylifecyclepod-2.yaml
```
<pre>
pod/myapp-pod created
</pre>
.....

```console
kubectl get pod -w
```
<pre>
NAME        READY   STATUS   RESTARTS   AGE
myapp-pod   0/1     Error    0          7s 
</pre>

```console
kubectl describe pod myapp-pod
```
<pre>
Name:               myapp-pod
Namespace:          cycle    
Priority:           0        
PriorityClassName:  <none>   
Node:               docker-desktop/192.168.65.3
Start Time:         Fri, 27 Dec 2019 20:08:38 +0100
Labels:             app=myapp
Annotations:        kubectl.kubernetes.io/last-applied-configuration:
                      {"apiVersion":"v1","kind":"Pod","metadata":{"annotations":{},"labels":{"app":"myapp"},"name":"myapp-pod","namespace":"cycle"},"spec":{"con...
Status:             Failed
IP:                 10.1.1.51
Containers:
  myapp-container:
    Container ID:  docker://fc0c80987542d9674ffa5c7892890a5d3e9ae68deaa062cc18e982a50b8508bb
    Image:         busybox
    Image ID:      docker-pullable://busybox@sha256:6915be4043561d64e0ab0f8f098dc2ac48e077fe23f488ac24b665166898115a
    Port:          <none>
    Host Port:     <none>
    Command:
      sh
      -c
      echo The Pod is running && exit 1
    State:          Terminated
      Reason:       Error
      Exit Code:    1
      Started:      Fri, 27 Dec 2019 20:08:39 +0100
      Finished:     Fri, 27 Dec 2019 20:08:39 +0100
    Ready:          False
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-67fwc (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             False
  ContainersReady   False
  PodScheduled      True
Volumes:
  default-token-67fwc:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-67fwc
    Optional:    false
QoS Class:       BestEffort
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:
  Type    Reason     Age    From                     Message
  ----    ------     ----   ----                     -------
  Normal  Scheduled  2m51s  default-scheduler        Successfully assigned cycle/myapp-pod to docker-desktop        
  Normal  Pulled     2m50s  kubelet, docker-desktop  Container image "busybox" already present on machine
  Normal  Created    2m50s  kubelet, docker-desktop  Created container myapp-container
  Normal  Started    2m50s  kubelet, docker-desktop  Started container myapp-container

</pre>


```console 
kubectl delete/myapp-pod 
```
<pre>
pod "myapp-pod" deleted
</pre>

[mylifecyclepod-3 : restartPolicy: Always, exit 1](mylifecyclepod-3.yaml "mylifecyclepod-3")


```console
kubectl apply -f mylifecyclepod-3.yaml
```
<pre>
pod/myapp-pod created
</pre>


```console
kubectl apply -f mylifecyclepod-3.yaml
```
<pre>
pod/myapp-pod created
</pre>

```console
kubectl get pod myapp-pod -w
```
<pre>
NAME        READY   STATUS              RESTARTS   AGE
myapp-pod   0/1     ContainerCreating   0          0s 
myapp-pod   0/1     Error               0          2s
myapp-pod   0/1     Error               1          3s
myapp-pod   0/1     CrashLoopBackOff    1          4s
myapp-pod   0/1     Error               2          21s
myapp-pod   0/1     CrashLoopBackOff    2          35s
myapp-pod   0/1     Error               3          48s
myapp-pod   0/1     CrashLoopBackOff    3          61s
</pre>
  

```console
kubectl describe pod myapp-pod
```
<pre>
Name:               myapp-pod
Namespace:          cycle
Priority:           0
PriorityClassName:  <none>
Node:               docker-desktop/192.168.65.3
Start Time:         Fri, 27 Dec 2019 20:14:34 +0100
Labels:             app=myapp
Annotations:        kubectl.kubernetes.io/last-applied-configuration:
                      {"apiVersion":"v1","kind":"Pod","metadata":{"annotations":{},"labels":{"app":"myapp"},"name":"myapp-pod","namespace":"cycle"},"spec":{"con...
Status:             Running
IP:                 10.1.1.53
Containers:
  myapp-container:
    Container ID:  docker://31302e4ca0a0bed46ffdedc36c43bba17884c2293cee5dd71350444dcaae910f
    Image:         busybox
    Image ID:      docker-pullable://busybox@sha256:6915be4043561d64e0ab0f8f098dc2ac48e077fe23f488ac24b665166898115a
    Port:          <none>
    Host Port:     <none>
    Command:
      sh
      -c
      echo The Pod is running && exit 1
    State:          Waiting
      Reason:       CrashLoopBackOff
    Last State:     Terminated
      Reason:       Error
      Exit Code:    1
      Started:      Fri, 27 Dec 2019 20:16:04 +0100
      Finished:     Fri, 27 Dec 2019 20:16:04 +0100
    Ready:          False
    Restart Count:  4
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-67fwc (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             False
  ContainersReady   False
  PodScheduled      True
Volumes:
  default-token-67fwc:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-67fwc
    Optional:    false
QoS Class:       BestEffort
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:
  Type     Reason     Age                   From                     Message
  ----     ------     ----                  ----                     -------
  Normal   Scheduled  2m14s                 default-scheduler        Successfully assigned cycle/myapp-pod to docker-desktop
  Normal   Pulled     44s (x5 over 2m13s)   kubelet, docker-desktop  Container image "busybox" already present on machine
  Normal   Created    44s (x5 over 2m13s)   kubelet, docker-desktop  Created container myapp-container
  Normal   Started    44s (x5 over 2m13s)   kubelet, docker-desktop  Started container myapp-container
  Warning  BackOff    21s (x10 over 2m11s)  kubelet, docker-desktop  Back-off restarting failed container  
 
</pre> 


```console 
kubectl delete/myapp-pod 
```
<pre>
pod "myapp-pod" deleted
</pre>

[mylifecyclepod-4 : restartPolicy: Always, sleep 1 ](mylifecyclepod-4.yaml "mylifecyclepod-4")

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

[mylifecyclepod-5 : restartPolicy: OnFailure, sleep 1 ](mylifecyclepod-5.yaml "mylifecyclepod-5")

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


[mylifecyclepod-6  : restartPolicy: Never, sleep 1 ](mylifecyclepod-6.yaml "mylifecyclepod-6")

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



[mylifecyclepod-7](mylifecyclepod-7.yaml "mylifecyclepod-7 : restartPolicy: Never, exit 1")

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

https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/?spm=a2c41.12820884.0.0.22345fa8qLBgIw
https://kubernetes.io/docs/tasks/configure-pod-container/attach-handler-lifecycle-event/?spm=a2c41.12820884.0.0.22345fa8qLBgIw



