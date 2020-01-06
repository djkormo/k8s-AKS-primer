Blue/green deployment to release multiple services simultaneously
=================================================================



## Steps to follow

1. service a and b are serving traffic
1. deploy new version of both services
1. wait for all services to be ready
1. switch incoming traffic from version 1 to version 2
1. shutdown version 1

## In practice


Deploy 1 version and application A and B 

```console
kubectl apply -f app-a-deployment-v1.yaml -f app-b-deployment-v1.yaml -n my-app
```
<pre>
deployment.apps/my-app-a-v1 created
deployment.apps/my-app-b-v1 created
</pre>

```console
kubectl apply -f app-a-service-v1.yaml -f app-b-service-v1.yaml -n my-app
```
<pre>
service/my-app-a-v1 created
service/my-app-b-v1 created
</pre>

```console
kubectl port-forward svc/kubeview -n monitor 3030:3030
```
<pre>
Forwarding from 127.0.0.1:3030 -> 8000
Forwarding from [::1]:3030 -> 8000
Handling connection for 3030
</pre>

Deploy 2 version and application A and B 

```console
kubectl apply -f app-a-deployment-v2.yaml -f app-b-deployment-v2.yaml -n my-app
```
<pre>
deployment.apps/my-app-a-v2 created
deployment.apps/my-app-b-v2 created
</pre>

```console
kubectl apply -f app-a-service-v2.yaml -f app-b-service-v2.yaml -n my-app
```
<pre>
service/my-app-a-v2 created
service/my-app-b-v2 created
</pre>

```console
kubectl get pods -n my-app -L app,version
```
<pre>
NAME                           READY   STATUS    RESTARTS   AGE     APP        VERSION
my-app-a-v1-69db8b5bd6-bslm2   1/1     Running   0          11m     my-app-a   v1.0.0
my-app-a-v1-69db8b5bd6-j4cq5   1/1     Running   0          11m     my-app-a   v1.0.0
my-app-a-v1-69db8b5bd6-jpmdt   1/1     Running   0          11m     my-app-a   v1.0.0
my-app-a-v2-5d9bdbcb6d-9mqbp   1/1     Running   0          4m38s   my-app-a   v2.0.0
my-app-a-v2-5d9bdbcb6d-pbqgf   1/1     Running   0          4m38s   my-app-a   v2.0.0
my-app-a-v2-5d9bdbcb6d-sb4mf   1/1     Running   0          4m38s   my-app-a   v2.0.0
my-app-b-v1-66fdb77768-cjdnq   1/1     Running   0          11m     my-app-b   v1.0.0
my-app-b-v1-66fdb77768-fvkvw   1/1     Running   0          11m     my-app-b   v1.0.0
my-app-b-v1-66fdb77768-prlxn   1/1     Running   0          11m     my-app-b   v1.0.0
my-app-b-v2-698bf66c78-d4rd9   1/1     Running   0          4m38s   my-app-b   v2.0.0
my-app-b-v2-698bf66c78-ph96m   1/1     Running   0          4m38s   my-app-b   v2.0.0
my-app-b-v2-698bf66c78-v4hgd   1/1     Running   0          4m38s   my-app-b   v2.0.0
</pre>

Creating ingress object  for splitting traffic between a.domain.com and b.domain.com
```console
kubectl apply -f ingress-v1.yaml 
```

<pre>
ingress.extensions/my-app configured
</pre>

```console
kubectl describe Ingress
```
<pre>
Name:             my-app
Namespace:        my-app
Address:
Default backend:  default-http-backend:80 (<none>)
Rules:
  Host          Path  Backends
  ----          ----  --------
  a.domain.com
                   my-app-a-v1:80 (10.240.0.14:80,10.240.0.45:80,10.240.0.58:80)
  b.domain.com
                   my-app-b-v1:80 (10.240.0.27:80,10.240.0.47:80,10.240.0.63:80)
Annotations:
  kubectl.kubernetes.io/last-applied-configuration:  {"apiVersion":"extensions/v1beta1","kind":"Ingress","metadata":{"annotations":{"kubernetes.io/ingress.class":"nginx"},"labels":{"app":"my-app"},"name":"my-app","namespace":"my-app"},"spec":{"rules":[{"host":"a.domain.com","http":{"paths":[{"backend":{"serviceName":"my-app-a-v1","servicePort":80}}]}},{"host":"b.domain.com","http":{"paths":[{"backend":{"serviceName":"my-app-b-v1","servicePort":80}}]}}]}}

  kubernetes.io/ingress.class:  nginx
</pre>


### Test if the deployment was successful

```console
kubectl get svc --namespace ingress -l app=nginx-ingress
```
<pre>
NAME                                      TYPE           CLUSTER-IP    EXTERNAL-IP     PORT(S)                      AGE
myingress-nginx-ingress-controller        LoadBalancer   10.0.121.3    40.127.224.23   80:32347/TCP,443:32189/TCP   2d2h
myingress-nginx-ingress-default-backend   ClusterIP      10.0.211.89   <none>          80/TCP                       2d2h
</pre>

```
```console
kubectl run myubuntu-$RANDOM --generator=run-pod/v1 \
  --namespace=my-app \
  --limits="cpu=200m,memory=100Mi" \
  --requests="cpu=100m,memory=50Mi" \
  --rm -i --tty --image ubuntu:16.04 -- bash
```
<pre>
apt-get update
apt-get install curl iputils-ping dnsutils -y

nslookup 40.127.224.23
ping 40.127.224.23
curl 40.127.224.23 -H 'Host: a.domain.com'

Hello, World from Docker! <br><img src="https://www.docker.com/sites/default/files/horizontal.png"><br>  Displayed at: my-app-a-v1-69db8b5bd6-jpmdt<br>Application version : v1.0.0     !<br>

curl 40.127.224.23 -H 'Host: b.domain.com'

Hello, World from Docker! <br><img src="https://www.docker.com/sites/default/files/horizontal.png"><br>  Displayed at: my-app-b-v1-66fdb77768-prlxn<br>Application version : v1.0.0     !<br>

</pre>


Now change version 1 to version 2 in ingress configuration

```concole
kubectl apply -f ingress-v2.yaml
```
<pre>
ingress.extensions/my-app configured
</pre>


In the same ubuntu pod
<pre>
curl 40.127.224.23 -H 'Host: a.domain.com'

Hello, World from Docker! <br><img src="https://www.docker.com/sites/default/files/horizontal.png"><br>  Displayed at: my-app-a-v2-5d9bdbcb6d-9mqbp<br>Application version : v2.0.0     !<br>

curl 40.127.224.23 -H 'Host: b.domain.com'

Hello, World from Docker! <br><img src="https://www.docker.com/sites/default/files/horizontal.png"><br>  Displayed at: my-app-b-v2-698bf66c78-v4hgd<br>Application version : v2.0.0     

</pre>




Literature:
https://docs.microsoft.com/bs-cyrl-ba/azure/aks/ingress-basic
https://vincentlauzon.com/2018/11/21/understanding-simple-http-ingress-in-aks/

