#### Imagine that you have simple two nodes cluster
```console
kubectl get nodes
```
<pre>
NAME                       STATUS   ROLES   AGE   VERSION
aks-nodepool1-16191604-0   Ready    agent   32d   v1.14.5
aks-nodepool1-16191604-1   Ready    agent   32d   v1.14.5
</pre>


Let's  apply our deployment.


At the beginning create new namespace for failure tests.

```console
kubectl create namespace failure
```

<pre>
namespace/failure created
</pre>

```console
kubectl apply -f my-failure-app-deployment.yaml -n failure
```

<pre>
deployment.apps/my-failure-app created
</pre>

```console
kubectl get all -n failure
```

<pre>
NAME                                  READY   STATUS    RESTARTS   AGE
pod/my-failure-app-5b784b5746-2nsmd   1/1     Running   0          2m1s
pod/my-failure-app-5b784b5746-sm2qm   1/1     Running   0          2m1s

NAME                             READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/my-failure-app   2/2     2            2           2m1s

NAME                                        DESIRED   CURRENT   READY   AGE
replicaset.apps/my-failure-app-5b784b5746   2         2         2       2m1s
</pre>

Now we would like to know on what nodes are deployed our pods

Let's try with filtering our pods in dedicated failure namespace

```console
kubectl get pods -l app=my-failure-app -n failure
```
<pre>
NAME                              READY   STATUS    RESTARTS   AGE
my-failure-app-5b784b5746-2nsmd   1/1     Running   0          3m25s
my-failure-app-5b784b5746-sm2qm   1/1     Running   0          3m25s
</pre>

```console
kubectl get pods -l app=my-failure-app -n failure -o wide
```
<pre>
NAME                              READY   STATUS    RESTARTS   AGE     IP            NODE                       NOMINATED NODE   READINESS GATES
my-failure-app-5b784b5746-2nsmd   1/1     Running   0          5m33s   10.244.1.52   aks-nodepool1-16191604-0   <none>
        <none>
my-failure-app-5b784b5746-sm2qm   1/1     Running   0          5m33s   10.244.1.51   aks-nodepool1-16191604-0   <none>
        <none>
</pre>

Here I have both pods on the same node. Let's shutdown the node-0.
Stop the corresponding VM aks-nodepool1-16191604-0.
<pre>
Stopping virtual machine 'aks-nodepool1-16191604-0'...
...

</pre>

After few minutes

```console
kubectl get nodes
```

<pre>
NAME                       STATUS     ROLES   AGE   VERSION
aks-nodepool1-16191604-0   NotReady   agent   32d   v1.14.5
aks-nodepool1-16191604-1   Ready      agent   32d   v1.14.5
</pre>

```console
kubectl get pods -l app=my-failure-app -n failure -o wide
```

<pre>
NAME                              READY   STATUS    RESTARTS   AGE   IP            NODE                       NOMINATED NODE   READINESS GATES
my-failure-app-5b784b5746-2nsmd   1/1     Running   0          14m   10.244.1.52   aks-nodepool1-16191604-0   <none>           <none>
my-failure-app-5b784b5746-sm2qm   1/1     Running   0          14m   10.244.1.51   aks-nodepool1-16191604-0   <none>           <none>
</pre>

Kubernetes still doesnt know that pods node aks-nodepool1-16191604-0 are out of service

After few minutes
<pre>
NAME                              READY   STATUS        RESTARTS   AGE   IP            NODE                       NOMINATED NODE   READINESS GATES
my-failure-app-5b784b5746-2nsmd   1/1     Terminating   0          17m   10.244.1.52   aks-nodepool1-16191604-0   <none>           <none>
my-failure-app-5b784b5746-7jrdw   1/1     Running       0          46s   10.244.0.53   aks-nodepool1-16191604-1   <none>           <none>
my-failure-app-5b784b5746-sm2qm   1/1     Terminating   0          17m   10.244.1.51   aks-nodepool1-16191604-0   <none>           <none>
my-failure-app-5b784b5746-twc45   1/1     Running       0          46s   10.244.0.52   aks-nodepool1-16191604-1   <none>           <none>
</pre>

Look at new running pods on ks-nodepool1-16191604-1 node.

The old instances on node aks-nodepool1-16191604-0 are  terminating .... terminating ... forever. Why ?


Now turn on aks-nodepool1-16191604-0 VM.
<pre>
Starting virtual machine 'aks-nodepool1-16191604-0'...
</pre>

```console
kubectl get nodes
```

<pre>
NAME                       STATUS   ROLES   AGE   VERSION
aks-nodepool1-16191604-0   Ready    agent   32d   v1.14.5
aks-nodepool1-16191604-1   Ready    agent   32d   v1.14.5
</pre>

```console
kubectl get pods -l app=my-failure-app -n failure -o wide
```

<pre>
NAME                              READY   STATUS    RESTARTS   AGE     IP            NODE                       NOMINATED NODE   READINESS GATES
my-failure-app-5b784b5746-7jrdw   1/1     Running   0          7m37s   10.244.0.53   aks-nodepool1-16191604-1   <none>           <none>
my-failure-app-5b784b5746-twc45   1/1     Running   0          7m37s   10.244.0.52   aks-nodepool1-16191604-1   <none>           <none>
</pre>

Our terminating pods are missing, Why ?