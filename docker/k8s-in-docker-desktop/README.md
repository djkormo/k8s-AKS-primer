###Installing Docker Desktop



![Docker Desktop](docker-desktop.png)


### Enabling Kubernetes




![Enabling Kubernetes](k8s-enable.png)


The installation process begins

![Enabling Kubernetes](k8s-installing.png)

After a while

![Enabling Kubernetes](k8s-done.png)


Checking cluster health

```console
kubectl cluster-info
```


![Cluster info](cluster-info.png)

For new k8s user lets try to use cluster from GUI instead of cli (kubectl)

### Adding dashboard

```console
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml
```
<pre>
secret/kubernetes-dashboard-certs unchanged
serviceaccount/kubernetes-dashboard unchanged
role.rbac.authorization.k8s.io/kubernetes-dashboard-minimal unchanged
rolebinding.rbac.authorization.k8s.io/kubernetes-dashboard-minimal unchanged
deployment.apps/kubernetes-dashboard unchanged
service/kubernetes-dashboard unchanged
</pre>

```console
kubectl proxy
```
<pre>
Starting to serve on 127.0.0.1:8001
</pre>

Dashboard is accesible at

http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/


Set the token menu

![Dashboard Token](dashboard-token.png)


The way to get the token from kubernetes cluster

In Bash
```console
TOKEN=$(kubectl -n kube-system describe secret default | grep 'token:' | awk '{print $2}')
echo $TOKEN
```
<pre>
 ......TOKEN .......
</pre>

Paste the token value




Unfortunately  the metrics server is absent

### Adding metrics server





### Adding  cluster visualizator  

Literature:

https://docs.docker.com/docker-for-windows/#kubernetes

https://github.com/kubernetes/dashboard
https://collabnix.com/kubernetes-dashboard-on-docker-desktop-for-windows-2-0-0-3-in-2-minutes/


https://blog.codewithdan.com/enabling-metrics-server-for-kubernetes-on-docker-desktop/




