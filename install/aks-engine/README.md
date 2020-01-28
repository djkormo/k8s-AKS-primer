Installing Kubernetes cluster in AKS with aks-engine  

# install aks-engine


```console
curl https://raw.githubusercontent.com/Azure/aks-engine/master/scripts/get-akse.sh >get-akse.sh
```
<pre>
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  6077  100  6077    0     0  17012      0 --:--:-- --:--:-- --:--:-- 17022
</pre>

```console
bash get-akse.sh
```
<pre>
Run 'aks-engine version' to test.
</pre>

```
aks-version
```
<pre>
Version: v0.46.0
GitCommit: 9335dfb72
GitTreeState: clean
</pre>


After installing try with kubectl 

```console
KUBECONFIG=_output/simple-aks-engine/kubeconfig/kubeconfig.northeurope.json  kubectl cluster-info
```
```console
cp _output/simple-aks-engine/kubeconfig/kubeconfig.northeurope.json  ~/.kube/config
```

```console
kubectl config set-context simple-aks-engine
```

<pre>
Context "simple-aks-engine" modified.
</pre>

```console
kubectl cluster-info
```
<pre>
Kubernetes master is running at https://simple-aks-engine.northeurope.cloudapp.azure.com
CoreDNS is running at https://simple-aks-engine.northeurope.cloudapp.azure.com/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
kubernetes-dashboard is running at https://simple-aks-engine.northeurope.cloudapp.azure.com/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy
Metrics-server is running at https://simple-aks-engine.northeurope.cloudapp.azure.com/api/v1/namespaces/kube-system/services/https:metrics-server:/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
</pre>

```console
kubectl get nodes
```
<pre>
NAME                                 STATUS   ROLES    AGE   VERSION
k8s-agentpool1-98285355-vmss000000   Ready    agent    15m   v1.13.11
k8s-agentpool1-98285355-vmss000001   Ready    agent    15m   v1.13.11
k8s-master-98285355-0                Ready    master   15m   v1.13.11
</pre>


Literature:


https://github.com/Azure/aks-engine/blob/master/docs/tutorials/deploy.md 

https://www.danielstechblog.io/distribute-aks-engine-kubeconfig-credentials/




