# ETCD in kubernetes cluster


In the Kubernetes world, etcd is used as the backend for service discovery and stores the cluster’s state and its configuration.



[ETCD and creating pod](etcd-pod.png)

```console
kubectl get pods --namespace kube-system -l component=etcd
```

<pre>
NAME                  READY   STATUS    RESTARTS   AGE
etcd-docker-desktop   1/1     Running   0          20h

</pre>

```console`
kubectl exec etcd-docker-desktop -n kube-system -- ps aux
```
<pre>
PID   USER     TIME  COMMAND
    1 root     18:51 etcd --advertise-client-urls=https://192.168.65.3:2379 --cert-file=/run/config/pki/etcd/server.crt --client-cert-auth=true --data-dir=/var/lib/etcd --initial-advertise-peer-urls=https://192.168.65.3:2380 --initial-cluster=docker-desktop=https://192.168.65.3:2380 --key-file=/run/config/pki/etcd/server.key --listen-client-urls=https://127.0.0.1:2379,https://192.168.65.3:2379 --listen-peer-urls=https://192.168.65.3:2380 --name=docker-desktop 
--peer-cert-file=/run/config/pki/etcd/peer.crt --peer-client-cert-auth=true --peer-key-file=/run/config/pki/etcd/peer.key --peer-trusted-ca-file=/run/config/pki/etcd/ca.crt --snapshot-count=10000 --trusted-ca-file=/run/config/pki/etcd/ca.crt
43922 root      0:00 ps aux
</pre>


```console
ADVERTISE_URL="https://localhost:2379"
ETCD_POD=etcd-docker-desktop

kubectl exec $ETCD_POD -n kube-system -- sh -c \
  "ETCDCTL_API=3 etcdctl \
  --endpoints $ADVERTISE_URL \
  --cacert /etc/kubernetes/pki/etcd/ca.crt \
  --key /etc/kubernetes/pki/etcd/server.key \
  #--cert /etc/kubernetes/pki/etcd/server.crt \
  get \"\" --prefix=true -w json" > etcd-kv.json

```
<pre>
</pre>

etcdctl --endpoints $ADVERTISE_URL  --cacert /etc/kubernetes/pki/etcd/ca.crt --key /etc/kubernetes/pki/etcd/server.key
  #--cert /etc/kubernetes/pki/etcd/server.crt \
  get \"\" --prefix=true -w json" > etcd-kv.json



Literature:

https://medium.com/better-programming/a-closer-look-at-etcd-the-brain-of-a-kubernetes-cluster-788c8ea759a5