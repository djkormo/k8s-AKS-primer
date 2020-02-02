## Simple implementation of chaos monkey in Kubernetes



Choosing one pod to kill
```console
kubectl    get pods --namespace "kube-system" -o 'jsonpath={.items[*].metadata.name}' |tr " " "\n" |shuf |head -n 1
```

```bash
#!/bin/bash

# Randomly delete pods in a Kubernetes namespace.
: ${DELAY:=30}
: ${NAMESPACE:=default}
: ${EXCLUDEDAPPS:=k8s-chaos-monkey}
# endless loop 
while true; do
  PODNAME=$(kubectl   get pods --field-selector=status.phase=Running -l app!=$EXCLUDEDAPPS --namespace $NAMESPACE -o 'jsonpath={.items[*].metadata.name}' |tr " " "\n" |shuf |head -n 1)
  echo "NAMESPACE :$NAMESPACE"
  echo "PODNAME :$PODNAME"
  NOW=$(date)
  echo "Current date: $NOW"
  # checking if there is a pod to delete
  if [[ -z "${PODNAME}" ]]; then
    echo "There are no pods to delete"
  else
    kubectl delete pod $PODNAME -n $NAMESPACE
  fi

  echo "DELAY: $DELAY seconds" 
  sleep $DELAY
done
```



Deploy chaos monkey pod
```
kubectl apply -f chaos-deployment.yaml 
```
<pre>
deployment.extensions/k8s-chaos-monkey created
</pre>

What is inside chaos-deployment.yaml file

```yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: k8s-chaos-monkey
spec:
  selector:
    matchLabels:
      app: k8s-chaos-monkey
  replicas: 1
  template:
    metadata:
      labels:
        app: k8s-chaos-monkey
    spec:
      containers:
      - name: k8-pod-chaos-monkey
        image: djkormo/chaos-monkey
        imagePullPolicy: Always
        env:
         - name: NAMESPACE
           value: "default"
         - name: DELAY
           value: "10"
         - name: EXLUDEDAPPS
           value: "k8s-chaos-monkey"
        resources:
          limits:
            cpu: "0.1"
            memory: "50Mi"
          requests:
            cpu: "0.1"
            memory: "50Mi"
```

In configuration we choose NAMESPACE, DELAY (in second) and EXCLUDED value for app label to prevent killing itself

One randomly pod is deleted in endless loop for every DETAL seconds

```console
kubectl get pods --show-labels
```
<pre>
NAME                               READY   STATUS    RESTARTS   AGE    LABELS
k8s-chaos-monkey-ddc978b78-gr8s2   1/1     Running   0          3m26s   app=k8s-chaos-monkey,pod-template-hash=ddc978b78
</pre>


```console
kubectl logs  -l app=k8s-chaos-monkey
```
<pre>
NAMESPACE :default
PODNAME :
Current date: Sun Feb  2 17:27:45 UTC 2020
There are no pods to delete
DELAY: 10 seconds
NAMESPACE :default
PODNAME :
Current date: Sun Feb  2 17:27:57 UTC 2020
There are no pods to delete
DELAY: 10 seconds
</pre>

Nothing to delete at the moment

Deploy 20 instances of pods with example web application written in php.

```console
kubectl apply -f php-hello-deployment.yaml 
```
<pre>
deployment.apps/php-hello created
</pre>

And service for application
```console
kubectl apply -f php-hello-service.yaml 
```
<pre>
service/php-hello created
</pre>

Now our chaos monkey pod is working

```console
kubectl logs  -l app=k8s-chaos-monkey
```
<pre>
DELAY: 10 seconds
NAMESPACE :default
PODNAME :php-hello-589bf78cc7-rgq8j
Current date: Sun Feb  2 17:33:15 UTC 2020
pod "php-hello-589bf78cc7-rgq8j" deleted
DELAY: 10 seconds
NAMESPACE :default
PODNAME :php-hello-589bf78cc7-ss75k
Current date: Sun Feb  2 17:33:35 UTC 2020
pod "php-hello-589bf78cc7-ss75k" deleted
</pre>

Look closely on AGE value of particular pods. 

```
kubectl get all -l app=php-hello
```
<pre>
NAME                             READY   STATUS    RESTARTS   AGE
pod/php-hello-589bf78cc7-5gcb7   1/1     Running   0          2m13s
pod/php-hello-589bf78cc7-5jhvh   1/1     Running   0          15s
pod/php-hello-589bf78cc7-68glp   1/1     Running   0          4m6s
pod/php-hello-589bf78cc7-68ks7   1/1     Running   0          65s
pod/php-hello-589bf78cc7-6wx9j   1/1     Running   0          31s
pod/php-hello-589bf78cc7-ckvld   1/1     Running   0          3m49s
pod/php-hello-589bf78cc7-cnkwj   1/1     Running   0          8m12s
pod/php-hello-589bf78cc7-cnrbl   1/1     Running   0          3m5s
pod/php-hello-589bf78cc7-jfkzf   1/1     Running   0          8m12s
pod/php-hello-589bf78cc7-jw2pz   1/1     Running   0          7m54s
pod/php-hello-589bf78cc7-kphsm   1/1     Running   0          6m43s
pod/php-hello-589bf78cc7-ldb9t   1/1     Running   0          5m25s
pod/php-hello-589bf78cc7-m9n28   1/1     Running   0          104s
pod/php-hello-589bf78cc7-p59gr   1/1     Running   0          4m25s
pod/php-hello-589bf78cc7-pkt7z   1/1     Running   0          7m18s
pod/php-hello-589bf78cc7-t8wjn   1/1     Running   0          48s
pod/php-hello-589bf78cc7-tc2nd   1/1     Running   0          2m29s
pod/php-hello-589bf78cc7-wkcgb   1/1     Running   0          5m4s
pod/php-hello-589bf78cc7-x4s5h   1/1     Running   0          8m12s
pod/php-hello-589bf78cc7-xv89j   1/1     Running   0          86s

NAME                TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
service/php-hello   LoadBalancer   10.109.114.27   localhost     8888:30232/TCP   86s

NAME                                   DESIRED   CURRENT   READY   AGE
replicaset.apps/php-hello-589bf78cc7   20        20        20      8m12s

</pre>

You can also see changes by using -w (watch) 
```
kubectl get pods -l app=php-hello -w
```
<pre>
...
php-hello-589bf78cc7-cnrbl   0/1     Terminating         0          5m16s
php-hello-589bf78cc7-cnrbl   0/1     Terminating         0          5m17s
php-hello-589bf78cc7-jw8dx   0/1     Running             0          5s
php-hello-589bf78cc7-jw8dx   1/1     Running             0          8s
php-hello-589bf78cc7-cnrbl   0/1     Terminating         0          5m26s
php-hello-589bf78cc7-cnrbl   0/1     Terminating         0          5m26s
php-hello-589bf78cc7-2m5jd   1/1     Terminating         0          100s
php-hello-589bf78cc7-kdf97   0/1     Pending             0          0s
php-hello-589bf78cc7-kdf97   0/1     Pending             0          0s
php-hello-589bf78cc7-kdf97   0/1     ContainerCreating   0          0s
php-hello-589bf78cc7-2m5jd   0/1     Terminating         0          102s
php-hello-589bf78cc7-2m5jd   0/1     Terminating         0          103s
php-hello-589bf78cc7-kdf97   0/1     Running             0          5s
php-hello-589bf78cc7-2m5jd   0/1     Terminating         0          105s
php-hello-589bf78cc7-2m5jd   0/1     Terminating         0          105s
php-hello-589bf78cc7-kdf97   1/1     Running             0          9s
...
</pre>


Based on:


https://hub.docker.com/r/jnewland/kubernetes-pod-chaos-monkey/


Literature:

https://github.com/Netflix/chaosmonkey

https://github.com/jnewland/kubernetes-pod-chaos-monkey

https://www.gremlin.com/chaos-monkey/chaos-monkey-alternatives/kubernetes/

https://medium.com/faun/failures-are-inevitable-even-a-strongest-platform-with-concrete-operations-infrastructure-can-7d0c016430c6

https://kubernetes.io/docs/tasks/tools/install-kubectl/



