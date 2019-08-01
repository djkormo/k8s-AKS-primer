#### Let's run the first pod

```console
kubectl run my-chess --image=djkormo/chess-ai:blue --replicas=2
```
<pre>
kubectl run --generator=deployment/apps.v1 is DEPRECATED and will be removed in a future version. Use kubectl run --generator=run-pod/v1 or kubectl create instead
</pre>

```console
kubectl get deployment # or deploy
```
<pre>
NAME       DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
my-chess   2         2         2            2           68s
</pre>
```
kubectl get replicaset # or rs
```
<pre>
NAME                  DESIRED   CURRENT   READY   AGE
my-chess-56b4d8597b   2         2         2       106s
</pre>
```console
kubectl get pods # or po
```
<pre>
NAME                        READY   STATUS    RESTARTS   AGE
my-chess-56b4d8597b-9swr4   1/1     Running   0          2m3s
my-chess-56b4d8597b-s5r2k   1/1     Running   0          2m3s
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
kubectl get deployment  my-chess -o yaml
```
##### In Json format
```console
kubectl get deployment  my-chess -o json
```
#####  get -> describe to show details
```console
kubectl describe deployment my-chess
```

#### Labels

```console
kubectl get deployment --show-labels
```

<pre>
NAME       DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE   LABELS
my-chess   2         2         2            2           5m    run=my-chess
</pre>

```console
kubectl get replicasets --show-labels
```
<pre>
NAME                  DESIRED   CURRENT   READY   AGE    LABELS
my-chess-56b4d8597b   2         2         2       5m1s   pod-template-hash=56b4d8597b,run=my-chess
</pre>

```console
kubectl get pods --show-labels
```
<pre>
NAME                        READY   STATUS    RESTARTS   AGE    LABELS
my-chess-56b4d8597b-9swr4   1/1     Running   0          5m1s   pod-template-hash=56b4d8597b,run=my-chess
my-chess-56b4d8597b-s5r2k   1/1     Running   0          5m1s   pod-template-hash=56b4d8597b,run=my-chess
</pre>

```console
kubectl get replicaset -L run # --label-columns
```
<pre>
NAME                  DESIRED   CURRENT   READY   AGE     RUN
my-chess-56b4d8597b   2         2         2       6m41s   my-chess
</pre>

```console
kubectl get replicaset -l run=my-chess # --selector
```
<pre>
NAME                  DESIRED   CURRENT   READY   AGE
my-chess-56b4d8597b   2         2         2       7m13s
</pre>

```console
kubectl label deployment my-chess owner=djkormo
```
<pre>
deployment.extensions/my-chess labeled
</pre>

```console
kubectl get deployment --show-labels
```
<pre>
NAME       DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE   LABELS
my-chess   2         2         2            2           10m   owner=djkormo,run=my-chess
</pre>

```console
kubectl get pods -l run=my-chess
```
<pre>
NAME                        READY   STATUS    RESTARTS   AGE
my-chess-56b4d8597b-9swr4   1/1     Running   0          12m
my-chess-56b4d8597b-s5r2k   1/1     Running   0          12m
</pre>

### Delete pods

```console
kubectl delete pods -l run=my-chess
```
<pre>
pod "my-chess-56b4d8597b-9swr4" deleted
pod "my-chess-56b4d8597b-s5r2k" deleted
</pre>

#### After a while 

```console
kubectl get pods -l run=my-ches
```
<pre>
NAME                        READY   STATUS    RESTARTS   AGE
my-chess-56b4d8597b-jkmpn   1/1     Running   0          38s
my-chess-56b4d8597b-tmqb2   1/1     Running   0          39s
</pre>

#### Delete replicaSet
```console
kubectl get rs -l run=my-chess
```
<pre>
NAME                  DESIRED   CURRENT   READY   AGE
my-chess-56b4d8597b   2         2         2       20m
</pre>

```console
kubectl delete rs -l run=my-chess
```
<pre>
replicaset.extensions "my-chess-56b4d8597b" deleted
</pre>

```console
kubectl get rs -l run=my-chess
```

#### Port-forward

kubectl port-forward deployment/my-chess 80

#### Expose


#### Logs


