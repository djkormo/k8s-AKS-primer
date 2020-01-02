

# Kubernetes Wordsmith Demo

Wordsmith is the demo project shown at DockerCon EU 2017, where Docker announced that support for Kubernetes was coming to the Docker platform.

The demo app runs across three containers:

- [db](db/Dockerfile) - a Postgres database which stores words

- [words](words/Dockerfile) - a Java REST API which serves words read from the database

- [web](web/Dockerfile) - a Go web application which calls the API and builds words into sentences:

![The Wordsmith app running in Kubernetes on Docker for Mac](img/dockercon-barcelona-logo.svg)



## Deploy application 

```console
kubectl create ns wordsmith
```

```console
kubectl config  set-context --current --namespace=wordsmith
```
<pre>
Context "***" modified.
</pre>

```console
kubectl get all
```

<pre>
No resources found.
</pre>

### DB part

```console
kubectl apply -f db-service.yaml
```
<pre>
service/db created
</pre>

```console
kubectl apply -f db-deployment-v1.yaml
```
<pre>
deployment.apps/db created
</pre>

### Words part

```console
kubectl apply -f api-service.yaml 
```
<pre>
service/words created
</pre>

```console
kubectl apply -f api-deployment-v1.yaml 
```
<pre>
deployment.apps/words created
</pre>

### Web part

```console
kubectl apply -f web-service.yaml
```
<pre> 
service/web created
</pre>
```console
kubectl apply -f web-deployment-v1.yaml 
```
<pre>
deployment.apps/web created
</pre>

### Deployed services

```console
kubectl get svc
```
<pre>
NAME    TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE  
db      ClusterIP      None           <none>        5432/TCP         3m50s
web     LoadBalancer   10.99.35.213   localhost     8081:31270/TCP   47s  
words   ClusterIP      None           <none>        8080/TCP         2m41s
</pre>

In kubeview dashboard

![kubeview](kubeview-wordsmith-v1.png)


Now browse to http://localhost:8081 and you will see

![wordsmith](wordsmith-v1.png)

Based on:
https://github.com/dockersamples/k8s-wordsmith-demo

Literature:
https://medium.com/@nieldw/kubernetes-probes-for-postgresql-pods-a66d707df6b4

