### Scaling pods
```console
kubectl create ns scaling
```

<pre>
namespace/scaling created
</pre>

#### Lets switch connection context to a new namespace (scaling)
```console
kubectl config set-context --current --namespace=scaling
```
<pre>
Context "***" modified.
</pre>

### Create pods 
```console
kubectl apply -f apache-php-api.yaml
```
<pre>
deployment.apps/apache-php-api created
</pre>
### Create service for them
```console
kubectl apply -f apache-php-api-service.yaml
```
<pre>
service/apache-php-api created
</pre>
```console
kubectl get all
```
<pre>
NAME                                 READY   STATUS    RESTARTS   AGE
pod/apache-php-api-f6c45cd64-2vfhp   0/1     Running   0          85s
pod/apache-php-api-f6c45cd64-gp55f   0/1     Running   0          85s
pod/apache-php-api-f6c45cd64-p8v79   0/1     Running   0          85s

NAME                     TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
service/apache-php-api   LoadBalancer   10.106.237.12   localhost     80:32590/TCP   103s

NAME                             READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/apache-php-api   0/3     3            0           85s

NAME                                       DESIRED   CURRENT   READY   AGE
replicaset.apps/apache-php-api-f6c45cd64   3         3         0       85s
</pre>

Why is ready equals zero a long time ?

A part of  file apache-php-api.yaml
```yaml
        livenessProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 60
          periodSeconds: 20
        readinessProbe:
          httpGet:
            path: /health
            port: 80
```


After a while 

```console
kubectl get rs
```
<pre>
NAME                       DESIRED   CURRENT   READY   AGE
apache-php-api-f6c45cd64   3         3         3       4m29s
</pre>


### Scale to 5 instances
```console
kubectl scale --replicas=5 deployment/apache-php-api
```
<pre>
  deployment.extensions/apache-php-api sca
</pre>

```console
kubectl get rs,po
```
<pre>
NAME                                             DESIRED   CURRENT   READY   AGE
replicaset.extensions/apache-php-api-f6c45cd64   5         5         5       6m14s

NAME                                 READY   STATUS    RESTARTS   AGE
pod/apache-php-api-f6c45cd64-2vfhp   1/1     Running   0          6m14s
pod/apache-php-api-f6c45cd64-gp55f   1/1     Running   0          6m14s
pod/apache-php-api-f6c45cd64-j7wjk   1/1     Running   0          84s
pod/apache-php-api-f6c45cd64-p8v79   1/1     Running   0          6m14s
pod/apache-php-api-f6c45cd64-wskvn   1/1     Running   0          84s
</pre>


### Autoscaling pods



![Horizontal Pod AutoScaler](hpa.jpg)


#### desiredReplicas = ceil[currentReplicas * ( currentMetricValue / desiredMetricValue )]


### Turning on autoscaling based on CPU utilisation
```console
kubectl apply -f apache-php-api-hpa.yaml
```
<pre>
 horizontalpodautoscaler.autoscaling/apache-php-api created
</pre>

```console
kubectl autoscale deployment apache-php-api --cpu-percent=30 --min=1 --max=10
```
<pre>
  horizontalpodautoscaler.autoscaling/apache-php-api autoscaled
</pre>

```console
kubectl get hpa apache-php-api
```

<pre>
NAME             REFERENCE                   TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
apache-php-api   Deployment/apache-php-api   <unknown>/30%   1         10        5          70s
</pre>


```console
kubectl describe hpa apache-php-api
```
<pre>
Name:                                                  apache-php-api
Namespace:                                             scaling
Labels:                                                <none>
Annotations:                                           <none>
CreationTimestamp:                                     Sun, 22 Dec 2019 21:00:38 +0100
Reference:                                             Deployment/apache-php-api
Metrics:                                               ( current / target )
  resource cpu on pods  (as a percentage of request):  <unknown> / 30%
Min replicas:                                          1
Max replicas:                                          10
Deployment pods:                                       5 current / 0 desired
Conditions:
  Type           Status  Reason                   Message
  ----           ------  ------                   -------
  AbleToScale    True    SucceededGetScale        the HPA controller was able to get the target's current scale
  ScalingActive  False   FailedGetResourceMetric  the HPA was unable to compute the replica count: unable to get metrics for resource cpu: unable to fetch metrics from resource metrics API: the server could not find 
the requested resource (get pods.metrics.k8s.io)
Events:
  Type     Reason                        Age               From                       Message
  ----     ------                        ----              ----                       -------
  Warning  FailedGetResourceMetric       7s (x2 over 22s)  horizontal-pod-autoscaler  unable to get metrics 
for resource cpu: unable to fetch metrics from resource metrics API: the server could not find the requested resource (get pods.metrics.k8s.io)
  Warning  FailedComputeMetricsReplicas  7s (x2 over 22s)  horizontal-pod-autoscaler  failed to get cpu utilization: unable to get metrics for resource cpu: unable to fetch metrics from resource metrics API: the server could not find the requested resource (get pods.metrics.k8s.io)
</pre>


service=13.79.164.182
while true; do curl -X Get $service; done

#### start 
> $ kubectl get hpa apache-php-api
> NAME             REFERENCE                   TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
> apache-php-api   Deployment/apache-php-api   70%/30%   1         10        3          7h39m

$ kubectl get hpa apache-php-api
NAME             REFERENCE                   TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
apache-php-api   Deployment/apache-php-api   43%/30%   1         10        6          7h46m

#### stop


service=13.79.164.182
curl -s "http://$service/?[1-1000]"

### using dedicated  load test 
service=13.79.149.180

kubectl run --image=djkormo/loadtest loadtest-app \
--generator=run-pod/v1 --env ENDPOINT=http://$service \
--env METHOD=GET  \
--env PAYLOAD='{"Test": "test@whitehouse.gov"}'

### using pod inside
```console

kubectl run load-generator --generator=run-pod/v1 \
  --limits="cpu=200m,memory=100Mi" \
  --requests="cpu=100m,memory=50Mi" \
  --rm -i --tty --image busybox -- sh

```

<pre>
while true; do wget -q -O- http://apache-php-api.default.svc.cluster.local/pi.php; done
</pre>

#### Based on  https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/

#### https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#support-for-cooldown-delay
