
#### downlod binary from

https://github.com/kubernetes/helm/releases


#### Create a service account

```console

kubectl apply -f helm-rbac.yaml

```

```console

helm version
```
<pre>
Client: &version.Version{SemVer:"v2.11.0", GitCommit:"2e55dbe1fdb5fdb96b75ff144a339489417b146b", GitTreeState:"clean"}
Error: could not find tiller
</pre>

Helm is not instaled on server


#### Install Helm on AKS

```console
helm init --service-account tiller --node-selectors "beta.kubernetes.io/os"="linux"
```
<pre>
Tiller (the Helm server-side component) has been installed into your Kubernetes Cluster.

Please note: by default, Tiller is deployed with an insecure 'allow unauthenticated users' policy.
To prevent this, run `helm init` with the --tiller-tls-verify flag.
For more information on securing your installation see: https://docs.helm.sh/using_helm/#securing-your-helm-installation
Happy Helming!
</pre>

#### After few minutes 
```console
helm version
```
<pre>
Client: &version.Version{SemVer:"v2.11.0", GitCommit:"2e55dbe1fdb5fdb96b75ff144a339489417b146b", GitTreeState:"clean"}
Server: &version.Version{SemVer:"v2.11.0", GitCommit:"2e55dbe1fdb5fdb96b75ff144a339489417b146b", GitTreeState:"clean"}
</pre>

Let's install ISTIO

```console
helm install install/kubernetes/helm/istio-init --name istio-init --namespace istio-system
```
<pre>
Error: failed to download "install/kubernetes/helm/istio-init" (hint: running `helm repo update` may help)
</pre>

Ups! 

```console
helm repo update
```
<pre>
 Hang tight while we grab the latest from your chart repositories...
...Skip local chart repository
...Successfully got an update from the "stable" chart repository
Update Complete. ⎈ Happy Helming!⎈
</pre>
```console
helm install install/kubernetes/helm/istio-init --name istio-init --namespace istio-system
```
<pre>
Error: failed to download "install/kubernetes/helm/istio-init" (hint: running `helm repo update` may help)
</pre>

Ups!

```console
helm repo list
```

<pre>
NAME    URL
stable  https://kubernetes-charts.storage.googleapis.com
local   http://127.0.0.1:8879/charts
</pre>

```console
helm repo add istio.io https://storage.googleapis.com/istio-release/releases/1.1.7/charts/
```

<pre>
"istio.io" has been added to your repositories
</pre>
```console
helm repo list
```
<pre>
NAME            URL
stable          https://kubernetes-charts.storage.googleapis.com
local           http://127.0.0.1:8879/charts
istio.io        https://storage.googleapis.com/istio-release/releases/1.1.7/charts/
</pre>

```console
helm install install/kubernetes/helm/istio-init --name istio-init --namespace istio-system
```
<pre>
Error: failed to download "install/kubernetes/helm/istio-init" (hint: running `helm repo update` may help)
</pre>
Ups!!!!

Resolution

# Specify the Istio version that will be leveraged throughout these instructions


$ ISTIO_VERSION=1.1.3


curl -sL "https://github.com/istio/istio/releases/download/$ISTIO_VERSION/istio-$ISTIO_VERSION-linux.tar.gz" | tar xz

cd istio-1.1.3

helm install install/kubernetes/helm/istio-init --name istio-init --namespace istio-system
<pre>
NAME:   istio-init
LAST DEPLOYED: Thu Sep 19 22:05:14 2019
NAMESPACE: istio-system
STATUS: DEPLOYED

RESOURCES:
==> v1/Job
NAME               AGE
istio-init-crd-10  1s
istio-init-crd-11  1s

==> v1/Pod(related)

NAME                     READY  STATUS             RESTARTS  AGE
istio-init-crd-10-dh5fm  0/1    ContainerCreating  0         1s
istio-init-crd-11-pq8t4  0/1    ContainerCreating  0         1s

==> v1/ConfigMap

NAME          AGE
istio-crd-10  1s
istio-crd-11  1s

==> v1/ServiceAccount
istio-init-service-account  1s

==> v1/ClusterRole
istio-init-istio-system  1s

==> v1/ClusterRoleBinding
istio-init-admin-role-binding-istio-system  1s

</pre>


```console
kubectl get jobs -n istio-system
```

<pre>
NAME                COMPLETIONS   DURATION   AGE
istio-init-crd-10   1/1           30s        2m17s
istio-init-crd-11   1/1           28s        2m17s
</pre>


```console
kubectl get crds | grep 'istio.io' |wc -l
```
<pre>
53
</pre>


Install the Istio components on AKS


grafana

```console
GRAFANA_USERNAME=$(echo -n "grafana" | base64)
GRAFANA_PASSPHRASE=$(echo -n "REPLACE_WITH_YOUR_SECURE_PASSWORD" | base64)

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: grafana
  namespace: istio-system
  labels:
    app: grafana
type: Opaque
data:
  username: $GRAFANA_USERNAME
  passphrase: $GRAFANA_PASSPHRASE
EOF
```
<pre>
secret/grafana created
</pre>

kiali

```console

KIALI_USERNAME=$(echo -n "kiali" | base64)
KIALI_PASSPHRASE=$(echo -n "REPLACE_WITH_YOUR_SECURE_PASSWORD" | base64)

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: kiali
  namespace: istio-system
  labels:
    app: kiali
type: Opaque
data:
  username: $KIALI_USERNAME
  passphrase: $KIALI_PASSPHRASE
EOF
```
<pre>
secret/kiali created
</pre>

```console
helm install install/kubernetes/helm/istio --name istio --namespace istio-system \
  --set global.controlPlaneSecurityEnabled=true \
  --set mixer.adapters.useAdapterCRDs=false \
  --set grafana.enabled=true --set grafana.security.enabled=true \
  --set tracing.enabled=true \
  --set kiali.enabled=true
```

<pre>
...
==> v1/Pod(related)

NAME                                     READY  STATUS             RESTARTS  AGE
istio-galley-795b8cc485-2x9qk            0/1    ContainerCreating  0         1m
istio-ingressgateway-5c4f9f859d-cb5l7    0/1    Running            0         1m
grafana-586cf6d9db-89j5h                 0/1    Running            0         1m
kiali-95fcf457f-w6cp7                    0/1    ContainerCreating  0         1m
istio-telemetry-76964ff8cc-q64pv         0/2    ContainerCreating  0         1m
istio-policy-6d8df569ff-mj56t            2/2    Running            1         1m
istio-pilot-5c99545c8b-8q8dv             0/2    Pending            0         1m
prometheus-5554746896-k5r2f              0/1    Init:0/1           0         1m
istio-citadel-5749f4b6dd-5b8wv           0/1    ContainerCreating  0         1m
istio-sidecar-injector-5cf67ccc65-rm2zv  0/1    ContainerCreating  0         1m
istio-tracing-5d8f57c8ff-rb9wj           1/1    Running            0         59s
...
</pre>

```console
kubectl get svc --namespace istio-system --output wide
```

<pre>
NAME                     TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)
                                                      AGE     SELECTOR
grafana                  ClusterIP      10.0.212.206   <none>           3000/TCP
                                                      3m56s   app=grafana
istio-citadel            ClusterIP      10.0.241.43    <none>           8060/TCP,15014/TCP
                                                      3m55s   istio=citadel
istio-galley             ClusterIP      10.0.1.99      <none>           443/TCP,15014/TCP,9901/TCP
                                                      3m56s   istio=galley
istio-ingressgateway     LoadBalancer   10.0.70.245    40.115.105.255   15020:32528/TCP,80:31380/TCP,443:31390/TCP,31400:31400/TCP,15029:30101/TCP,15030:32248/TCP,15031:31219/TCP,15032:30342/TCP,15443:31810/TCP   3m56s   app=istio-ingressgateway,istio=ingressgateway,release=istio
istio-pilot              ClusterIP      10.0.142.122   <none>           15010/TCP,15011/TCP,8080/TCP,15014/TCP
                                                      3m55s   istio=pilot
istio-policy             ClusterIP      10.0.61.208    <none>           9091/TCP,15004/TCP,15014/TCP
                                                      3m56s   istio-mixer-type=policy,istio=mixer
istio-sidecar-injector   ClusterIP      10.0.207.186   <none>           443/TCP
                                                      3m55s   istio=sidecar-injector
istio-telemetry          ClusterIP      10.0.118.246   <none>           9091/TCP,15004/TCP,15014/TCP,42422/TCP
                                                      3m56s   istio-mixer-type=telemetry,istio=mixer
jaeger-agent             ClusterIP      None           <none>           5775/UDP,6831/UDP,6832/UDP
                                                      3m55s   app=jaeger
jaeger-collector         ClusterIP      10.0.48.59     <none>           14267/TCP,14268/TCP
                                                      3m55s   app=jaeger
jaeger-query             ClusterIP      10.0.154.224   <none>           16686/TCP
                                                      3m55s   app=jaeger
kiali                    ClusterIP      10.0.174.90    <none>           20001/TCP
                                                      3m56s   app=kiali
prometheus               ClusterIP      10.0.166.103   <none>           9090/TCP
                                                      3m55s   app=prometheus
tracing                  ClusterIP      10.0.237.169   <none>           80/TCP
                                                      3m54s   app=jaeger
zipkin                   ClusterIP      10.0.79.68     <none>           9411/TCP
                                                      3m54s   app=jaeger
</pre>

```console
kubectl get pods --namespace istio-system
```
<pre>
NAME                                      READY   STATUS      RESTARTS   AGE
grafana-586cf6d9db-89j5h                  1/1     Running     0          6m41s
istio-citadel-5749f4b6dd-5b8wv            1/1     Running     0          6m41s
istio-galley-795b8cc485-2x9qk             1/1     Running     0          6m41s
istio-ingressgateway-5c4f9f859d-cb5l7     0/1     Running     0          6m41s
istio-init-crd-10-dh5fm                   0/1     Completed   0          23m
istio-init-crd-11-pq8t4                   0/1     Completed   0          23m
istio-pilot-5c99545c8b-8q8dv              0/2     Pending     0          6m41s
istio-policy-6d8df569ff-mj56t             2/2     Running     5          6m41s
istio-sidecar-injector-5cf67ccc65-rm2zv   1/1     Running     0          6m41s
istio-telemetry-76964ff8cc-q64pv          2/2     Running     4          6m41s
istio-tracing-5d8f57c8ff-rb9wj            1/1     Running     0          6m40s
kiali-95fcf457f-w6cp7                     1/1     Running     0          6m41s
prometheus-5554746896-k5r2f               1/1     Running     0          6m41s
</pre>


```console
kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=grafana -o jsonpath='{.items[0].metadata.name}') 3000:3000
```
<pre>
Forwarding from 127.0.0.1:3000 -> 3000
Forwarding from [::1]:3000 -> 3000
</pre>

Use
http://localhost:3000

```console
kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=prometheus -o jsonpath='{.items[0].metadata.name}') 9090:9090
```
<pre>
Forwarding from 127.0.0.1:9090 -> 9090
Forwarding from [::1]:9090 -> 9090
</pre>

Use 
http://localhost:9090


```console
kubectl port-forward -n istio-system $(kubectl get pod -n istio-system -l app=jaeger -o jsonpath='{.items[0].metadata.name}') 16686:16686
```
<pre>
Forwarding from 127.0.0.1:16686 -> 16686
Forwarding from [::1]:16686 -> 16686
</pre>
Use
http://localhost:16686.

```console
kubectl port-forward -n istio-system $(kubectl get pod -n istio-system -l app=kiali -o jsonpath='{.items[0].metadata.name}') 20001:20001
```

<pre>
Forwarding from 127.0.0.1:20001 -> 20001
Forwarding from [::1]:20001 -> 20001
</pre>

Use

http://localhost:20001/kiali/console/



```console
kubectl get namespace -L istio-injection
```
<pre>
NAME              STATUS   AGE   ISTIO-INJECTION
default           Active   33d
failure           Active   23h
istio-system      Active   41m
kube-node-lease   Active   33d
kube-public       Active   33d
kube-system       Active   33d
</pre>
```console
kubectl label namespace default istio-injection=enabled
kubectl get namespace -L istio-injection
```
<pre>
namespace/default labeled

NAME              STATUS   AGE   ISTIO-INJECTION
default           Active   33d   enabled
failure           Active   23h
istio-system      Active   42m
kube-node-lease   Active   33d
kube-public       Active   33d
kube-system       Active   33d

</pre>

To inject sidecar restart pod in default namespace

```console
kubectl get  pods -l run=my-app
```
<pre>
NAME                           READY   STATUS      RESTARTS   AGE   LABELS
my-app-7875b68698-8t7fp        1/1     Running     1          25h   pod-template-hash=7875b68698,run=my-app
my-app-7875b68698-sn4mb        1/1     Running     1          25h   pod-template-hash=7875b68698,run=my-app
</pre>

```console
kubectl delete  pods -l run=my-app
```
<pre>
my-app-7875b68698-7qjxf   1/2     Running   0          2m3s
my-app-7875b68698-dq52n   1/2     Running   0          2m3s
</pre>

### TODO more examples 

Literature:
 
https://docs.microsoft.com/en-us/azure/aks/istio-install

https://istio.io/docs/setup/additional-setup/sidecar-injection/

