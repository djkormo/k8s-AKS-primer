## Types of health checks

Kubernetes gives you two types of health checks: **readiness** and **liveness**, and it is important to understand the differences between the two, and their uses.

### Readiness


Readiness probes are designed to let Kubernetes know when your app is ready to serve traffic. Kubernetes makes sure the readiness probe passes before allowing a service to send traffic to the pod. If a readiness probe starts to fail, Kubernetes stops sending traffic to the pod until it passes.

![Readiness|512x397,50%](google-kubernetes-probe-readiness.gif).

### Liveness

Liveness probes let Kubernetes know if your app is alive or dead. If you app is alive, then Kubernetes leaves it alone. If your app is dead, Kubernetes removes the Pod and starts a new one to replace it.

![Liveness|512x397,50%](google-kubernetes-probe-liveness.gif).

**Type of Probes** 
The next step is to define the probes that test readiness and liveness. There are three types of probes: 
- HTTP
- Command
- TCP

You can use any of them for liveness and readiness checks.

**HTTP**

HTTP probes are probably the most common type of custom liveness probe. Even if your app isn’t an HTTP server, you can create a lightweight HTTP server inside your app to respond to the liveness probe. Kubernetes pings a path, and if it gets an HTTP response in the 200 or 300 range, it marks the app as healthy. Otherwise it is marked as unhealthy.


**Command**

For command probes, Kubernetes runs a command inside your container. If the command returns with exit code 0, then the container is marked as healthy. Otherwise, it is marked unhealthy. This type of probe is useful when you can’t or don’t want to run an HTTP server, but can run a command that can check whether or not your app is healthy.

**TCP**

The last type of probe is the TCP probe, where Kubernetes tries to establish a TCP connection on the specified port. If it can establish a connection, the container is considered healthy; if it can’t it is considered unhealthy.

TCP probes come in handy if you have a scenario where HTTP probes or command probe don’t work well. For example, a gRPC or FTP service is a prime candidate for this type of probe.


## It is time to experiment.


```console
kubectl apply -f ./exec-liveness.yaml
```
<pre>
pod/liveness-exec created
</pre>

```console
kubectl get pod liveness-exec
```
<pre>
NAME            READY   STATUS    RESTARTS   AGE
liveness-exec   1/1     Running   1          108s

NAME            READY   STATUS    RESTARTS   AGE
liveness-exec   1/1     Running   2          3m6s

</pre>
#### Why is the pod in restarting mode ?

Lets look inside pod definition
```yaml
...
containers:
  - name: liveness
    image: k8s.gcr.io/busybox
    args:
    - /bin/sh
    - -c
    - touch /tmp/healthy; sleep 30; rm -rf /tmp/healthy; sleep 600
    livenessProbe:
      exec:
        command:
        - cat
        - /tmp/healthy
      initialDelaySeconds: 5
      periodSeconds: 5
...

```


```
kubectl describe pod liveness-exec |grep Events -A20
```
<pre>
Events:
  Type     Reason     Age                    From                               Message
  ----     ------     ----                   ----                               -------
  Normal   Scheduled  9m37s                  default-scheduler                  Successfully assigned my-app/liveness-exec to aks-nodepool1-16191604-1
  Normal   Pulled     7m5s (x3 over 9m35s)   kubelet, aks-nodepool1-16191604-1  Successfully pulled image "k8s.gcr.io/busybox"
  Normal   Created    7m4s (x3 over 9m35s)   kubelet, aks-nodepool1-16191604-1  Created container liveness
  Normal   Started    7m4s (x3 over 9m34s)   kubelet, aks-nodepool1-16191604-1  Started container liveness
  Warning  Unhealthy  6m21s (x9 over 9m1s)   kubelet, aks-nodepool1-16191604-1  Liveness probe failed: cat: can't open '/tmp/healthy': No such file or directory
  Normal   Killing    6m21s (x3 over 8m51s)  kubelet, aks-nodepool1-16191604-1  Container liveness failed liveness probe, will be restarted
  Normal   Pulling    4m35s (x5 over 9m36s)  kubelet, aks-nodepool1-16191604-1  Pulling image "k8s.gcr.io/busybox"
</pre>

### Examples from excellent book "Kubernetes up and running".

```console
kubectl apply -f kuard-deploy-heath-check.yaml
```
<pre>
service/kuard-health created
deployment.apps/kuard-health-deployment created
</pre>

#### --namespace filters object from on namespace
```console
kubectl get all --namespace=default
```
<pre>
NAME                                           READY   STATUS    RESTARTS   AGE
pod/kuard-health-deployment-68d9766d56-89v27   1/1     Running   0          105s
pod/kuard-health-deployment-68d9766d56-thj9p   1/1     Running   0          105s
pod/liveness-exec                              1/1     Running   9          18m

NAME                   TYPE       CLUSTER-IP    EXTERNAL-IP   PORT(S)          AGE
service/kuard-health   NodePort   10.0.211.24   <none>        8080:31885/TCP   106s

NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/kuard-health-deployment   2/2     2            2           106s

NAME                                                 DESIRED   CURRENT   READY   AGE
replicaset.apps/kuard-health-deployment-68d9766d56   2         2         2       106s
</pre>

```console
kubectl port-forward deploy/kuard-health-deployment 8080:8080
```
<pre>
Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080
Handling connection for 8080
Handling connection for 8080
</pre>

```console
kubectl get pods
```
<pre>
NAME                                       READY   STATUS             RESTARTS   AGE
kuard-health-deployment-68d9766d56-89v27   1/1     Running            3          11m
kuard-health-deployment-68d9766d56-thj9p   1/1     Running            0          11m
liveness-exec                              0/1     CrashLoopBackOff   11         27m
</pre>

```console
kubectl describe pod kuard-health-deployment-68d9766d56-89v27 |grep Events -A20
```
<pre>
Events:
  Type     Reason     Age                   From                               Message
  ----     ------     ----                  ----                               -------
  Normal   Scheduled  19m                   default-scheduler                  Successfully assigned my-app/kuard-health-deployment-68d9766d56-89v27 to aks-nodepool1-16191604-1
  Warning  BackOff    9m4s (x2 over 9m11s)  kubelet, aks-nodepool1-16191604-1  Back-off restarting failed container
  Normal   Killing    3m44s                 kubelet, aks-nodepool1-16191604-1  Container kuard-health failed liveness probe, will be restarted
  Warning  Unhealthy  3m44s (x3 over 4m4s)  kubelet, aks-nodepool1-16191604-1  Liveness probe failed: HTTP probe
failed with statuscode: 500
  Normal   Pulling    3m43s (x4 over 19m)   kubelet, aks-nodepool1-16191604-1  Pulling image "djkormo/kuard"
  Normal   Pulled     3m42s (x4 over 19m)   kubelet, aks-nodepool1-16191604-1  Successfully pulled image "djkormo/kuard"
  Normal   Created    3m42s (x4 over 19m)   kubelet, aks-nodepool1-16191604-1  Created container kuard-health
  Normal   Started    3m42s (x4 over 19m)   kubelet, aks-nodepool1-16191604-1  Started container kuard-health
</pre>

## Resources reqests and limits


**requests.cpu** is the maximum combined CPU requests in millicores for all the containers in the Namespace. In the above example, you can have 50 containers with 10m requests, five containers with 100m requests, or even one container with a 500m request. As long as the total requested CPU in the Namespace is less than 500m!

**requests.memory** is the maximum combined Memory requests for all the containers in the Namespace. In the above example, you can have 50 containers with 2MiB requests, five containers with 20MiB CPU requests, or even a single container with a 100MiB request. As long as the total requested Memory in the Namespace is less than 100MiB!

**limits.cpu** is the maximum combined CPU limits for all the containers in the Namespace. It’s just like requests.cpu but for the limit.

**limits.memory** is the maximum combined Memory limits for all containers in the Namespace. It’s just like requests.memory but for the limit.

```console
kubectl describe nodes |grep "Allocated resources:" -A7
```
<pre>
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource                       Requests      Limits
  --------                       --------      ------
  cpu                            1155m (59%)   900m (46%)
  memory                         1296Mi (60%)  2170Mi (101%)
  ephemeral-storage              0 (0%)        0 (0%)
  attachable-volumes-azure-disk  0             0
</pre>

### Creating new namespace
```console
kubectl create namespace my-app
```
<pre>
namespace/my-app created
</pre>

### Lets create quotas.yaml file for restrictions for one namespace

Inside of file we have....
<pre>

cat <<EOF > quotas.yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-resources
spec:
  hard:
    pods: "20"
    requests.cpu: "2"
    requests.memory: 2Gi
    limits.cpu: "4"
    limits.memory: 4Gi
    requests.nvidia.com/gpu: 4
EOF
</pre>


### Applying quotas to namespace
```console
kubectl apply -f ./quotas.yaml --namespace=my-app
```
<pre>
resourcequota/compute-resources created
</pre>

Now we are ready to control bad behaviour of our application


#### Lets switch connection context to a new namespace (my-app)
```console
kubectl config set-context --current --namespace=my-app
```
<pre>
Context "***" modified.
</pre>

I worth to check if our namespace is empty
```console
kubectl get all
```
<pre>
No resources found.
</pre>
```console
kubectl apply -f kuard-deploy-heath-check.yaml 
```
<pre>
service/kuard-health created
deployment.apps/kuard-health-deployment created
</pre>

```console
kubectl get all
```
<pre>
NAME                                           READY   STATUS    RESTARTS   AGE
pod/kuard-health-deployment-68d9766d56-s9xst   1/1     Running   0          30s
pod/kuard-health-deployment-68d9766d56-wtqcq   1/1     Running   0          30s

NAME                   TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
service/kuard-health   NodePort   10.106.107.160   <none>        8080:30454/TCP   30s

NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/kuard-health-deployment   2/2     2            2           30s

NAME                                                 DESIRED   CURRENT   READY   AGE
replicaset.apps/kuard-health-deployment-68d9766d56   2         2         2       30s

</pre>

```console
kubectl get pods
```
Our pods have zero restart counters
<pre>
NAME                                       READY   STATUS    RESTARTS   AGE  
kuard-health-deployment-68d9766d56-s9xst   1/1     Running   0          9m14s
kuard-health-deployment-68d9766d56-wtqcq   1/1     Running   0          9m14s
</pre>

What is resources utilisation

```console
kubectl describe ns my-app
```
<pre>
Name:         my-app
Labels:       <none>
Annotations:  <none>
Status:       Active

Resource Quotas
 Name:                    compute-resources
 Resource                 Used   Hard
 --------                 ---    ---
 limits.cpu               400m   4
 limits.memory            200Mi  4Gi
 pods                     2      20
 requests.cpu             200m   2
 requests.memory          100Mi  2Gi
 requests.nvidia.com/gpu  0      4

No resource limits.
</pre>


```console
kubectl port-forward deployment/kuard-health-deployment 8080:8080
```
<pre>
Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080
Handling connection for 8080
</pre>


Open the browser at http://localhost:8080


#### Trying to allocate memory 

![kuard memory allocation](kuard_memory.png)

```console
kubectl get pods
```
<pre>
NAME                                       READY   STATUS    RESTARTS   AGE
kuard-health-deployment-68d9766d56-s9xst   1/1     Running   0          18m
kuard-health-deployment-68d9766d56-wtqcq   1/1     Running   2          18m
</pre>



```console
kubectl describe pods kuard-health-deployment-68d9766d56-wtqcq |grep -A10 Back-off
```

<pre>
  Warning  BackOff    2m8s (x2 over 2m9s)  kubelet, docker-desktop  Back-off restarting failed container
  Normal   Pulling    117s (x3 over 20m)   kubelet, docker-desktop  Pulling image "djkormo/kuard"
  Normal   Pulled     114s (x3 over 20m)   kubelet, docker-desktop  Successfully pulled image "djkormo/kuard"
  Normal   Created    114s (x3 over 20m)   kubelet, docker-desktop  Created container kuard-health
  Normal   Started    114s (x3 over 20m)   kubelet, docker-desktop  Started container kuard-health
</pre>

#### Putting liveness to status 500

![kuard liveness](kuard_liveness.png)

Press 10
Probe will fail for next 10 calls
Repeat twice

```console
kubectl get pod --namespace=my-app # remember then name of our namespace
```

<pre>
NAME                                       READY   STATUS    RESTARTS   AGE
kuard-health-deployment-68d9766d56-s9xst   1/1     Running   0          129m
kuard-health-deployment-68d9766d56-wtqcq   1/1     Running   4          129m
</pre>

```console
kubectl describe pods kuard-health-deployment-68d9766d56-wtqcq |grep "Liveness probe" -A10
```

<pre>
  Warning  Unhealthy  54s (x9 over 2m44s)  kubelet, docker-desktop  Liveness probe failed: HTTP probe failed with statuscode: 500
  Normal   Killing    54s (x3 over 2m24s)  kubelet, docker-desktop  Container kuard-health failed liveness probe, will be restarted
  Normal   Pulled     51s (x6 over 130m)   kubelet, docker-desktop  Successfully pulled image "djkormo/kuard"
  Normal   Created    51s (x6 over 130m)   kubelet, docker-desktop  Created container kuard-health
  Normal   Started    51s (x6 over 130m)   kubelet, docker-desktop  Started container kuard-health
</pre>


Based on 
https://cloud.google.com/blog/products/gcp/kubernetes-best-practices-setting-up-health-checks-with-readiness-and-liveness-probes

https://cloud.google.com/blog/products/gcp/kubernetes-best-practices-resource-requests-and-limits

https://github.com/kubernetes-up-and-running
