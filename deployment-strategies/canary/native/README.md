
## Steps to follow

1. 10 replicas of version 1 is serving traffic
1. deploy 1 replicas version 2 (meaning ~10% of traffic)
1. wait enought time to confirm that version 2 is stable and not throwing
   unexpected errors
1. scale up version 2 replicas to 10
1. wait until all instances are ready
1. shutdown version 1


```console
kubectl create ns canary
```
<pre>
namespace/canary created
</pre>

```console
kubectl config set-context --current --namespace=canary
```
<pre>
Context *** modified.
</pre>

```console
kubectl apply -f app-deploy-v1.yaml
```
<pre>
deployment.apps/my-app-v1 created
</pre>

```console
kubectl apply -f app-service.yaml
```
<pre>
service/my-app created
</pre>

```console
kubectl get pod  -L app -L  version
```
<pre>
NAME                         READY   STATUS    RESTARTS   AGE   APP      VERSION
my-app-v1-6ff4f84c8d-664dg   1/1     Running   0          76s   my-app   v1.0.0
my-app-v1-6ff4f84c8d-7t8td   1/1     Running   0          76s   my-app   v1.0.0
my-app-v1-6ff4f84c8d-c6lqb   1/1     Running   0          76s   my-app   v1.0.0
my-app-v1-6ff4f84c8d-fbk8m   1/1     Running   0          76s   my-app   v1.0.0
my-app-v1-6ff4f84c8d-j745k   1/1     Running   0          76s   my-app   v1.0.0
my-app-v1-6ff4f84c8d-j97cp   1/1     Running   0          76s   my-app   v1.0.0
my-app-v1-6ff4f84c8d-kbsgs   1/1     Running   0          76s   my-app   v1.0.0
my-app-v1-6ff4f84c8d-kxhvx   1/1     Running   0          76s   my-app   v1.0.0
my-app-v1-6ff4f84c8d-lqkt2   1/1     Running   0          76s   my-app   v1.0.0
my-app-v1-6ff4f84c8d-vxszm   1/1     Running   0          76s   my-app   v1.0.0
</pre>

```console
kubectl apply -f app-deploy-v2.yaml
```
<pre>
deployment.apps/my-app-v2 created
</pre>

```console
kubectl get pod  -L app -L  version
```
<pre>
NAME                         READY   STATUS    RESTARTS   AGE     APP      VERSION
my-app-v1-6ff4f84c8d-664dg   1/1     Running   0          3m27s   my-app   v1.0.0
my-app-v1-6ff4f84c8d-7t8td   1/1     Running   0          3m27s   my-app   v1.0.0
my-app-v1-6ff4f84c8d-c6lqb   1/1     Running   0          3m27s   my-app   v1.0.0
...
my-app-v2-7bd4b55cbd-8r5d2   1/1     Running   0          80s     my-app   v2.0.0
</pre>


Now we have ten pod with version v1.0.0 and one pod with version v2.0.0

Selector in service my-app

```console
kubectl describe svc my-app |grep Selector: -A0
```
<pre>
Selector:                 app=my-app
</pre>

```console
kubectl get deploy
```
<pre>
NAME        READY   UP-TO-DATE   AVAILABLE   AGE
my-app-v1   10/10   10           10          7m31s
my-app-v2   1/1     1            1           5m24s
</pre>

Scale app-v2 deployment  up to ten instances

```console
kubectl apply -f app-deploy-v2-to-10-replicas.yaml 
```
<pre>
deployment.apps/my-app-v2 configured
</pre>

```
kubectl get deploy
```
<pre>
NAME        READY   UP-TO-DATE   AVAILABLE   AGE
my-app-v1   10/10   10           10          11m
my-app-v2   10/10   10           10          9m42s
</pre>

Now we have ten v1.0.0 pods and ten v2.0.0 pods

```
kubectl get svc
```

<pre>
NAME     TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
my-app   ClusterIP   10.106.188.229   <none>        8080/TCP   11s
</pre>

```console
kubectl run load-generator-$RANDOM --generator=run-pod/v1 \
  --limits="cpu=200m,memory=100Mi" \
  --requests="cpu=100m,memory=50Mi" \
  --rm -i --tty --image radial/busyboxplus:curl -- sh
```
<pre>

service=my-app

ping $service
#PING my-app (10.101.237.13): 56 data bytes

nslookup my-app
#Name:      my-app
#Address 1: 10.101.237.13 my-app.canary.svc.cluster.local


curl http://$service:8080
#Host: my-app-v2-7bd4b55cbd-4bthb, Version: v2.0.0


while sleep 1; do curl "$service:8080"; done

#Host: my-app-v1-6ff4f84c8d-kbrfd, Version: v1.0.0
#Host: my-app-v2-7bd4b55cbd-jg299, Version: v2.0.0
#Host: my-app-v2-7bd4b55cbd-sttbd, Version: v2.0.0
#Host: my-app-v2-7bd4b55cbd-4bthb, Version: v2.0.0
#Host: my-app-v2-7bd4b55cbd-v82pq, Version: v2.0.0
#Host: my-app-v1-6ff4f84c8d-r5f86, Version: v1.0.0
#Host: my-app-v2-7bd4b55cbd-v82pq, Version: v2.0.0
#Host: my-app-v2-7bd4b55cbd-vblcp, Version: v2.0.0
#Host: my-app-v1-6ff4f84c8d-dcq2j, Version: v1.0.0

exit

#Session ended, resume using 'kubectl attach load-generator-31816 -c load-generator-31816 -i -t' command when the pod is running
#pod "load-generator-31816" deleted

</pre>

Making decision to delete version v1.0.0

```console
kubectl delete deploy my-app-v1
```
<pre>
deployment.extensions "my-app-v1" deleted
</pre>

```console
  kubectl get pod  -L app -L  version
```
<pre>

NAME                         READY   STATUS    RESTARTS   AGE     APP      VERSION
my-app-v2-7bd4b55cbd-2n7nl   1/1     Running   0          3m44s   my-app   v2.0.0
my-app-v2-7bd4b55cbd-4bthb   1/1     Running   0          3m37s   my-app   v2.0.0
my-app-v2-7bd4b55cbd-6zngl   1/1     Running   0          3m37s   my-app   v2.0.0
my-app-v2-7bd4b55cbd-fdpzn   1/1     Running   0          3m37s   my-app   v2.0.0
my-app-v2-7bd4b55cbd-jg299   1/1     Running   0          3m37s   my-app   v2.0.0
my-app-v2-7bd4b55cbd-lbskb   1/1     Running   0          3m37s   my-app   v2.0.0
my-app-v2-7bd4b55cbd-lnqhj   1/1     Running   0          3m37s   my-app   v2.0.0
my-app-v2-7bd4b55cbd-sttbd   1/1     Running   0          3m37s   my-app   v2.0.0
my-app-v2-7bd4b55cbd-v82pq   1/1     Running   0          3m37s   my-app   v2.0.0
my-app-v2-7bd4b55cbd-vblcp   1/1     Running   0          3m37s   my-app   v2.0.0
</pre>

Cleanup deployment

```console
kubectl delete ns canary
```
<pre>
namespace "canary" deleted
</pre>


