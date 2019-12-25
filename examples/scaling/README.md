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
kubectl apply -f apache-php-api-deployment.yaml
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

A part of  file apache-php-api-deployment.yaml
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
deployment.extensions/apache-php-api scaled
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
apiVersion: autoscaling/v2beta2
kind: HorizontalPodAutoscaler
```
<pre>
horizontalpodautoscaler.autoscaling/apache-php-api created
</pre>

```console
kubectl autoscale deployment apache-php-api --cpu-percent=20 --min=1 --max=10
```
<pre>
horizontalpodautoscaler.autoscaling/apache-php-api autoscaled
</pre>

```console
kubectl get hpa apache-php-api
```

<pre>
NAME             REFERENCE                   TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
apache-php-api   Deployment/apache-php-api   <unknown>/20%   1         10        5          70s
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
  resource cpu on pods  (as a percentage of request):  <unknown> / 20%
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


### Metrics server is lossing on my local k8s cluster.

Cookbook to install metric server

curl  https://raw.githubusercontent.com/kubernetes-sigs/metrics-server/master/deploy/1.8%2B/metrics-server-deployment.yaml > metrics-server-deployment.yaml


#### patch yaml file by adding after  imagePullPolicy: Always
<pre>
  command:
    - /metrics-server
    - --kubelet-insecure-tls
    - --cert-dir=/tmp
    - --secure-port=4443
    - --kubelet-preferred-address-types=InternalIP
</pre>

#### Save the file and deploy on cluster in kube-system namespace
```console
kubectl apply -n kube-system -f metrics-server-deployment.yaml
```
<pre>
serviceaccount/metrics-server unchanged
deployment.apps/metrics-server configured
</pre>
```console
kubectl get pods -n kube-system |grep metrics
```
<pre>
metrics-server-564fbf75b5-dtr2v          1/1     Running   0          98s
</pre>
```console
kubectl logs metrics-server-564fbf75b5-dtr2v -n kube-system
```
<pre>
I1222 22:06:38.041311       1 serving.go:312] Generated self-signed cert (/tmp/apiserver.crt, /tmp/apiserver.key)
I1222 22:06:39.019465       1 manager.go:95] Scraping metrics from 0 sources
I1222 22:06:39.019657       1 manager.go:148] ScrapeMetrics: time: 2µs, nodes: 0, pods: 0        
I1222 22:06:39.031001       1 secure_serving.go:116] Serving securely on [::]:4443
I1222 22:07:39.020001       1 manager.go:95] Scraping metrics from 1 sources
I1222 22:07:39.027658       1 manager.go:120] Querying source: kubelet_summary:docker-desktop    
I1222 22:07:39.088902       1 manager.go:148] ScrapeMetrics: time: 68.8058ms, nodes: 1, pods: 23 
I1222 22:08:39.019769       1 manager.go:95] Scraping metrics from 1 sources
I1222 22:08:39.023063       1 manager.go:120] Querying source: kubelet_summary:docker-desktop    
I1222 22:08:39.057139       1 manager.go:148] ScrapeMetrics: time: 37.2889ms, nodes: 1, pods: 23 
</pre>

```console
kubectl top nodes
```
<pre>
Error from server (NotFound): the server could not find the requested resource (get services http:heapster:)
</pre>
```console
kubectl to pods
```
<pre>
Error from server (NotFound): the server could not find the requested resource (get services http:heapster:)
</pre>


The final solution was to install metrics server via helm 

```console
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm install metrics stable/metrics-server  --namespace kube-system --set args={--kubelet-insecure-tls}
```

After all we have
```console
kubectl get hpa
```
<pre>
NAME             REFERENCE                   TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
apache-php-api   Deployment/apache-php-api   1%/30%    1         10        1          38h
</pre>

#### Lets try to stress our deployment


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

HPA_SERVICE=apache-php-api:2020

kubectl run --image=djkormo/loadtest loadtest-app \
--generator=run-pod/v1 --restart="Never" \
--image-pull-policy Always \
--env ENDPOINT=http://$HPA_SERVICE \
--env METHOD=GET  \
--env PAYLOAD='{"Test": "test@whitehouse.gov"}' \
--env PHASES=3

### Testing online ...
```console
kubectl logs loadtest-app; kubectl get hpa; kubectl get pod loadtest-app
```

History of pod instances number
```console
kubectl get hpa -w
```

NAME             REFERENCE                   TARGETS    MINPODS   MAXPODS   REPLICAS   AGE
apache-php-api   Deployment/apache-php-api   141%/20%   1         10        4          18m
apache-php-api   Deployment/apache-php-api   141%/20%   1         10        8          18m
apache-php-api   Deployment/apache-php-api   150%/20%   1         10        8          18m
apache-php-api   Deployment/apache-php-api   150%/20%   1         10        8          19m
apache-php-api   Deployment/apache-php-api   151%/20%   1         10        10         20m
apache-php-api   Deployment/apache-php-api   1%/20%     1         10        10         20m
apache-php-api   Deployment/apache-php-api   129%/20%   1         10        10         21m
apache-php-api   Deployment/apache-php-api   146%/20%   1         10        10         22m
apache-php-api   Deployment/apache-php-api   129%/20%   1         10        10         23m
apache-php-api   Deployment/apache-php-api   1%/20%     1         10        10         23m
apache-php-api   Deployment/apache-php-api   16%/20%    1         10        10         25m
apache-php-api   Deployment/apache-php-api   31%/20%    1         10        10         26m
apache-php-api   Deployment/apache-php-api   23%/20%    1         10        10         27m
apache-php-api   Deployment/apache-php-api   16%/20%    1         10        10         28m
apache-php-api   Deployment/apache-php-api   1%/20%     1         10        10         29m
apache-php-api   Deployment/apache-php-api   1%/20%     1         10        10         33m
apache-php-api   Deployment/apache-php-api   1%/20%     1         10        8          33m
apache-php-api   Deployment/apache-php-api   1%/20%     1         10        8          34m
apache-php-api   Deployment/apache-php-api   2%/20%     1         10        1          34m
apache-php-api   Deployment/apache-php-api   1%/20%     1         10        1          37m
apache-php-api   Deployment/apache-php-api   2%/20%     1         10        1          38m

Instead of using on time run pod, we can experiment with kubernetes job objects.





### using pod inside
```console

kubectl run load-generator --generator=run-pod/v1 \
  --limits="cpu=200m,memory=100Mi" \
  --requests="cpu=100m,memory=50Mi" \
  --rm -i --tty --image busybox -- sh

```

<pre>
while true; do wget -O- http://apache-php-api:2020; done
</pre>
<pre>
Connecting to apache-php-api:2020 (10.96.213.227:2020)
</pre>




#### Based on  https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/

##### https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/support-for-cooldown-delay

##### https://github.com/kubernetes-sigs/metrics-server/issues/317

##### https://aws.amazon.com/premiumsupport/knowledge-center/eks-metrics-server-pod-autoscaler/?nc1=h_ls


##### https://blog.codewithdan.com/enabling-metrics-server-for-kubernetes-on-docker-desktop/

##### https://github.com/kubernetes-sigs/metrics-server/issues/167

