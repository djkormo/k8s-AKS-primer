Ramped deployment
=================

> Version B is slowly rolled out and replacing version A. Also known as
rolling-update or incremental.

![kubernetes ramped deployment](grafana-ramped.png)

The ramped deployment strategy consists of slowly rolling out a version of an
application by replacing instances one after the other until all the instances
are rolled out. It usually follows the following process: with a pool of version
A behind a load balancer, one instance of version B is deployed. When the
service is ready to accept traffic, the instance is added to the pool. Then, one
instance of version A is removed from the pool and shut down.

Depending on the system taking care of the ramped deployment, you can tweak the
following parameters to increase the deployment time:

- Parallelism, max batch size: Number of concurrent instances to roll out.
- Max surge: How many instances to add in addition of the current amount.
- Max unavailable: Number of unavailable instances during the rolling update
  procedure.

# In practice
```console
kubectl create namespace my-app
```
<pre>
namespace/my-app created
</pre>

Switching context to my-app namespace

```console
kubectl config set-context --current --namespace=my-app
```
<pre>
Context "***" modified.
</pre>


## Steps to follow

1. version 1 is serving traffic
1. deploy version 2
1. wait until all replicas are replaced with version 2

## In practice

### Deploy application service

```console
kubectl apply -f app-ramped-service.yaml -n my-app
```
<pre>
service/my-app-ram created
</pre>


### Deploy the first application

```console
kubectl apply -f app-ramped-deployment-v1.yaml --namespace=my-app
```
<pre>
deployment.apps/my-app-ram created
</pre>

### Test if the deployment was successful

```console
kubectl get service my-app-ram
```
<pre>
NAME         TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
my-app-ram   NodePort   10.0.224.199   <none>        80:31118/TCP   112s
</pre>


### To see the deployment in action, open a new terminal and run the following
### command

```console
kubectl get po --namespace=my-app -L app,version
```

<pre>
NAME                          READY   STATUS    RESTARTS   AGE     APP          VERSION
my-app-ram-5d4656d566-fjfrr   0/1     Running   0          105s    my-app-ram   v1.0.0
my-app-ram-5d4656d566-gljfw   0/1     Running   0          105s    my-app-ram   v1.0.0
my-app-ram-5d4656d566-gwv5g   0/1     Running   0          105s    my-app-ram   v1.0.0
my-app-ram-5d4656d566-nvtwf   0/1     Running   0          105s    my-app-ram   v1.0.0
my-app-ram-f49bfd697-4gg8m    1/1     Running   0          2m43s   my-app-ram   v1.0.0
my-app-ram-f49bfd697-8l9lf    1/1     Running   0          2m43s   my-app-ram   v1.0.0
my-app-ram-f49bfd697-h2zdx    1/1     Running   0          2m43s   my-app-ram   v1.0.0
my-app-ram-f49bfd697-jjfq5    1/1     Running   0          2m43s   my-app-ram   v1.0.0
my-app-ram-f49bfd697-vxc4b    1/1     Running   0          2m43s   my-app-ram   v1.0.0
my-app-ram-f49bfd697-zv574    1/1     Running   0          2m43s   my-app-ram   v1.0.0
</pre>


```console
kubectl port-forward svc/kubeview -n monitor 3030:3030
```
<pre>
Forwarding from 127.0.0.1:3030 -> 8000
Forwarding from [::1]:3030 -> 8000
Handling connection for 3030
</pre>
```console
kubectl port-forward svc/my-app-ram -n my-app 9998:80 
```
<pre>
Forwarding from 127.0.0.1:9998 -> 80
Forwarding from [::1]:9998 -> 80
</pre>

### Then deploy version 2 of the application

```console
kubectl apply -f app-ramped-deployment-v2.yaml --namespace=my-app
```


kubectl get po --namespace=my-app -L app,version
NAME                         READY   STATUS    RESTARTS   AGE     APP          VERSION
my-app-ram-9f4ddb54d-5grm6   1/1     Running   0          2m38s   my-app-ram   v1.0.0
my-app-ram-9f4ddb54d-7wm6p   1/1     Running   0          2m38s   my-app-ram   v1.0.0
my-app-ram-9f4ddb54d-8qm9c   1/1     Running   0          2m38s   my-app-ram   v1.0.0
my-app-ram-9f4ddb54d-d2pfb   1/1     Running   0          2m38s   my-app-ram   v1.0.0
my-app-ram-9f4ddb54d-g967k   1/1     Running   0          2m38s   my-app-ram   v1.0.0
my-app-ram-9f4ddb54d-sgn9h   1/1     Running   0          2m38s   my-app-ram   v1.0.0
my-app-ram-9f4ddb54d-snlhv   1/1     Running   0          2m38s   my-app-ram   v1.0.0
my-app-ram-9f4ddb54d-vfzkx   1/1     Running   0          2m38s   my-app-ram   v1.0.0
my-app-ram-dbbb4f984-zlfj8   0/1     Running   0          57s     my-app-ram   v2.0.0

```console
kubectl get po --namespace=my-app -L app,version
```
<pre>
NAME                         READY   STATUS        RESTARTS   AGE     APP          VERSION
my-app-ram-9f4ddb54d-5grm6   1/1     Running       0          2m52s   my-app-ram   v1.0.0
my-app-ram-9f4ddb54d-7wm6p   1/1     Running       0          2m52s   my-app-ram   v1.0.0
my-app-ram-9f4ddb54d-8qm9c   1/1     Running       0          2m52s   my-app-ram   v1.0.0
my-app-ram-9f4ddb54d-d2pfb   1/1     Running       0          2m52s   my-app-ram   v1.0.0
my-app-ram-9f4ddb54d-g967k   1/1     Running       0          2m52s   my-app-ram   v1.0.0
my-app-ram-9f4ddb54d-sgn9h   1/1     Running       0          2m52s   my-app-ram   v1.0.0
my-app-ram-9f4ddb54d-snlhv   0/1     Terminating   0          2m52s   my-app-ram   v1.0.0
my-app-ram-9f4ddb54d-vfzkx   1/1     Running       0          2m52s   my-app-ram   v1.0.0
my-app-ram-dbbb4f984-86xqv   0/1     Running       0          4s      my-app-ram   v2.0.0
my-app-ram-dbbb4f984-zlfj8   1/1     Running       0          71s     my-app-ram   v2.0.0
</pre>

```console
kubectl get po --namespace=my-app -L app,version
```
<pre>
NAME                         READY   STATUS    RESTARTS   AGE     APP          VERSION
my-app-ram-dbbb4f984-86xqv   1/1     Running   0          13m     my-app-ram   v2.0.0
my-app-ram-dbbb4f984-9znrq   1/1     Running   0          6m34s   my-app-ram   v2.0.0
my-app-ram-dbbb4f984-g5bq5   1/1     Running   0          9m48s   my-app-ram   v2.0.0
my-app-ram-dbbb4f984-kzg9q   1/1     Running   0          12m     my-app-ram   v2.0.0
my-app-ram-dbbb4f984-nq6rn   1/1     Running   0          10m     my-app-ram   v2.0.0
my-app-ram-dbbb4f984-qcclf   1/1     Running   0          7m37s   my-app-ram   v2.0.0
my-app-ram-dbbb4f984-r5l2b   1/1     Running   0          8m44s   my-app-ram   v2.0.0
my-app-ram-dbbb4f984-zlfj8   1/1     Running   0          14m     my-app-ram   v2.0.0

</pre>

```
kubectl rollout status deploy/my-app-ram
```
<pre>
deployment "my-app-ram" successfully rolled out
</pre>

### In case you discover some issue with the new version, you can undo the
### rollout
```console
kubectl rollout undo deploy my-app-ram
```
<pre>
deployment.extensions/my-app-ram rolled back
</pre>


### If you can also pause the rollout if you want to run the application for a
### subset of users

```console
kubectl rollout pause deploy my-app-ram
```

### Then if you are satisfy with the result, rollout

```console
kubectl rollout resume deploy my-app-ram
```

### Cleanup

```console
kubectl delete all -l app=my-app-ram
```

Testing version during rolling update
```console
kubectl run curl-$RANDOM --image=radial/busyboxplus:curl --namespace=my-app \
  --labels app=words-web --rm -it  \
  --generator=run-pod/v1
```

Inside the pod
```console
while true; do curl -v -X Get http://my-app-ram:80; done
```

#### Filter in Grafana

```console
kubectl port-forward svc/mygrafana -n monitor 4444:4444
```
<pre>
Forwarding from 127.0.0.1:4444 -> 3000
Forwarding from [::1]:4444 -> 3000
Handling connection for 4444
</pre>

```console
sum(kube_pod_labels{label_app="my-app-ram",namespace="my-app"}) by (label_app,label_version)
```
