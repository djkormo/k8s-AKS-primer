#### Let's run the first pod

```console
kubectl run my-app --image=djkormo/primer --replicas=2
```
<pre>
kubectl run --generator=deployment/apps.v1 is DEPRECATED and will be removed in a future version. Use kubectl run --generator=run-pod/v1 or kubectl create instead
</pre>

###### Create only pod (different case)
```console
kubectl run my-app --image=djkormo/primer --replicas=2 --generator=run-pod/v1
console


```console
kubectl get deployment # or deploy
```
<pre>
NAME     DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
my-app   2         2         2            0           66s
</pre>
```
kubectl get replicaset # or rs
```
<pre>
NAME                DESIRED   CURRENT   READY   AGE
my-app-54fd89d7f4   2         2         2       101s
</pre>
```console
kubectl get pods # or po
```
<pre>
NAME                        READY   STATUS    RESTARTS   AGE
my-chess-56b4d8597b-9swr4   1/1     Running   0          2m3s
my-chess-56b4d8597b-s5r2k   1/1     Running   0          2m3s
</pre>

#### You can get all objects

```console
kubectl get all
```
<pre>
NAME                          READY   STATUS    RESTARTS   AGE
pod/my-app-54fd89d7f4-98lk7   1/1     Running   0          3m27s
pod/my-app-54fd89d7f4-fl4w2   1/1     Running   0          3m27s


NAME                     DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/my-app   2         2         2            2           3m28s

NAME                                DESIRED   CURRENT   READY   AGE
replicaset.apps/my-app-54fd89d7f4   2         2         2       3m27s
</pre>

```console
kubectl get nodes
```
<pre>
NAME                       STATUS   ROLES   AGE   VERSION
aks-agentpool-64356105-0   Ready    agent   29d   v1.12.8
</pre>


###### In Yaml format
```console
kubectl get deployment  my-app -o yaml
```
##### In Json format
```console
kubectl get deployment  my-app -o json
```

##### In own template TODO
```console
kubectl get deployment  my-app -o jsonpath={.metadata.*}
```
<pre>
my-app /apis/extensions/v1beta1/namespaces/default/deployments/my-app 27520003-b494-11e9-86ff-0e4bcd418782 3023280 default 3 2019-08-01T19:40:01Z map[owner:djkormo run:my-app] map[deployment.kubernetes.io/revision:1]
</pre>

#####  get -> describe to show details

```console
kubectl describe deployment my-app
```
<pre>
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  8m4s  deployment-controller  Scaled up replica set my-app-54fd89d7f4 to 2
</pre>


#### Labels

```console
kubectl get deployment --show-labels
```

<pre>
NAME     DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE     LABELS
my-app   2         2         2            2           6m10s   run=my-app
</pre>

```console
kubectl get replicasets --show-labels
```
<pre>
NAME                DESIRED   CURRENT   READY   AGE     LABELS
my-app-54fd89d7f4   2         2         2       6m20s   pod-template-hash=54fd89d7f4,run=my-app
</pre>

```console
kubectl get pods --show-labels
```
<pre>
NAME                      READY   STATUS    RESTARTS   AGE     LABELS
my-app-54fd89d7f4-98lk7   1/1     Running   0          6m32s   pod-template-hash=54fd89d7f4,run=my-app
my-app-54fd89d7f4-fl4w2   1/1     Running   0          6m32s   pod-template-hash=54fd89d7f4,run=my-app
</pre>

#### Adding label column

```console
kubectl get replicaset -L run # --label-columns
```

<pre>
NAME                DESIRED   CURRENT   READY   AGE     RUN
my-app-54fd89d7f4   2         2         2       6m46s   my-app
</pre>
##### Filtering by label value


```console
kubectl get replicaset -l run=my-app # --selector
```
<pre>
NAME                DESIRED   CURRENT   READY   AGE
my-app-54fd89d7f4   2         2         2       8m22s
</pre>

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
NAME     DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE     LABELS
my-app   2         2         2            2           8m50s   owner=djkormo,run=my-app
</pre>

```console
kubectl get pods -l run=my-app
```

<pre>
NAME                      READY   STATUS    RESTARTS   AGE
my-app-54fd89d7f4-98lk7   1/1     Running   0          9m6s
my-app-54fd89d7f4-fl4w2   1/1     Running   0          9m6s
</pre>

### Delete pods

```console
kubectl delete pods -l run=my-app
```
<pre>
pod "my-app-54fd89d7f4-98lk7" deleted
pod "my-app-54fd89d7f4-fl4w2" deleted
</pre>

#### After a while , look at pods names

```console
kubectl get pods -l run=my-app
```
<pre>
NAME                      READY   STATUS    RESTARTS   AGE
my-app-54fd89d7f4-c4w7l   1/1     Running   0          47s
my-app-54fd89d7f4-vqjj5   1/1     Running   0          46s
</pre>

#### Delete replicaSet
```console
kubectl get rs -l run=my-app
```
<pre>
NAME                DESIRED   CURRENT   READY   AGE
my-app-54fd89d7f4   2         2         2       10m
</pre>

```console
kubectl delete rs -l run=my-app
```
<pre>
replicaset.extensions "my-app-54fd89d7f4" deleted
</pre>

```console
kubectl get rs -l run=my-app
```

#### Simple scaling to 4 instances
```console 
kubectl scale --current-replicas=2 --replicas=2 deployment/my-app
```
<pre>
NAME                DESIRED   CURRENT   READY   AGE
my-app-54fd89d7f4   4         4         4       10m
</pre>

#### And again to 2 instances
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
Hi, Iâm Anonymous, from my-app-54fd89d7f4-rcgct.
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
kubectl get services my-app # or svc
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
IP:                10.0.61.36
Port:              <unset>  3000/TCP
TargetPort:        3000/TCP
Endpoints:         10.244.0.115:3000,10.244.0.116:3000
Session Affinity:  None
Events:            <none>
</pre>

#### Show endpoints

```console
kubectl get endpoints my-app
```
<pre>
NAME     ENDPOINTS                             AGE
my-app   10.244.0.115:3000,10.244.0.116:3000   3m15s
</pre>

##### Temporary pod 
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
Hi, Im Anonymous, from my-app-54fd89d7f4-w7jgb.
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
Found 2 pods, using pod/my-app-54fd89d7f4-rcgct
Server running at http://0.0.0.0:3000/
</pre>


```console
kubectl logs deployment/myapp --since 5m > log.txt
cat log.txt
```
<pre>

</pre>

```console
POD_NAME=$(kubectl get pods -l run=my-app -o jsonpath={.items[0].metadata.name})
echo $POD_NAME
```

<pre>
my-app-54fd89d7f4-rcgct
</pre>

##### Executing inside pod

```console
kubectl exec $POD_NAME -it sh
```
<pre>
node --version
v10.16.0
# echo $WHOAMI

# exit
</pre>

```console
kubectl cp $POD_NAME:app.js remote-app.js
cat remote-app.js
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
kubectl set env deployment/my-app WHOAMI="HAL 9000"
kubectl exec $POD_NAME -it sh
```

<pre>
echo $WHOAMI
HAL 9000
</pre>

#### On what nodes are our pods
```console
kubectl get pods -l run=my-app -o wide # check the NODE column
```
<pre>
NAME                      READY   STATUS    RESTARTS   AGE     IP             NODE                       NOMINATED NODE
my-app-64dd8fc57f-h59lc   1/1     Running   0          3m46s   10.244.0.123   aks-agentpool-64356105-0   <none>
my-app-64dd8fc57f-vwh24   1/1     Running   0          3m42s   10.244.0.124   aks-agentpool-64356105-0   <none>
</pre>
```console
NODE_NAME=$(kubectl get pods -l run=my-app -o jsonpath={.items[0].spec.nodeName})
kubectl patch deployment my-app -p '{"spec":{"template":{"spec":{"nodeName":"'$NODE_NAME'"}}}}'
```
<pre>
deployment.extensions/my-app patched
</pre>

```console
kubectl get pods -l run=my-app -o wide
```
<pre>
NAME                      READY   STATUS        RESTARTS   AGE     IP             NODE                       NOMINATED NODE
my-app-64dd8fc57f-h59lc   1/1     Terminating   0          5m19s   10.244.0.123   aks-agentpool-64356105-0   <none>
my-app-64dd8fc57f-vwh24   1/1     Terminating   0          5m15s   10.244.0.124   aks-agentpool-64356105-0   <none>
my-app-67dbbfbd74-kkw9g   1/1     Running       0          26s     10.244.0.125   aks-agentpool-64356105-0   <none>
my-app-67dbbfbd74-kvw4l   1/1     Running       0          22s     10.244.0.126   aks-agentpool-64356105-0   <none>
</pre>

##### After a while
<pre>
NAME                      READY   STATUS    RESTARTS   AGE   IP             NODE                       NOMINATED NODE
my-app-67dbbfbd74-kkw9g   1/1     Running   0          63s   10.244.0.125   aks-agentpool-64356105-0   <none>
my-app-67dbbfbd74-kvw4l   1/1     Running   0          59s   10.244.0.126   aks-agentpool-64356105-0   <none>
</pre>
##### Look what is going with Replicaset objects

<pre>
NAME                 DESIRED   CURRENT   READY   AGE
my-app-64dd8fc57f    0         0         0       15m
my-app-67dbbfbd74    2         2         2       10m
</pre>

##### Exporting  to yaml 
```console
kubectl get deployment my-app -o yaml --export > my-app-deployment.yaml
kubectl get service my-app -o yaml --export > my-app-service.yaml
###### replicasets and pods are controlled and don’t need manifests (the deployment spec contains a pod template)
```

<pre>
Flag --export has been deprecated, This flag is deprecated and will be removed in future.
</pre>

my-app-deployment.yaml

```yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  annotations:
    deployment.kubernetes.io/revision: "3"
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
          value: HAL 9000
        image: djkormo/primer
        imagePullPolicy: Always
        name: my-app
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      dnsPolicy: ClusterFirst
      nodeName: aks-agentpool-64356105-0
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
status: {}
```

my-app-service.yaml

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
kubectl apply -f my-app-deployment.yaml -f my-app-service.yaml
```


