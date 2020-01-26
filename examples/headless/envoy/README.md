Using custom  loadbalancer with Kubernetes headless service



```console
kubectl create ns envoy
```
<pre>
namespace/envoy created
</pre>


```console
kubectl config set-context --current --namespace=envoy

```
<pre>
Context "***" modified.
</pre>


```console
kubectl apply -f headless-service.yaml 
```
<pre>
service/myapp created
</pre>


```console
kubectl run headless-test-$RANDOM --generator=run-pod/v1 \
  --limits="cpu=200m,memory=100Mi" \
  --requests="cpu=100m,memory=50Mi" \
--rm  -it --image eddiehale/utils bash
```

Inside headless-test pod run

```console
nslookup myapp
Server:         10.96.0.10
Address:        10.96.0.10#53
```
<pre>
** server can't find myapp: NXDOMAIN
</pre>

Lets deploy 5 instances of pod behind our myapp service
```console
kubectl apply -f my-deployment.yaml
```
<pre>
deployment.apps/myapp-deployment created
</pre>

```console
kubectl get pods 
```
<pre>
NAME                                READY   STATUS    RESTARTS   AGE     IP          NODE             NOMINATED NODE   READINESS GATES
myapp-deployment-75964f68c5-5wg56   1/1     Running   0          5m19s   10.1.2.45   docker-desktop   <none>           <none>
myapp-deployment-75964f68c5-776qm   1/1     Running   0          5m19s   10.1.2.44   docker-desktop   <none>           <none>
myapp-deployment-75964f68c5-fc7xb   1/1     Running   0          5m19s   10.1.2.42   docker-desktop   <none>           <none>
myapp-deployment-75964f68c5-xjrfx   1/1     Running   0          5m19s   10.1.2.43   docker-desktop   <none>           <none>
myapp-deployment-75964f68c5-xk6rj   1/1     Running   0          5m19s   10.1.2.41   docker-desktop   <none>           <none>
</pre>


```console
kubectl run headless-test-$RANDOM --generator=run-pod/v1 \
  --limits="cpu=200m,memory=100Mi" \
  --requests="cpu=100m,memory=50Mi" \
--rm  -it --image eddiehale/utils bash
```
 
Inside headless-test pod run
```console
nslookup myapp
```
<pre>
Server:         10.96.0.10
Address:        10.96.0.10#53

Name:   myapp.envoy.svc.cluster.local
Address: 10.1.2.45
Name:   myapp.envoy.svc.cluster.local
Address: 10.1.2.44
Name:   myapp.envoy.svc.cluster.local
Address: 10.1.2.43
Name:   myapp.envoy.svc.cluster.local
Address: 10.1.2.42
Name:   myapp.envoy.svc.cluster.local
Address: 10.1.2.41
</pre>

```console
curl myapp:80
```
<pre>
Hello, World from Docker! <br><img src="https://www.docker.com/sites/default/files/horizontal.png"><br>  Displayed at: myapp-deployment-75964f68c5-xk6rj<br>Application version : 1.0     !<br>
</pre>

```console
curl myapp:80 #serveral times
```
<pre>
Hello, World from Docker! <br><img src="https://www.docker.com/sites/default/files/horizontal.png"><br>  Displayed at: myapp-deployment-75964f68c5-fc7xb<br>Application version : 1.0     !<br>

Hello, World from Docker! <br><img src="https://www.docker.com/sites/default/files/horizontal.png"><br>  Displayed at: 
myapp-deployment-75964f68c5-xjrfx<br>Application version : 1.0     !<br>

Hello, World from Docker! <br><img src="https://www.docker.com/sites/default/files/horizontal.png"><br>  Displayed at: myapp-deployment-75964f68c5-5wg56<br>Application version : 1.0     !<br>

Hello, World from Docker! <br><img src="https://www.docker.com/sites/default/files/horizontal.png"><br>  Displayed at: myapp-deployment-75964f68c5-xjrfx<br>Application version : 1.0     !<br>

Hello, World from Docker! <br><img src="https://www.docker.com/sites/default/files/horizontal.png"><br>  Displayed at: myapp-deployment-75964f68c5-fc7xb<br>Application version : 1.0     !<br>

Hello, World from Docker! <br><img src="https://www.docker.com/sites/default/files/horizontal.png"><br>  Displayed at: myapp-deployment-75964f68c5-776qm<br>Application version : 1.0     !<br> 

</pre>


```console
exit
```
<pre>
Session ended, resume using 'kubectl attach headless-test-2578 -c headless-test-2578 -i -t' command when the pod is running
pod "headless-test-2578" deleted
</pre>

```console
kubectl apply -f envoy-deployment.yaml 
```
<pre>
service/myapp-envoy created
deployment.extensions/myapp-envoy created
</pre>


```
kubectl get pod -l app=myapp-envoy
```
<pre>
NAME                        READY   STATUS    RESTARTS   AGE
myapp-envoy-9fcfbfc-qfh8l   1/1     Running   0          112s
</pre>

```console
kubectl get svc
```
<pre>
NAME          TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
myapp         ClusterIP   None           <none>        80/TCP    8m52s
myapp-envoy   ClusterIP   10.105.28.32   <none>        80/TCP    2m24s
</pre>


Service myapp-envoy point to pod myapp-envoy-9fcfbfc-qfh8l  (singleton at this moment)

In pod definition we use envoy images pointing to service myapp (headless service)
```yaml
containers:
      - name: myapp-envoy
        image: djkormo/myapp-envoy:v1
        imagePullPolicy: Always
        env:
        - name: "ENVOY_LB_ALG"
          value: "LEAST_REQUEST"
        - name: "SERVICE_NAME"
          value: "myapp"
```


```console
kubectl run headless-test-$RANDOM --generator=run-pod/v1 \
  --limits="cpu=200m,memory=100Mi" \
  --requests="cpu=100m,memory=50Mi" \
--rm  -it --image eddiehale/utils bash
```



Inside the pod run
```bash
nslookup myapp-envoy
```
<pre>
Server:         10.96.0.10
Address:        10.96.0.10#53

Name:   myapp-envoy.envoy.svc.cluster.local
Address: 10.105.28.32
</pre>

```bash
curl myapp-envoy:80 # several times
```
<pre>
Hello, World from Docker! <br><img src="https://www.docker.com/sites/default/files/horizontal.png"><br>  Displayed at: myapp-deployment-75964f68c5-776qm<br>Application version : 1.0     !<br>

Hello, World from Docker! <br><img src="https://www.docker.com/sites/default/files/horizontal.png"><br>  Displayed at: myapp-deployment-75964f68c5-xjrfx<br>Application version : 1.0     !<br>

Hello, World from Docker! <br><img src="https://www.docker.com/sites/default/files/horizontal.png"><br>  Displayed at: myapp-deployment-75964f68c5-5wg56<br>Application version : 1.0     !<br>
Hello, World from Docker! <br><img src="https://www.docker.com/sites/default/files/horizontal.png"><br>  Displayed at: myapp-deployment-75964f68c5-xk6rj<br>Application version : 1.0     !<br>

Hello, World from Docker! <br><img src="https://www.docker.com/sites/default/files/horizontal.png"><br>  Displayed at: myapp-deployment-75964f68c5-5wg56<br>Application version : 1.0     !<br>

Hello, World from Docker! <br><img src="https://www.docker.com/sites/default/files/horizontal.png"><br>  Displayed at: myapp-deployment-75964f68c5-xk6rj<br>Application version : 1.0     !<br>

Hello, World from Docker! <br><img src="https://www.docker.com/sites/default/files/horizontal.png"><br>  Displayed at: myapp-deployment-75964f68c5-xjrfx<br>Application version : 1.0     !<br>
</pre>

```bash
exit
```
<pre>
Session ended, resume using 'kubectl attach headless-test-24708 -c headless-test-24708 -i -t' command when the pod is running
pod "headless-test-24708" deleted
</pre>


kubectl port-forward pods/myapp-envoy-9fcfbfc-qfh8l 8099:80 9901:9901

Loot at 
http://localhost:8099/

and

http://localhost:9901/



Clean up our experiment


```console
kubectl delete ns envoy
```
<pre>
namespace "envoy" deleted
</pre>


Literature:

https://blog.markvincze.com/how-to-use-envoy-as-a-load-balancer-in-kubernetes/

