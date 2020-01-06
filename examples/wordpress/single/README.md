Installing single pod with wordpress application

```console
kubectl apply -f wordpress-namespace.yaml 
```
<pre>
namespace/wordpress-single created
</pre>

```console
kubectl config set-context --current --namespace wordpress-single
```
<pre>
Context "***" modified.
</pre>
```console
kubectl apply -f wordpress-deployment.yaml  -n wordpress-single
```
<pre>
deployment.extensions/wordpress-single created
</pre>
```console
kubectl apply -f wordpress-service.yaml -n wordpress-single
```
<pre>
service/wordpress-single created
</pre>
```console
kubectl get all -n wordpress-single
```
<pre>
NAME                                   READY   STATUS    RESTARTS   AGE
pod/wordpress-single-66b6899dc-4znb4   2/2     Running   1          112s

NAME                       TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
service/wordpress-single   ClusterIP   10.0.95.151   <none>        80/TCP    74s

NAME                               READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/wordpress-single   1/1     1            1           113s

NAME                                         DESIRED   CURRENT   READY   AGE
replicaset.apps/wordpress-single-66b6899dc   1         1         1       113s
</pre>

```console
kubectl port-forward service/wordpress-single 8989:80
```
<pre>
Forwarding from 127.0.0.1:8989 -> 80
Forwarding from [::1]:8989 -> 80
</pre>

Let's look what we have inside

Wordpress-single pod has two containers.

```console
POD_NAME=$(kubectl get pods -l app=wordpress-single -n wordpress-single -o jsonpath={.items[0].metadata.name})
echo $POD_NAME
```
<pre>
wordpress-single-66b6899dc-4znb4
</pre>

kubectl exec $POD_NAME -c wordpress  ls

kubectl exec $POD_NAME -c mysql  ls

kubectl exec -it $POD_NAME -c wordpress  -- bash
<pre>
whoami
exit
</pre>

kubectl exec -it $POD_NAME -c mysql  -- bash
<pre>
whoami
exit
</pre>

