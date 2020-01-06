Blue/green deployment to release a single service
=================================================

> In this example, we release a new version of a single service using the
blue/green deployment strategy.

![kubernetes ramped deployment](grafana-bluegreen.png)

## Steps to follow

1. version 1 is serving traffic
1. deploy version 2
1. wait until version 2 is ready
1. switch incoming traffic from version 1 to version 2
1. shutdown version 1

## In practice

### Deploy the first application

Service part

```console

```
<pre>
service/my-app-bg created
</pre>

Deployment part

```cosnsole
 kubectl apply -f app-bluegreen-deployment-v1.yaml --namespace=my-app

```
<pre>
deployment.apps/my-app-bg-v1 created
</pre>


### Test if the deployment was successful
```console
kubectl get all --namespace=my-app
```
<pre>
NAME                TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
service/my-app-bg   NodePort   10.0.215.117   <none>        80:30750/TCP   15s

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/my-app-bg-v1   5/5     5            5           103s

NAME                                      DESIRED   CURRENT   READY   AGE
replicaset.apps/my-app-bg-v1-6966fcdbcc   5         5         5       103s
</pre>

```console
kubectl get pods -L app,version -n my-app
```
<pre>
NAME                            READY   STATUS    RESTARTS   AGE     APP         VERSION  
my-app-bg-v1-6966fcdbcc-2plj8   1/1     Running   0          2m54s   my-app-bg   v1.0.0
my-app-bg-v1-6966fcdbcc-4t4qk   1/1     Running   0          2m54s   my-app-bg   v1.0.0
my-app-bg-v1-6966fcdbcc-k5fz4   1/1     Running   0          2m54s   my-app-bg   v1.0.0
my-app-bg-v1-6966fcdbcc-th2bg   1/1     Running   0          2m54s   my-app-bg   v1.0.0
my-app-bg-v1-6966fcdbcc-tk8kz   1/1     Running   0          2m54s   my-app-bg   v1.0.0
</pre>

### To see the deployment in action, open a new terminal and run the following
### command:

```console
kubectl get po  --namespace=my-app -w
```

```
kubectl port-forward svc/kubeview -n monitor 3030:3030
```
<pre>
Forwarding from 127.0.0.1:3030 -> 8000
Forwarding from [::1]:3030 -> 8000
Handling connection for 3030
</pre>


### Then deploy version 2 of the application

```console
kubectl apply -f app-bluegreen-deployment-v2.yaml --namespace=my-app
```
<pre>
deployment.apps/my-app-bg-v2 created
</pre>

### Wait for all the version 2 pods to be running

```console
kubectl rollout status deploy my-app-bg-v2 --namespace=my-app
```
<pre>
Waiting for deployment "my-app-bg-v2" rollout to finish: 1 of 5 updated replicas are available...
Waiting for deployment "my-app-bg-v2" rollout to finish: 2 of 5 updated replicas are available...
Waiting for deployment "my-app-bg-v2" rollout to finish: 3 of 5 updated replicas are available...
Waiting for deployment "my-app-bg-v2" rollout to finish: 4 of 5 updated replicas are available...
deployment "my-app-bg-v2" successfully rolled out
</pre>


### Side by side, x pods are running with version 2 but the service still send
### traffic to the first deployment.

If necessary, you can manually test one of the pod by port-forwarding it to
your local environment.

```console
kubectl get services my-app-bg --namespace=my-app

kubectl describe services my-app-bg --namespace=my-app

```
Forward service port to http://localhost:9999
```console
kubectl port-forward service/my-app-bg --namespace=my-app 9999:80
```

Once your are ready, you can switch the traffic to the new version by patching
the service to send traffic to all pods with label version=v2.0.0

```console
kubectl patch service my-app-bg -p '{"spec":{"selector":{"version":"v2.0.0"}}}'
```
<pre>
service/my-app-bg patched
</pre>

### Test if the second deployment was successful

```console
service=http://localhost:9999/
while sleep 0.1; do curl "$service"; done
```

### In case you need to rollback to the previous version

```console
kubectl patch service my-app-bg -p '{"spec":{"selector":{"version":"v1.0.0"}}}'
```
<pre>
service/my-app-bg patched
</pre>

We can also change service selector from yaml file
```console
kubectl apply -f app-bluegreen-service-v2.yaml  -n my-app
```
<pre>
service/my-app-bg configured
</pre>


You can also check the same inside the temporary pod
```console
kubectl run myubuntu --image ubuntu:16.04 --rm -ti --generator=run-pod/v1
kubectl run myubuntu --image ubuntu:16.04 --rm -ti --generator=deployment/apps.v1
kubectl run myubuntu --image ubuntu:16.04 --rm -ti --generator=run-pod/v1 \
  --requests "cpu=50m,memory=50Mi" --limits="cpu=100m,memory=100Mi"
```
> apt-get update
>
> apt-get install curl
>
> service=http://my-app-bg:80/
>
> while sleep 0.1; do curl "$service"; done

### If everything is working as expected, you can then delete the v1.0.0
### deployment

```console
kubectl delete deploy my-app-bg-v1
```

### Cleanup

```console
kubectl delete all -l app=my-app-bg
```




#### Filter in Grafana
```console
sum(kube_pod_labels{label_app="my-app-bg", namespace="my-app"}) by (label_app,label_version)
```