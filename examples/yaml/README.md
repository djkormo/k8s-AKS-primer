### YAML for k8s users


####Fortunately, there are only two types of structures you need to know about in YAML:

##### Lists
##### Maps

#####YAML Maps
---
apiVersion: v1
kind: Pod

the same in JSON`
```json
{
   "apiVersion": "v1",
   "kind": "Pod"
}
```

---
apiVersion: v1
kind: Pod
metadata:
  name: rss-site
  labels:
    app: web
	
	

Quick note: NEVER use tabs in a YAML file.

the same in JSON

```json
{
  "apiVersion": "v1",
  "kind": "Pod",
  "metadata": {
               "name": "rss-site",
               "labels": {
                          "app": "web"
                         }
              }
}
```


##### YAML lists

###### YAML lists are literally a sequence of objects

```yaml
args:
  - sleep
  - "1000"
  - message
  - "Bring back Firefly!"
```

the same in JSON 

```json
{
   "args": ["sleep", "1000", "message", "Bring back Firefly!"]
}
```



Samply YAML content for k8s 

```yaml
---
apiVersion: v1
kind: Pod
metadata:
  name: rss-site
  labels:
    app: web
spec:
  containers:
    - name: front-end
      image: nginx
      ports:
        - containerPort: 80
    - name: rss-reader
      image: nickchase/rss-php-nginx:v1
      ports:
        - containerPort: 88
```


the same in JSON

```json
{
   "apiVersion": "v1",
   "kind": "Pod",
   "metadata": {
                 "name": "rss-site",
                 "labels": {
                             "app": "web"
                           }
               },
    "spec": {
       "containers": [{
                       "name": "front-end",
                       "image": "nginx",
                       "ports": [{
                                  "containerPort": "80"
                                 }]
                      }, 
                      {
                       "name": "rss-reader",
                       "image": "nickchase/rss-php-nginx:v1",
                       "ports": [{
                                  "containerPort": "88"
                                 }]
                      }]
            }
}
```

```console
kubectl create -f pod.yaml
```

pod "rss-site" created

```console
kubectl get pods
```
<pre>
 NAME       READY     STATUS              RESTARTS   AGE
 rss-site   0/2       ContainerCreating   0          6s
</pre>

 ```console
kubectl get pods
```
<pre>
NAME       READY     STATUS    RESTARTS   AGE
rss-site   2/2       Running   0          14s
</pre>


```console
kubectl get pods
```
<pre>
NAME       READY     STATUS         RESTARTS   AGE
rss-site   1/2       ErrImagePull   0          9s
</pre>

```console
kubectl describe pod rss-site
```
<pre>
42s           26s             2       {kubelet 10.0.10.7}                    Warning          FailedSync              Error syncing pod, skipping: failed to "StartContainer" for "rss-reader" with ErrImagePull: "Tag latest not found in repository docker.io/nickchase/rss-php-nginx
</pre>


#### Creating deployment in YAML

```yaml
---
 apiVersion: extensions/v1beta1
 kind: Deployment
 metadata:
   name: rss-site
 spec:
   replicas: 2
```

```yaml
---
 apiVersion: extensions/v1beta1
 kind: Deployment
 metadata:
   name: rss-site
 spec:
   replicas: 2
   template:
     metadata:
       labels:
         app: web
     spec:
       containers:
         - name: front-end
           image: nginx
           ports:
             - containerPort: 80
         - name: rss-reader
           image: nickchase/rss-php-nginx:v1
           ports:
             - containerPort: 88

```

```console
kubectl create -f deployment.yaml
```

<pre>
deployment "rss-site" created
</pre>

```console
kubectl get deployments
```

<pre>
NAME       DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
rss-site   2         2         2            1           7s
</pre>


<pre>
NAME       DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
rss-site   2         2         2            2           1m
</pre>
