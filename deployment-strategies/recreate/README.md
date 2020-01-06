Recreate deployment
===================

> Version A is terminated then version B is rolled out.

![kubernetes recreate deployment](grafana-recreate.png)

## In practice
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


### Deploy service for application

```console
kubectl apply -f app-recreate-service.yaml -n my-app
```

<pre>
service/my-app-re created
</pre>



### Deploy version 1 of the application

```console
kubectl apply -f app-recreate-deployment-v1.yaml  --namespace=my-app
```
<pre>
deployment.apps/my-app-re created
</pre>


#### List all pods

```console
kubectl get pods -n my-app -l app=my-app-re -L app,version
```

<pre>
NAME                         READY   STATUS    RESTARTS   AGE   APP         VERSION
my-app-re-7bcbc6db85-2d8vf   1/1     Running   0          45s   my-app-re   v1.0.0
my-app-re-7bcbc6db85-4pl4n   1/1     Running   0          46s   my-app-re   v1.0.0
my-app-re-7bcbc6db85-7hbjn   1/1     Running   0          46s   my-app-re   v1.0.0
my-app-re-7bcbc6db85-8rj4n   1/1     Running   0          46s   my-app-re   v1.0.0
my-app-re-7bcbc6db85-j8hzz   1/1     Running   0          46s   my-app-re   v1.0.0
my-app-re-7bcbc6db85-swfk8   1/1     Running   0          46s   my-app-re   v1.0.0
my-app-re-7bcbc6db85-v644t   1/1     Running   0          46s   my-app-re   v1.0.0
my-app-re-7bcbc6db85-v6pwv   1/1     Running   0          46s   my-app-re   v1.0.0
</pre>

####  Kubeview
```console
kubectl port-forward svc/kubeview -n monitor 3030:3030
```
<pre>
Forwarding from 127.0.0.1:3030 -> 8000
Forwarding from [::1]:3030 -> 8000
Handling connection for 3030     
</pre>

Browse at http://localhost:3030

```console
kubectl port-forward svc/my-app-re 9997:80
```
<pre>
Forwarding from 127.0.0.1:9997 -> 80
Forwarding from [::1]:9997 -> 80
</pre>

Browse at http://localhost:9997

### Then deploy version 2 of the application

```console
kubectl apply -f app-recreate-deployment-v2.yaml --namespace=my-app
```
<pre>
deployment.apps/my-app-re configured
</pre>

#### List all pods

```console
kubectl get pods -n my-app -l app=my-app-re -L app,version
```

<pre>
NAME                         READY   STATUS    RESTARTS   AGE   APP         VERSION
my-app-re-558885fb89-2ws86   0/1     Running   0          9s    my-app-re   v2.0.0
my-app-re-558885fb89-429gb   0/1     Running   0          9s    my-app-re   v2.0.0
my-app-re-558885fb89-lprmr   0/1     Running   0          9s    my-app-re   v2.0.0
my-app-re-558885fb89-nhqw5   0/1     Running   0          9s    my-app-re   v2.0.0
my-app-re-558885fb89-sqgjq   0/1     Running   0          9s    my-app-re   v2.0.0
my-app-re-558885fb89-t7f84   0/1     Running   0          9s    my-app-re   v2.0.0
my-app-re-558885fb89-x6qwp   0/1     Running   0          9s    my-app-re   v2.0.0
my-app-re-558885fb89-zr29x   0/1     Running   0          9s    my-app-re   v2.0.0
</pre>

#### Delete deployment

```console
kubectl delete deployment/my-app-re --namespace=my-app
```

#### Filter in Grafana

```console
sum(kube_pod_labels{label_app="my-app-re",namespace="my-app"}) by (label_app,label_version)
```