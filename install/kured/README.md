### Using Kured for automating VMs restarts


### Show all cluster node in wide mode
```console
kubectl get nodes -o wide 
```
<pre>
NAME                       STATUS   ROLES   AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
aks-nodepool1-16191604-0   Ready    agent   33d   v1.15.4   10.240.0.5    <none>        Ubuntu 16.04.6 LTS   4.15.0-1061-azure   docker://3.0.6
aks-nodepool1-16191604-1   Ready    agent   33d   v1.15.4   10.240.0.4    <none>        Ubuntu 16.04.6 LTS   4.15.0-1061-azure   docker://3.0.6
aks-nodepool1-16191604-2   Ready    agent   33d   v1.15.4   10.240.0.6    <none>        Ubuntu 16.04.6 LTS   4.15.0-1061-azure   docker://3.0.6
</pre>


### Install  kured 
```console
kubectl apply -f https://github.com/weaveworks/kured/releases/download/1.2.0/kured-1.2.0-dockerhub.yaml
```
<pre>
clusterrole.rbac.authorization.k8s.io/kured created
clusterrolebinding.rbac.authorization.k8s.io/kured created
role.rbac.authorization.k8s.io/kured created
rolebinding.rbac.authorization.k8s.io/kured created
serviceaccount/kured created
daemonset.apps/kured created
</pre>

```console
kubectl get pods --namespace=kube-system |grep kured
```
<pre>
kured-j9jbs                             1/1     Running   0          57s
kured-jhxrn                             1/1     Running   0          57s
kured-p5wzw                             1/1     Running   0          57s
</pre>


```console
kubectl describe pod kured-j9jbs  --namespace=kube-system
```
<pre>

Name:           kured-j9jbs
Namespace:      kube-system
Priority:       0
Node:           aks-nodepool1-16191604-0/10.240.0.5
Start Time:     Mon, 25 Nov 2019 21:22:36 +0000
Labels:         controller-revision-hash=7cd9c7cb74
                name=kured
                pod-template-generation=1
Annotations:    <none>
Status:         Running
IP:             10.244.0.25
IPs:            <none>
Controlled By:  DaemonSet/kured
Containers:
  kured:
    Container ID:  docker://50a7f80a428a293530272410e45e6b7706e912536da0d9ca55a472723fe22934
    Image:         docker.io/weaveworks/kured:1.2.0
    Image ID:      docker-pullable://weaveworks/kured@sha256:0d4bf4911f10ef1e3bd088f331e9412cf2d870bec2780d555c4671774503c73c
    Port:          <none>
    Host Port:     <none>
    Command:
      /usr/bin/kured
    State:          Running
      Started:      Mon, 25 Nov 2019 21:22:50 +0000
    Ready:          True
    Restart Count:  0
    Environment:
      KURED_NODE_ID:                  (v1:spec.nodeName)
      KUBERNETES_PORT_443_TCP_ADDR:  aks-simple-rg-aks-simple-1abe75-0700996b.hcp.northeurope.azmk8s.io
      KUBERNETES_PORT:               tcp://aks-simple-rg-aks-simple-1abe75-0700996b.hcp.northeurope.azmk8s.io:443
      KUBERNETES_PORT_443_TCP:       tcp://aks-simple-rg-aks-simple-1abe75-0700996b.hcp.northeurope.azmk8s.io:443
      KUBERNETES_SERVICE_HOST:       aks-simple-rg-aks-simple-1abe75-0700996b.hcp.northeurope.azmk8s.io
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kured-token-x7ppn (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  kured-token-x7ppn:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  kured-token-x7ppn
    Optional:    false
QoS Class:       BestEffort
Node-Selectors:  <none>
Tolerations:     node-role.kubernetes.io/master:NoSchedule
                 node.kubernetes.io/disk-pressure:NoSchedule
                 node.kubernetes.io/memory-pressure:NoSchedule
                 node.kubernetes.io/not-ready:NoExecute
                 node.kubernetes.io/pid-pressure:NoSchedule
                 node.kubernetes.io/unreachable:NoExecute
                 node.kubernetes.io/unschedulable:NoSchedule
Events:
  Type    Reason     Age    From                               Message
  ----    ------     ----   ----                               -------
  Normal  Scheduled  3m13s  default-scheduler                  Successfully assigned kube-system/kured-j9jbs to aks-nodepool1-16191604-0
  Normal  Pulling    3m12s  kubelet, aks-nodepool1-16191604-0  Pulling image "docker.io/weaveworks/kured:1.2.0"
  Normal  Pulled     3m8s   kubelet, aks-nodepool1-16191604-0  Successfully pulled image "docker.io/weaveworks/kured:1.2.0"
  Normal  Created    3m     kubelet, aks-nodepool1-16191604-0  Created container kured
  Normal  Started    2m59s  kubelet, aks-nodepool1-16191604-0  Started container kured

</pre>


### Look what is going on with cluster nodes

```console
kubectl get nodes -o wide 
```
<pre>
NAME                       STATUS   ROLES   AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
aks-nodepool1-16191604-0   Ready    agent   33d   v1.15.4   10.240.0.5    <none>        Ubuntu 16.04.6 LTS   4.15.0-1061-azure   docker://3.0.6
aks-nodepool1-16191604-1   Ready    agent   33d   v1.15.4   10.240.0.4    <none>        Ubuntu 16.04.6 LTS   4.15.0-1061-azure   docker://3.0.6
aks-nodepool1-16191604-2   Ready    agent   33d   v1.15.4   10.240.0.6    <none>        Ubuntu 16.04.6 LTS   4.15.0-1061-azure   docker://3.0.6
</pre>



Literature:
https://github.com/weaveworks/kured
https://carlos.mendible.com/2019/07/28/kured-restart-your-azure-kubernetes-service-nodes/