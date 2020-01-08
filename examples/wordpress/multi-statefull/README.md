Installing wordpress in multi pods

Database part in statefull version

Lets create wordpress-multi namespace

```console
kubectl apply -f wordpress-namespace.yaml
```
<pre>
namespace/wordpress-multi created
</pre>

```console
kubectl config set-context --current --namespace=wordpress-multi
```
<pre>
Context "***" modified.
</pre>

Lets create configmap with database user and password

```console
kubectl apply -f wordpress-configmap.yaml -n wordpress-multi
```
<pre>
configmap/wordpress-multi-config created
</pre>

Create storage for mysql database

```console
kubectl apply -f mysql-volume.yaml  -n wordpress-multi
```
<pre>
persistentvolume/mysql-pv-volume created
persistentvolumeclaim/mysql-pv-claim created
</pre>

Install deployment with mysql database

```console
kubectl apply -f mysql-deployment.yaml -n wordpress-multi
```
<pre>
deployment.extensions/wordpress-multi-mysql created
</pre>

Install service for mysql pods

```console
kubectl apply -f mysql-service.yaml -n wordpress-multi
```
<pre>
service/wordpress-multi-mysql-service created
</pre>

```console
kubectl get pod,svc,rs,deploy,cm -n wordpress-multi
```
<pre>
NAME                                         READY   STATUS    RESTARTS   AGE
pod/wordpress-multi-mysql-8449c8c4c9-8hz7c   1/1     Running   0          2m11s

NAME                                    TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)    AGE
service/wordpress-multi-mysql-service   ClusterIP   10.0.69.126   <none>        3306/TCP   92s

NAME                                                     DESIRED   CURRENT   READY   AGE
replicaset.extensions/wordpress-multi-mysql-8449c8c4c9   1         1         1       2m12s

NAME                                          READY   UP-TO-DATE   AVAILABLE   AGE
deployment.extensions/wordpress-multi-mysql   1/1     1            1           2m12s

NAME                               DATA   AGE
configmap/wordpress-multi-config   3      2m41s

</pre>


It's time for apache and php deployment

```console
kubectl apply -f wordpress-deployment.yaml -n wordpress-multi
```
<pre>
deployment.extensions/wordpress-multi created
</pre>

And service for frontend

```console
kubectl apply -f wordpress-service.yaml -n wordpress-multi
```
<pre>
service/wordpress-multi-service created
</pre>

```console
kubectl get svc -n wordpress-multi
```
<pre>
NAME                            TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)    AGE  
wordpress-multi-mysql-service   ClusterIP   10.0.69.126   <none>        3306/TCP   11m  
wordpress-multi-service         ClusterIP   10.0.247.48   <none>        80/TCP     4m27s
</pre>

kubectl port-forward svc/wordpress-multi-service 9999:80

Forwarding from 127.0.0.1:9999 -> 80
Forwarding from [::1]:9999 -> 80

Browse at http://localhost:9999

```console
kubectl scale deployment/wordpress-multi --replicas=3
```
<pre>
deployment.extensions/wordpress-multi scaled
</pre>

Literature:

https://www.serverlab.ca/tutorials/containers/kubernetes/deploy-phpmyadmin-to-kubernetes-to-manage-mysql-pods/
