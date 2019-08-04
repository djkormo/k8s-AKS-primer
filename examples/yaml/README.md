### YAML for k8s users


#### Fortunately, there are only two types of structures you need to know about in YAML:

##### Lists
##### Maps

##### YAML Maps
```yaml
---
apiVersion: v1
kind: Pod
```

the same in JSON
```json
{
   "apiVersion": "v1",
   "kind": "Pod"
}
```


```yaml
---
apiVersion: v1
kind: Pod
metadata:
  name: rss-site
  labels:
    app: web
```



https://matthewpalmer.net/kubernetes-app-developer/articles/kubernetes-apiversion-definition-guide.html

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
  - "message"
  - "Bring back Firefly!"
```

the same in JSON 

```json
{
   "args": ["sleep", "1000", "message", "Bring back Firefly!"]
}
```



Simple YAML content for k8s 

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
      image: nickchase/rss-php-nginx:v2 # v2 does not exist
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
                       "image": "nickchase/rss-php-nginx:v2", 
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
<pre>
pod "rss-site" created
</pre>

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
kubectl describe pod rss-site | grep Events: -A20
```

<pre>
Events:
  Type     Reason     Age                    From                               Message
  ----     ------     ----                   ----                               -------
  Normal   Scheduled  3m43s                  default-scheduler                  Successfully assigned my-app/rss-site to aks-nodepool1-16191604-1
  Normal   Pulling    3m42s                  kubelet, aks-nodepool1-16191604-1  Pulling image "nginx"
  Normal   Pulled     3m41s                  kubelet, aks-nodepool1-16191604-1  Successfully pulled image "nginx"
  Normal   Created    3m40s                  kubelet, aks-nodepool1-16191604-1  Created container front-end
  Normal   Started    3m40s                  kubelet, aks-nodepool1-16191604-1  Started container front-end
  Normal   Pulling    2m55s (x3 over 3m40s)  kubelet, aks-nodepool1-16191604-1  Pulling image "nickchase/rss-php-nginx:v2"
  Warning  Failed     2m54s (x3 over 3m39s)  kubelet, aks-nodepool1-16191604-1  Failed to pull image "nickchase/rss-php-nginx:v2": rpc error: code = Unknown desc = Error response from daemon: manifest for nickchase/rss-php-nginx:v2 not found: manifest unknown: manifest unknown
  Warning  Failed     2m54s (x3 over 3m39s)  kubelet, aks-nodepool1-16191604-1  Error: ErrImagePull
  Normal   BackOff    2m39s (x3 over 3m38s)  kubelet, aks-nodepool1-16191604-1  Back-off pulling image "nickchase/rss-php-nginx:v2"
  Warning  Failed     2m39s (x3 over 3m38s)  kubelet, aks-nodepool1-16191604-1  Error: ImagePullBackOff
</pre>


##### Correct v2 do v1 in bad image
```console
kubectl create -f pod.yaml
```
<pre>
Error from server (AlreadyExists): error when creating "pod.yaml": pods "rss-site" already exists
</pre>

```console
kubectl apply -f pod.yaml
```

<pre>
Warning: kubectl apply should be used on resource created by either kubectl create --save-config or kubectl apply
pod/rss-site configured
</pre>

```console
kubectl get pods
```

<pre>
NAME       READY   STATUS    RESTARTS   AGE
rss-site   2/2     Running   0          5m48s
</pre>

#### deleting pod based on yaml file
```console
kubectl delete -f pod.yaml
```
<pre>
pod "rss-site" deleted
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
           image: nickchase/rss-php-nginx:v1 ##### v1 is the correct version
           ports:
             - containerPort: 88

```

```console
kubectl create -f deployment.yaml
```

<pre>
deployment.extensions/rss-site created
</pre>

```console
kubectl get deployments
```

<pre>
NAME       READY   UP-TO-DATE   AVAILABLE   AGE
rss-site   2/2     2            2           13s
</pre>

```console
kubectl get rs
```
<pre>
NAME                 DESIRED   CURRENT   READY   AGE
rss-site-c88f9b65c   2         2         2       40s
</pre>

```console
kubectl get pods
```
<pre>
rss-site-c88f9b65c-8gqgr   2/2     Running   0          88s
rss-site-c88f9b65c-xhnjm   2/2     Running   0          88s
</pre>

##### Based on 

##### https://www.mirantis.com/blog/introduction-to-yaml-creating-a-kubernetes-deployment/


You can also specify more complex properties, such as a command to run when the container starts, arguments it should use, a working directory, 
or whether to pull a new copy of the image every time it’s instantiated.  
You can also specify even deeper information, such as the location of the container’s exit log.  
Here are the properties you can set for a Container:

name
image
command
args
workingDir
ports
env
resources
volumeMounts
livenessProbe
readinessProbe
lifecycle
terminationMessagePath
imagePullPolicy
securityContext
stdin
stdinOnce
tty

