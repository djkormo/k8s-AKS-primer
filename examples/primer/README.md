## Simple overview  of main Kubernetes objects

#### Create first namespace

```console
kubectl create ns my-app
```
<pre>
namespace/my-app created
</pre>

#### Switch connection context to my-app namespace

```console
kubectl config set-context --current --namespace=my-app
```
<pre>
Context "***" modified.
</pre>


#### Let's run the first object

```console
kubectl run my-app --image=djkormo/primer --replicas=2
```
<pre>
kubectl run --generator=deployment/apps.v1 is DEPRECATED and will be removed in a future version. Use kubectl run --generator=run-pod/v1 or kubectl create instead
deployment.apps/my-app created
</pre>

##### delete our objects

```console
kubectl delete deployment/my-app
```
<pre>
deployment.extensions "my-app" deleted
service "kubernetes" deleted
</pre>

```console
kubectl get po
```
<pre>
NAME                      READY   STATUS        RESTARTS   AGE
my-app-6b7855d554-b2rzn   1/1     Terminating   0          56s
my-app-6b7855d554-lgg9c   1/1     Terminating   0          56s
</pre>
##### After a while

<pre>
No resources found.
</pre>

###### Create only pod (different case)
```console
kubectl run my-app --image=djkormo/primer --replicas=2 --generator=run-pod/v1
```
<pre>
pod/my-app created
</pre>

#### You can also try to verify  in dry run mode
```
kubectl run my-app --generator=run-pod/v1 nginx --image=djkormo/primer --dry-run -o yaml --port=3000
```
##### Definition of pod in YAML format
```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: my-app
  name: my-app
spec:
  containers:
  - args:
    - nginx
    image: djkormo/primer
    name: my-app
    ports:
    - containerPort: 3000
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```

###### Let's stop at this moment

#### See what we have inside k8s cluster
```
kubectl get pod
```
<pre>
NAME     READY   STATUS    RESTARTS   AGE
my-app   1/1     Running   0          20s
</pre>

```console
kubectl get pod my-app
```
<pre>
NAME     READY   STATUS    RESTARTS   AGE
my-app   1/1     Running   0          73s
</pre>


```console
kubectl describe pod my-app
```
<pre>
...
Events:
  Type    Reason     Age    From                               Message
  ----    ------     ----   ----                               -------
  Normal  Scheduled  6m18s  default-scheduler                  Successfully assigned my-app/my-app to aks-nodepool1-16191604-1
  Normal  Pulling    6m17s  kubelet, aks-nodepool1-16191604-1  Pulling image "djkormo/primer"
  Normal  Pulled     6m16s  kubelet, aks-nodepool1-16191604-1  Successfully pulled image "djkormo/primer"
  Normal  Created    6m15s  kubelet, aks-nodepool1-16191604-1  Created container my-app
  Normal  Started    6m15s  kubelet, aks-nodepool1-16191604-1  Started container my-app
</pre>


#### delete our pod

```console
kubectl delete pod my-app
```
<pre>
pod "my-app" deleted
</pre>


### Let's experiment with dry-run and pod restart policy

```console
kubectl run my-app --image=djkormo/primer --restart="Never" 
```
<pre>
pod/my-app created
</pre>

### Delete this new pod

```console
kubectl delete pod/my-app
```
<pre>
pod "my-app" deleted
</pre>

#### Dry-run allows us to prepare changes in kubernetes cluster 

```console
kubectl run my-app --image=djkormo/primer --restart="Never"  --dry-run
```
<pre>
pod/my-app created (dry run)
</pre>
```console
kubectl get pods
```
<pre>
No resources found.
</pre>

#### Additionally we can export our future deployment in yaml  or json format

```console
kubectl run my-app --image=djkormo/primer --restart="Never"  --dry-run -o yaml
```
<pre>
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: my-app
  name: my-app
spec:
  containers:
  - image: djkormo/primer
    name: my-app
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}
</pre>
```console
kubectl run my-app --image=djkormo/primer --restart="Never"  --dry-run -o yaml
```
<pre>
{
    "kind": "Pod",
    "apiVersion": "v1",
    "metadata": {
        "name": "my-app",
        "creationTimestamp": null,
        "labels": {
            "run": "my-app"
        }
    },
    "spec": {
        "containers": [
            {
                "name": "my-app",
                "image": "djkormo/primer",
                "resources": {}
            }
        ],
        "restartPolicy": "Never",
        "dnsPolicy": "ClusterFirst"
    },
    "status": {}
}
</pre>

### Now we only change restart pod policy from Never to Always in dry-run mode
```console
kubectl run my-app --image=djkormo/primer --restart="Always" --replicas=2 --dry-run
```
<pre>
kubectl run --generator=deployment/apps.v1 is DEPRECATED and will be removed in a future version. Use kubectl run --generator=run-pod/v1 or kubectl create instead.
deployment.apps/my-app created (dry run)
</pre>

```console
kubectl run my-app --image=djkormo/primer --restart="Always" --replicas=2 --dry-run  -o yaml
```
<pre>
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    run: my-app
  name: my-app
spec:
  replicas: 2
  selector:
    matchLabels:
      run: my-app
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        run: my-app
    spec:
      containers:
      - image: djkormo/primer
        name: my-app
        resources: {}
status: {}
</pre>



#### Now we have new objects deployment -> replicaset -> pod. Lets remove --dry-run mode

##### Lets create our objects as deloyment

```console
kubectl run my-app --image=djkormo/primer --replicas=2 --restart="Always"
```
<pre>
kubectl run --generator=deployment/apps.v1 is DEPRECATED and will be removed in a future version. Use kubectl run --generator=run-pod/v1 or kubectl create instead
deployment.apps/my-app created
</pre>

```console
kubectl get deployment # or deploy
```
<pre>
NAME     DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
my-app   2         2         2            0           66s
</pre>


```console
kubectl get replicaset # or rs
```

<pre>
NAME                DESIRED   CURRENT   READY   AGE
my-app-6b7855d554   2         2         2       78s
</pre>

```console
kubectl get pods # or po
```
<pre>
NAME                      READY   STATUS    RESTARTS   AGE
my-app-6b7855d554-c5scw   1/1     Running   0          3m1s
my-app-6b7855d554-q7nzl   1/1     Running   0          3m1s
</pre>

#### You can get all objects. 
#### Beware! All does not mean all types of objects, but  only pods, services, replicasets and deployments

```console
kubectl get all
```
<pre>
NAME                          READY   STATUS    RESTARTS   AGE
pod/my-app-6b7855d554-c5scw   1/1     Running   0          4m30s
pod/my-app-6b7855d554-q7nzl   1/1     Running   0          4m30s

NAME                     READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/my-app   2/2     2            2           4m30s

NAME                                DESIRED   CURRENT   READY   AGE
replicaset.apps/my-app-6b7855d554   2         2         2       4m30s
</pre>

```console
kubectl get nodes
```
<pre>
NAME                       STATUS   ROLES   AGE   VERSION
aks-nodepool1-16191604-0   Ready    agent   17d   v1.14.3
aks-nodepool1-16191604-1   Ready    agent   11d   v1.14.3
</pre>


###### In Yaml format
```console
kubectl get deployment  my-app -o yaml
```
<pre>
apiVersion: extensions/v1beta1
kind: Deployment
....
</pre>

##### In Json format
```console
kubectl get deployment  my-app -o json
```
<pre>
{
    "apiVersion": "extensions/v1beta1",
    "kind": "Deployment",
....
</pre>

##### In own template 
```console
kubectl get deployment  my-app -o jsonpath={.metadata.*}
```
<pre>
map[run:my-app] my-app /apis/extensions/v1beta1/namespaces/default/deployments/my-app 1697123 1 2019-08-04T11:27:36Z my-app dc0d20f4-b6aa-11e9-8fb6-7a04c9d91c64 
map[deployment.kubernetes.io/revision:1]
</pre>

#####  get -> describe to show details

```console
kubectl describe deployment my-app
```
<pre>
...
OldReplicaSets:  <none>
NewReplicaSet:   my-app-6b7855d554 (2/2 replicas created)
Events:
  Type    Reason             Age    From                   Message
  ----    ------             ----   ----                   -------
  Normal  ScalingReplicaSet  9m11s  deployment-controller  Scaled up replica set my-app-6b7855d554 to 2
</pre>


#### Labels

```console
kubectl get deployment --show-labels # or kubectl get deploy --show-labels
```

<pre>
NAME     READY   UP-TO-DATE   AVAILABLE   AGE   LABELS
my-app   2/2     2            2           10m   run=my-app
</pre>

```console
kubectl get replicasets --show-labels # or kubectl get rs --show-labels
```
<pre>
NAME                DESIRED   CURRENT   READY   AGE   LABELS
my-app-6b7855d554   2         2         2       10m   pod-template-hash=6b7855d554,run=my-app
</pre>

```console
kubectl get pods --show-labels # or kubectl get pod --show-labels # or kubectl get po --show-labels
```
<pre>
my-app-6b7855d554-c5scw   1/1     Running   0          11m   pod-template-hash=6b7855d554,run=my-app
my-app-6b7855d554-q7nzl   1/1     Running   0          11m   pod-template-hash=6b7855d554,run=my-app
</pre>

#### Adding label column

```console
kubectl get replicaset -L run # abbreviation of --label-columns
```

<pre>
NAME                DESIRED   CURRENT   READY   AGE   RUN
my-app-6b7855d554   2         2         2       12m   my-app
</pre>
```console
kubectl get replicaset -L run -L pod-template-hash # --label-columns
```
<pre>
NAME                DESIRED   CURRENT   READY   AGE   RUN      POD-TEMPLATE-HASH
my-app-6b7855d554   2         2         2       12m   my-app   6b7855d554
</pre>

##### Filtering by label value


```console
kubectl get replicaset -l run=my-app # abbreviation of --selector
```
<pre>
NAME                DESIRED   CURRENT   READY   AGE
my-app-6b7855d554   2         2         2       14m
</pre>

#### Add label to object
```console
kubectl label deployment my-app owner=djkormo
```
<pre>
deployment.extensions/my-app labeled
</pre>

```console
kubectl get deployment --show-labels
```
<pre>
NAME     READY   UP-TO-DATE   AVAILABLE   AGE   LABELS
my-app   2/2     2            2           15m   owner=djkormo,run=my-app
</pre>

```console
kubectl get pods -l run=my-app
```

<pre>
NAME                      READY   STATUS    RESTARTS   AGE
my-app-6b7855d554-c5scw   1/1     Running   0          16m
my-app-6b7855d554-q7nzl   1/1     Running   0          16m
</pre>


```console
kubectl get pods -l run=my-app  --show-labels
```
<pre>
NAME                      READY   STATUS    RESTARTS   AGE   LABELS
my-app-6b7855d554-c5scw   1/1     Running   0          16m   pod-template-hash=6b7855d554,run=my-app
my-app-6b7855d554-q7nzl   1/1     Running   0          16m   pod-template-hash=6b7855d554,run=my-app
</pre>

### Delete pods

```console
kubectl delete pods -l run=my-app
```
<pre>
pod "my-app-6b7855d554-c5scw" deleted
pod "my-app-6b7855d554-q7nzl" deleted
</pre>

#### After a while , look at pods names

```console
kubectl get pods -l run=my-app
```
<pre>
NAME                      READY   STATUS    RESTARTS   AGE
my-app-6b7855d554-5zws7   1/1     Running   0          3m33s
my-app-6b7855d554-x9zkk   1/1     Running   0          3m33s
</pre>

#### Experimental, do not do it in your production environment

#### Delete replicaSet
###### Look what we have 
```console
kubectl get rs -l run=my-app
```
<pre>
NAME                DESIRED   CURRENT   READY   AGE
my-app-6b7855d554   2         2         2       22m
</pre>
#### delete rs
```console
kubectl delete rs -l run=my-app
```
<pre>
replicaset.extensions "my-app-6b7855d554" deleted
</pre>

```console
kubectl get rs -l run=my-app
```
<pre>
NAME                DESIRED   CURRENT   READY   AGE
my-app-6b7855d554   2         2         2       33s
</pre>

#### Simple scaling to 4 instances
```console 
kubectl scale --current-replicas=2 --replicas=4 deployment/my-app
```
<pre>
 --replicas=4 deployment/my-app
deployment.extensions/my-app scaled
</pre>

#### Look again
```console
kubectl get rs -l run=my-app
```

<pre>
NAME                DESIRED   CURRENT   READY   AGE
my-app-6b7855d554   4         4         4       103s
</pre>

#### And again scale to 2 instances
```console
kubectl scale  --replicas=2 deployment/my-app
```
<pre>
NAME                DESIRED   CURRENT   READY   AGE
my-app-54fd89d7f4   2         2         2       12m
</pre>

#### Port-forward

```console
kubectl port-forward deployment/my-app 3000:3000
```
<pre>
Forwarding from 127.0.0.1:3000 -> 3000
Forwarding from [::1]:3000 -> 3000
Handling connection for 3000
</pre>

##### Look at localhost:3000

<pre>
Hi, Iâm Anonymous, from my-app-6b7855d554-sjg7m.
</pre>

#### Expose deployment
```console
kubectl expose deployment my-app --port 3000 --target-port=3000
```
<pre>
service/my-app exposed
</pre>

#### Show services

```console
kubectl get services my-app # or kubectl get svc my-app
```
<pre>
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE
my-app       ClusterIP   10.0.61.36   <none>        3000/TCP   44s
</pre>
```console
kubectl describe services my-app
```

<pre>
Name:              my-app
Namespace:         default
Labels:            owner=djkormo
                   run=my-app
Annotations:       <none>
Selector:          run=my-app
Type:              ClusterIP
IP:                10.0.74.93
Port:              <unset>  3000/TCP
TargetPort:        3000/TCP
Endpoints:         10.244.1.211:3000,10.244.1.212:3000
Session Affinity:  None
Events:            <none>
</pre>

#### Show endpoints

```console
kubectl get endpoints my-app
```
<pre>
NAME     ENDPOINTS                             AGE
my-app   10.244.1.211:3000,10.244.1.212:3000   2m58s
</pre>

##### Temporary pod  --rm flag means remove, -it flag means interactive
```console
kubectl run my-test  -it --rm --image=alpine  --generator=run-pod/v1
```
<pre>
If you don't see a command prompt, try pressing enter.
</pre>

##### Execute inside alpine 

```console
apk add curl
curl http://my-app:3000
```
<pre>
...
Hi, Im Anonymous, from my-app-6b7855d554-sjg7m.
...
Hi, Im Anonymous, from my-app-6b7855d554-fzjhl.
...
Hi, Im Anonymous, from my-app-6b7855d554-sjg7m.
</pre>

```console
nslookup my-app
```
<pre>
Name:      my-app
Address 1: 10.0.74.93 my-app.default.svc.cluster.local
</pre>


```console
exit
```
<pre>
Session ended, resume using 'kubectl attach my-test -c my-test -i -t' command when the pod is running
pod "my-test" deleted
</pre>

#### Logs
```console
kubectl logs deployment/my-app
```
<pre>
Found 2 pods, using pod/my-app-6b7855d554-sjg7m
Server running at http://0.0.0.0:3000/
</pre>


```console
kubectl logs deployment/my-app --since 5m > log.txt
cat log.txt
```
<pre>

</pre>

#### Let's do something inside runninig pod
```console
POD_NAME=$(kubectl get pods -l run=my-app -o jsonpath={.items[0].metadata.name})
echo $POD_NAME
```

<pre>
my-app-6b7855d554-fzjhl
</pre>

##### Executing inside pod

```console
kubectl exec $POD_NAME -it sh
```
<pre>
node --version
v10.16.0
# echo $WHOAMI
# ls -la *.js
# -rw-r--r-- 1 root root 450 Aug  1 19:28 app.js
# exit
</pre>
#### Getting file from pod

```console
kubectl cp $POD_NAME:app.js ./from-pod
cat ./from-pod/app.js
```
<pre>
const http = require('http');
const os = require('os');const ip = '0.0.0.0';
const port = 3000;const hostname = os.hostname();
const whoami = process.env['WHOAMI'] || 'Anonymous';const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end(`Hi, I’m ${whoami}, from ${hostname}.\n`);
});server.listen(port, ip, () => {
  console.log(`Server running at http://${ip}:${port}/`);
});
</pre>

##### setting env variable
```console
POD_NAME=$(kubectl get pods -l run=my-app -o jsonpath={.items[0].metadata.name})
kubectl set env deployment/my-app WHOAMI="Kubernetes in 2020"
echo $POD_NAME
kubectl exec $POD_NAME -it sh
```
<pre>
deployment.extensions/my-app env updated
</pre>

#### Inside $POD_NAME
<pre>
echo $WHOAMI
Kubernetes in 2020
printenv |grep WHOAMI
WHOAMI=Kubernetes in 20210
exit
</pre>

#### On what nodes are our pods
```console
kubectl get pods -l run=my-app -o wide # check the NODE column
```
<pre>
NAME                      READY   STATUS    RESTARTS   AGE     IP             NODE                       NOMINATED NODE   READINESS GATES
my-app-7875b68698-6cjrc   1/1     Running   0          2m46s   10.244.1.218   aks-nodepool1-16191604-1   <none>
         <none>
my-app-7875b68698-f4wmt   1/1     Running   0          2m43s   10.244.1.219   aks-nodepool1-16191604-1   <none>
         <none>
</pre>

#### Example valid only if you have more than one node. On local clusters (minicube) it is useless
```console
NODE_NAME=$(kubectl get pods -l run=my-app -o jsonpath={.items[0].spec.nodeName})
echo $NODE_NAME
kubectl patch deployment my-app -p '{"spec":{"template":{"spec":{"nodeName":"'$NODE_NAME'"}}}}'
```
<pre>
deployment.extensions/my-app patched
</pre>

```console
kubectl get pods -l run=my-app -o wide
```
<pre>
NAME                      READY   STATUS        RESTARTS   AGE     IP             NODE                       NOMINATED NODE   READINESS GATES
my-app-7875b68698-6cjrc   1/1     Terminating   0          4m34s   10.244.1.218   aks-nodepool1-16191604-1   <none>           <none>
my-app-7875b68698-f4wmt   1/1     Terminating   0          4m31s   10.244.1.219   aks-nodepool1-16191604-1   <none>           <none>
my-app-dd8846c94-4wlxv    1/1     Running       0          16s     10.244.1.220   aks-nodepool1-16191604-1   <none>           <none>
my-app-dd8846c94-lzxx9    1/1     Running       0          12s     10.244.1.221   aks-nodepool1-16191604-1   <none>           <none>
</pre>

##### After a while
<pre>
NAME                     READY   STATUS    RESTARTS   AGE   IP             NODE                       NOMINATED NODE   READINESS GATES
my-app-dd8846c94-4wlxv   1/1     Running   0          43s   10.244.1.220   aks-nodepool1-16191604-1   <none>
      <none>
my-app-dd8846c94-lzxx9   1/1     Running   0          39s   10.244.1.221   aks-nodepool1-16191604-1   <none>
      <none>
</pre>

##### Look what is going with Replicaset objects
```console
kubectl get rs -l run=my-app
```

<pre>
NAME                DESIRED   CURRENT   READY   AGE
my-app-7875b68698   0         0         0       6m11s
my-app-dd8846c94    2         2         2       113s
</pre>

##### Exporting  to yaml 
```console
kubectl get deployment my-app -o yaml --export > my-app-deployment.yaml
kubectl get service my-app -o yaml --export > my-app-service.yaml

```
###### replicasets and pods are controlled and don’t need manifests (the deployment spec contains a pod template)

<pre>
Flag --export has been deprecated, This flag is deprecated and will be removed in future.
</pre>

How looks my-app-deployment.yaml file
```console
cat my-app-deployment.yaml
```

```yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  annotations:
    deployment.kubernetes.io/revision: "4"
  creationTimestamp: null
  generation: 1
  labels:
    owner: djkormo
    run: my-app
  name: my-app
  selfLink: /apis/extensions/v1beta1/namespaces/default/deployments/my-app
spec:
  progressDeadlineSeconds: 600
  replicas: 2
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      run: my-app
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      creationTimestamp: null
      labels:
        run: my-app
    spec:
      containers:
      - env:
        - name: WHOAMI
          value: WROCLAW 2019
        image: djkormo/primer
        imagePullPolicy: Always
        name: my-app
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      dnsPolicy: ClusterFirst
      nodeName: aks-nodepool1-16191604-1
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
status: {}
```
##### How looks my-app-service.yaml file
```console
cat my-app-service.yaml
```

```yaml
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    owner: djkormo
    run: my-app
  name: my-app
  selfLink: /api/v1/namespaces/default/services/my-app
spec:
  ports:
  - port: 3000
    protocol: TCP
    targetPort: 3000
  selector:
    run: my-app
  sessionAffinity: None
  type: ClusterIP
status:
  loadBalancer: {}

```

##### Recreate the same from yaml files

```console
kubectl delete deployment my-app
kubectl delete service my-app

```

<pre>
deployment.extensions "my-app" deleted
service "my-app" deleted
</pre>

```console
kubectl get all -l run=my-app
```
<pre>
No resources found.
</pre>

##### Create our objects from yaml files
```console
kubectl apply -f ./my-app-deployment.yaml -f ./my-app-service.yaml
```
<pre>
deployment.extensions/my-app created
service/my-app created
</pre>


```console
kubectl get all -l run=my-app
```
<pre>
NAME                         READY   STATUS    RESTARTS   AGE
pod/my-app-dd8846c94-swlkt   1/1     Running   0          54s
pod/my-app-dd8846c94-v4zzc   1/1     Running   0          54s

NAME             TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE
service/my-app   ClusterIP   10.0.230.0   <none>        3000/TCP   54s

NAME                     READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/my-app   2/2     2            2           54s

NAME                               DESIRED   CURRENT   READY   AGE
replicaset.apps/my-app-dd8846c94   2         2         2       54s

</pre>

###### Not only kubectl
```console
kubectl proxy
```
<pre>
Starting to serve on 127.0.0.1:8001
</pre>

##### Try to use http://localhost:8001/api/v1/namespaces/default/services/my-app

```json
{
  "kind": "Service",
  "apiVersion": "v1",
  "metadata": {
    "name": "my-app",
    "namespace": "my-app",
    "selfLink": "/api/v1/namespaces/my-app/services/my-app",
    "uid": "e82695e9-b6b2-11e9-8fb6-7a04c9d91c64",
    "resourceVersion": "1702098",
    "creationTimestamp": "2019-08-04T12:25:12Z",
    "labels": {
      "owner": "djkormo",
      "run": "my-app"
    },
    "annotations": {
      "kubectl.kubernetes.io/last-applied-configuration": "{\"apiVersion\":\"v1\",\"kind\":\"Service\",\"metadata\":{\"annotations\":{},\"creationTimestamp\":null,\"labels\":{\"owner\":\"djkormo\",\"run\":\"my-app\"},\"name\":\"my-app\",\"namespace\":\"default\",\"selfLink\":\"/api/v1/namespaces/default/services/my-app\"},\"spec\":{\"ports\":[{\"port\":3000,\"protocol\":\"TCP\",\"targetPort\":3000}],\"selector\":{\"run\":\"my-app\"},\"sessionAffinity\":\"None\",\"type\":\"ClusterIP\"},\"status\":{\"loadBalancer\":{}}}\n"
    }
  },
  "spec": {
    "ports": [
      {
        "protocol": "TCP",
        "port": 3000,
        "targetPort": 3000
      }
    ],
    "selector": {
      "run": "my-app"
    },
    "clusterIP": "10.0.230.0",
    "type": "ClusterIP",
    "sessionAffinity": "None"
  },
  "status": {
    "loadBalancer": {
      
    }
  }
}
```


