# Using headless service in Kubernetes.


```console
kubectl create ns headless
```
<pre>
namespace/headless created
</pre>
```console
kubectl config set-context --current --namespace=headless
```
<pre>
Context "***" modified.
</pre>

```console
kubectl apply -f my-deployment.yaml 
```
<pre>
deployment.apps/api-deployment created
</pre>

```console
kubectl apply -f my-headless-service.yaml
```
<pre>
service/headless-service created
</pre>

```console
kubectl apply -f my-normal-service.yaml 
```
<pre>
service/normal-service created
</pre>
```console
kubectl get all
```
<pre>
NAME                                 READY   STATUS    RESTARTS   AGE
pod/api-deployment-f457fbcf6-4qrlq   1/1     Running   0          52s
pod/api-deployment-f457fbcf6-mm8lc   1/1     Running   0          52s
pod/api-deployment-f457fbcf6-nltgf   1/1     Running   0          52s
pod/api-deployment-f457fbcf6-rsnlh   1/1     Running   0          52s
pod/api-deployment-f457fbcf6-v774c   1/1     Running   0          52s

NAME                       TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
service/headless-service   ClusterIP   None             <none>        80/TCP    42s
service/normal-service     ClusterIP   10.108.188.236   <none>        80/TCP    30s

NAME                             READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/api-deployment   5/5     5            5           52s

NAME                                       DESIRED   CURRENT   READY   AGE
replicaset.apps/api-deployment-f457fbcf6   5         5         5       52s

</pre>

```console
kubectl get pods -o wide
```
<pre>
NAME                             READY   STATUS    RESTARTS   AGE    IP           NODE             NOMINATED NODE   READINESS GATES
api-deployment-f457fbcf6-4qrlq   1/1     Running   0          103s   10.1.1.250   docker-desktop   <none>           <none>
api-deployment-f457fbcf6-mm8lc   1/1     Running   0          103s   10.1.1.249   docker-desktop   <none>           <none>
api-deployment-f457fbcf6-nltgf   1/1     Running   0          103s   10.1.1.248   docker-desktop   <none>           <none>
api-deployment-f457fbcf6-rsnlh   1/1     Running   0          103s   10.1.1.251   docker-desktop   <none>           <none>
api-deployment-f457fbcf6-v774c   1/1     Running   0          103s   10.1.1.252   docker-desktop   <none>           <none>
</pre>


```console
kubectl run headless-test-$RANDOM --generator=run-pod/v1 \
  --limits="cpu=200m,memory=100Mi" \
  --requests="cpu=100m,memory=50Mi" \
--rm  -it --image eddiehale/utils bash
```

Inside pod run dns queries

```bash
nslookup normal-service
```
<pre>
Server:         10.96.0.10
Address:        10.96.0.10#53

Name:   normal-service.headless.svc.cluster.local
Address: 10.108.188.236
</pre>

```bash
nslookup headless-service
```
<pre>
Server:         10.96.0.10
Address:        10.96.0.10#53

Name:   headless-service.headless.svc.cluster.local
Address: 10.1.1.252
Name:   headless-service.headless.svc.cluster.local
Address: 10.1.1.248
Name:   headless-service.headless.svc.cluster.local
Address: 10.1.1.251
Name:   headless-service.headless.svc.cluster.local
Address: 10.1.1.250
Name:   headless-service.headless.svc.cluster.local
Address: 10.1.1.249
</pre>




```bash
exit
```
<pre>
Session ended, resume using 'kubectl attach headless-test-28526 -c headless-test-28526 -i -t' command when the pod is running
pod "headless-test-28526" deleted
</pre>

Cleanup deployment

```console
kubectl delete ns headless
```
<pre>
namespace "headless" deleted
</pre>


Literature:

https://dev.to/kaoskater08/building-a-headless-service-in-kubernetes-3bk8


https://medium.com/faun/kubernetes-headless-service-vs-clusterip-and-traffic-distribution-904b058f0dfd


https://blog.markvincze.com/how-to-use-envoy-as-a-load-balancer-in-kubernetes/

