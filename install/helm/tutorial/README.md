### Simple operations with Helm


```console
helm version
```
<pre>
Client: &version.Version{SemVer:"v2.11.0", GitCommit:"2e55dbe1fdb5fdb96b75ff144a339489417b146b", GitTreeState:"clean"}
Server: &version.Version{SemVer:"v2.9.1", GitCommit:"20adb27c7c5868466912eebdf6664e7390ebe710", GitTreeState:"clean"}

</pre>
```console
helm repo list
```
<pre>
NAME    URL
local   http://127.0.0.1:8879/charts
</pre>

```console
helm repo add coreos https://s3-eu-west-1.amazonaws.com/coreos-charts/stable/
```
<pre>
"coreos" has been added to your repositories
</pre>

```console
helm repo add azure-samples  https://azure-samples.github.io/helm-charts/
```
<pre>
"azure-samples" has been added to your repositories
</pre>

```console
helm repo add azure-marketplace https://marketplace.azurecr.io/helm/v1/repo
```
<pre>
"azure-marketplace" has been added to your repositories
</pre>

```console
helm repo update  
```
<pre>
Hang tight while we grab the latest from your chart repositories...
...Skip local chart repository
...Successfully got an update from the "azure-samples" chart repository
...Successfully got an update from the "coreos" chart repository
...Successfully got an update from the "azure-marketplace" chart repository
Update Complete. ⎈ Happy Helming!⎈
</pre>

```console
helm repo list
```

<pre>
NAME                    URL
local                   http://127.0.0.1:8879/charts
coreos                  https://s3-eu-west-1.amazonaws.com/coreos-charts/stable/
azure-samples           https://azure-samples.github.io/helm-charts/
azure-marketplace       https://marketplace.azurecr.io/helm/v1/repo
</pre>

```console
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo update
```
<pre>
"stable" has been added to your repositories
</pre>

```console
helm search ghost
```
<pre>
NAME                    CHART VERSION   APP VERSION     DESCRIPTION

azure-marketplace/ghost 6.7.32          2.25.9          A simple, powerful publishing platform that allows you to...
</pre>

```console
helm inspect stable/ghost
```

```console
helm install --name my-ghost -f ghost-config.yaml stable/ghost
```
<pre>
Error: incompatible versions client[v2.11.0] server[v2.9.1]
</pre>
```console
helm init --service-account tiller --node-selectors "beta.kubernetes.io/os"="linux" --upgrade
```
<pre>
Client: &version.Version{SemVer:"v2.11.0", GitCommit:"2e55dbe1fdb5fdb96b75ff144a339489417b146b", GitTreeState:"clean"}
Server: &version.Version{SemVer:"v2.11.0", GitCommit:"2e55dbe1fdb5fdb96b75ff144a339489417b146b", GitTreeState:"clean"}
</pre>


```console
helm install --name my-ghost -f ghost-config.yaml stable/ghost
```

<pre>
NOTES:
1. Get the Ghost URL by running:

  echo Blog URL  : http://ghost.example.com/
  echo Admin URL : http://ghost.example.com/ghost

2. Get your Ghost login credentials by running:

  echo Email:    email@example.com
  echo Password: $(kubectl get secret --namespace default coiling-quoll-ghost -o jsonpath="{.data.ghost-password}" | base64 --decode)
</pre>

```
helm ls
```
<pre>
NAME                    REVISION        UPDATED                         STATUS          CHART
APP VERSION     NAMESPACE
my-ghost                1               Thu Aug  1 10:05:01 2019        DEPLOYED        ghost-6.7.33
2.26.0          default
</pre>

<pre>
helm status my-ghost
</pre>
```console
  echo Password: $(kubectl get secret --namespace default my-ghost -o jsonpath="{.data.ghost-password}" | base64 --decode)
```
<pre>
Password: 9SNpn8Jhs9
</pre>
### add ghostBlogTitle: Example Site Name

```console
helm upgrade -f ghost-config2.yaml my-ghost stable/ghost
```

```console
helm ls
```
<pre>
NAME                    REVISION        UPDATED                         STATUS          CHART
APP VERSION     NAMESPACE
my-ghost                2               Thu Aug  1 10:08:30 2019        DEPLOYED        ghost-6.7.33
2.26.0          default
</pre>

```console
helm rollback my-ghost 1
```

<pre>
Rollback was a success! Happy Helming
</pre>

```console
helm ls
```

<pre>
NAME                    REVISION        UPDATED                         STATUS          CHART
APP VERSION     NAMESPACE
my-ghost                3               Thu Aug  1 10:08:57 2019        DEPLOYED        ghost-6.7.33
2.26.0          default
</pre>
```console
helm delete my-ghost 
```
<pre>
release "my-ghost" deleted
</pre>
```console
helm ls --deleted
```
<pre>
NAME            REVISION        UPDATED                         STATUS  CHART           APP VERSION NAMESPACE
my-ghost   3               Thu Aug  1 10:14:01 2019        DELETED ghost-6.7.33    2.26.0      default
</pre>
```console
helm delete my-ghost  --purge
```
<pre>
release "my-ghost" deleted
</pre>

### Based on https://www.linode.com/docs/applications/containers/kubernetes/how-to-install-apps-on-kubernetes-with-helm/