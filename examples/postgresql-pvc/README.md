##### repo for application https://github.com/xcoulon/go-url-shortener

```console
kubectl create namespace postgres-app
```
<pre>

</pre>

```console
kubectl apply -f ./postgres-deployment.yaml --namespace=postgres-app
```
<pre>
deployment.apps/postgres created
</pre>

```console
kubectl get all --namespace=postgres-app
```

<pre>
NAME                           READY   STATUS    RESTARTS   AGE
pod/postgres-cd7d5b497-jhjtv   1/1     Running   0          59s

NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/postgres   1/1     1            1           61s

NAME                                 DESIRED   CURRENT   READY   AGE
replicaset.apps/postgres-cd7d5b497   1         1         1       61s
</pre>

```console
POSTGRES_POD=$(
kubectl get pods --namespace=postgres-app -l app=postgres -o jsonpath={.items[0].metadata.name})
echo $POSTGRES_POD

kubectl exec -it $POSTGRES_POD bash --namespace=postgres-app
```
<pre>
NAME                       READY   STATUS    RESTARTS   AGE
postgres-cd7d5b497-jhjtv   1/1     Running   0          8m10s
</pre>

<pre>
psql -U user -d url_shortener_db
psql (9.6.5)
Type "help" for help.

url_shortener_db=#
\q
exit
</pre>

```console
kubectl apply -f postgres-service.yaml --namespace=postgres-app
```
<pre>
service/postgres created
</pre>
```console
kubectl get services  --namespace=postgres-app
```
<pre>
NAME       TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE
postgres   ClusterIP   10.0.54.35   <none>        5432/TCP   18s
</pre>

```console
kubectl apply -f webapp-deployment.yaml --namespace=postgres-app
```
<pre>
deployment.apps/webapp created
</pre>

```console
kubectl get all -l app=webapp --namespace=postgres-app
```

<pre>
NAME                          READY   STATUS    RESTARTS   AGE
pod/webapp-586ff7cfcd-bz8gd   1/1     Running   0          2m5s

NAME                     READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/webapp   1/1     1            1           2m6s

NAME                                DESIRED   CURRENT   READY   AGE
replicaset.apps/webapp-586ff7cfcd   1         1         1       2m6s
</pre>

WEBAPP_POD=$(
kubectl get pods --namespace=postgres-app -l app=webapp -o jsonpath={.items[0].metadata.name})
echo $WEBAPP_POD

kubectl logs $WEBAPP_POD --namespace=postgres-app

<pre>
time="2019-08-06T18:15:56Z" level=info msg="Connecting to Postgres database using: host=`postgres:5432` dbname=`url_shortener_db` username=`user`\n"
time="2019-08-06T18:15:56Z" level=info msg="Adding the 'uuid-ossp' extension..."

   ____    __
  / __/___/ /  ___
 / _// __/ _ \/ _ \
/___/\__/_//_/\___/ v3.2.1
High performance, minimalist Go web framework
https://echo.labstack.com
____________________________________O/_______
                                    O\
⇨ http server started on [::]:8080
</pre>
```console
kubectl apply -f webapp-service.yaml --namespace=postgres-app
```

<pre>
service/webapp created
</pre>

```console
kubectl get services -o wide  --namespace=postgres-app
```
<pre>
NAME       TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)          AGE   SELECTOR
postgres   ClusterIP   10.0.54.35   <none>        5432/TCP         10m   app=postgres
webapp     NodePort    10.0.48.34   <none>        8080:31317/TCP   97s   app=webapp
</pre>
```console
kubectl port-forward service/webapp 8080:8080 --namespace=postgres-app
```

curl -X POST http://localhost:8080/ -d "full_url=https://redhat.com"
curl -X POST http://localhost:8080/ -d "full_url=https://portal.azure.com"
curl -X POST http://localhost:8080/ -d "full_url=https://www.whitehouse.gov"

<pre>
vtwo17O
HF8sL7e
8HpiBPW
</pre>

curl -X GET http://localhost:8080/vtwo17O -v
curl -X GET http://localhost:8080/HF8sL7e -v
curl -X GET http:/localhost:8080/8HpiBPW -v

<pre>
...
< HTTP/1.1 307 Temporary Redirect
< Location: https://redhat.com
< Date: Tue, 06 Aug 2019 19:40:43 GMT
< Content-Length: 0
< Content-Type: text/plain; charset=utf-8
...
 HTTP/1.1 307 Temporary Redirect
< Location: https://portal.azure.com
< Date: Tue, 06 Aug 2019 19:40:59 GMT
< Content-Length: 0
< Content-Type: text/plain; charset=utf-8
...
< HTTP/1.1 307 Temporary Redirect
< Location: https://www.whitehouse.gov
< Date: Tue, 06 Aug 2019 19:41:09 GMT
< Content-Length: 0
< Content-Type: text/plain; charset=utf-8
...
</pre>


#### Creating secret

#### hashing -> base64

```console
echo -n "url_shortener_db" | base64 -
```
<pre>
dXJsX3Nob3J0ZW5lcl9kYg==
</pre>
```console
echo -n "user" | base64 -
```
<pre>
dXNlcg==
</pre>

```console
echo -n "mysecretpassword" | base64 -
```
<pre>
bXlzZWNyZXRwYXNzd29yZA==
</pre>

```console
kubectl create -f database-secrets.yaml --namespace=postgres-app
```
<pre>
secret/database-secret-config created
</pre>

kubectl get secret database-secret-config  --namespace=postgres-app

<pre>
NAME                     TYPE     DATA   AGE
database-secret-config   Opaque   3      10s
</pre>

```console
kubectl describe secret database-secret-config  --namespace=postgres-app
```

<pre>
Name:         database-secret-config
Namespace:    postgres-app
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
password:  16 bytes
username:  4 bytes
dbname:    16 bytes

</pre>


```console
kubectl apply -f postgres-secret-deployment.yaml --namespace=postgres-app
```

<pre>
deployment.apps/postgres configured
</pre>

```console
kubectl get all --namespace=postgres-app
```

<pre>
NAME                            READY   STATUS    RESTARTS   AGE
pod/postgres-676579b6cd-k4l8c   1/1     Running   0          65s
pod/webapp-586ff7cfcd-bz8gd     1/1     Running   0          100m

NAME               TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)          AGE
service/postgres   ClusterIP   10.0.54.35   <none>        5432/TCP         103m
service/webapp     NodePort    10.0.48.34   <none>        8080:31317/TCP   94m

NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/postgres   1/1     1            1           121m
deployment.apps/webapp     1/1     1            1           100m

NAME                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/postgres-676579b6cd   1         1         1       65s
replicaset.apps/postgres-cd7d5b497    0         0         0       121m
replicaset.apps/webapp-586ff7cfcd     1         1         1       100m
</pre>





```console
POSTGRES_POD=$(
kubectl get pods --namespace=postgres-app -l app=postgres -o jsonpath={.items[0].metadata.name})
echo $POSTGRES_POD

kubectl exec -it $POSTGRES_POD bash --namespace=postgres-app
```
<pre>
psql -U user -d url_shortener_db

psql (9.6.5)
Type "help" for help.

select datname,encoding from pg_databases;

\q

exit
</pre>



```console
kubectl create configmap app-config --from-file=./config.yaml  --namespace=postgres-app
```

<pre>
configmap/app-config created
</pre>

```console
kubectl describe cm app-config --namespace=postgres-app
```

<pre>
Name:         app-config
Namespace:    postgres-app
Labels:       <none>
Annotations:  <none>

Data
====
config.yaml:
----
level: info
Events:  <none>
</pre>

```console
kubectl apply -f webapp-configmap-deployment.yaml --namespace=postgres-app
```
<pre>
deployment.apps/webapp configured
</pre>

```console
kubectl get all --namespace=postgres-app
```
<pre>
NAME                            READY   STATUS    RESTARTS   AGE
pod/postgres-676579b6cd-k4l8c   1/1     Running   0          14m
pod/webapp-5bdbc4bffb-4n84q     1/1     Running   0          91s

NAME               TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)          AGE
service/postgres   ClusterIP   10.0.54.35   <none>        5432/TCP         117m
service/webapp     NodePort    10.0.48.34   <none>        8080:31317/TCP   107m

NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/postgres   1/1     1            1           134m
deployment.apps/webapp     1/1     1            1           114m

NAME                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/postgres-676579b6cd   1         1         1       14m
replicaset.apps/postgres-cd7d5b497    0         0         0       134m
replicaset.apps/webapp-586ff7cfcd     0         0         0       114m
replicaset.apps/webapp-5bdbc4bffb     1         1         1       93s
</pre>


```console
WEBAPP_POD=$(
kubectl get pods --namespace=postgres-app -l app=webapp -o jsonpath={.items[0].metadata.name})
echo $WEBAPP_POD
kubectl exec -it $WEBAPP_POD bash  --namespace=postgres-app
kubectl logs $WEBAPP_POD --namespace=postgres-app

```
<pre>

cat /etc/config/config.yaml

level: info
...
time="2019-08-06T20:08:35Z" level=warning msg="loading config" path=/etc/config/config.yaml
time="2019-08-06T20:08:35Z" level=warning msg="setting log level" level=info
time="2019-08-06T20:08:35Z" level=info msg="Connecting to Postgres database using: host=`postgres:5432` dbname=`url_shortener_db` username=`user`"
</pre>

```console
kubectl apply -f database-storage.yaml --namespace=postgres-app
```

<pre>
persistentvolume/postgres-pv created
persistentvolumeclaim/postgres-pv-claim create
</pre>

```console
kubectl get pv postgres-pv  --namespace=postgres-app
kubectl get pvc postgres-pv-claim --namespace=postgres-app
```


<pre>
NAME          CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                            STORAGECLASS
 REASON   AGE
postgres-pv   100M       RWO            Retain           Bound    postgres-app/postgres-pv-claim   manual
          119s
NAME                STATUS   VOLUME        CAPACITY   ACCESS MODES   STORAGECLASS   AGE
postgres-pv-claim   Bound    postgres-pv   100M       RWO            manual         119s
</pre>


```console
kubectl apply -f postgres-secret-pvc-deployment.yaml --namespace=postgres-app
```

<pre>
deployment.apps/postgres configured
</pre>


kubectl get pods --namespace=postgres-app

NAME                        READY   STATUS    RESTARTS   AGE
postgres-69867dc454-qn6hf   1/1     Running   0          97s
webapp-5bdbc4bffb-4n84q     1/1     Running   0          14m

```console
POSTGRES_POD=$(
kubectl get pods --namespace=postgres-app -l app=postgres -o jsonpath={.items[0].metadata.name})
echo $POSTGRES_POD
kubectl describe pod $POSTGRES_POD --namespace=postgres-app | grep Volumes: -A4
```

<pre>
Volumes:
  postgres-pv-claim:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  postgres-pv-claim
    ReadOnly:   false
</pre>

#### restart pod with webapp by deleting it

kubectl delete pod/webapp-5bdbc4bffb-4n84q --namespace=postgres-app


###### forward port 
kubectl port-forward service/webapp 8080:8080 --namespace=postgres-app

#### after a while

curl -X POST http://localhost:8080/ -d "full_url=https://redhat.com"
curl -X POST http://localhost:8080/ -d "full_url=https://portal.azure.com"
curl -X POST http://localhost:8080/ -d "full_url=https://www.whitehouse.gov"

<pre>
ngDJXOj
RTdkAmi
5RbGPQ2
</pre>

### connect to postgres to see table in database

```console
POSTGRES_POD=$(
kubectl get pods --namespace=postgres-app -l app=postgres -o jsonpath={.items[0].metadata.name})
echo $POSTGRES_POD
kubectl exec -it $POSTGRES_POD bash  --namespace=postgres-app
```
<pre>
# psql -U user -d url_shortener_db
psql (9.6.5)
Type "help" for help.

url_shortener_db=# select id,short_url,long_url from urls ;
                  id                  | short_url |          long_url
--------------------------------------+-----------+----------------------------
 1393fda2-a2a6-4016-9e1f-f7a804c946b5 | ngDJXOj   | https://redhat.com
 fa6565b9-78ed-4c08-8098-1f70a9f72524 | RTdkAmi   | https://portal.azure.com
 138d903a-edbb-4da0-8fe6-de08cdacd4c2 | 5RbGPQ2   | https://www.whitehouse.gov
(3 rows)

\q

exit
 </pre>

 #### now we can delete and restart our application.