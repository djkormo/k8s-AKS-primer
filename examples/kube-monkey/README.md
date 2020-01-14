
# Chaos Engineering

Every system eventually breaks. Every system needs fixing. 

That doesn’t mean it was badly built in the first place. It’s just that it is built from parts that are themselves failable.

So, how do we go from there?

Do we act like everything will run fine and act surprised every time it doesn’t? 

Or do we take that fact into account and integrate that uncertainty into our engineering process?

In 2011, Netflix engineering teams opted for the second option by releasing a piece of software name Chaos Monkey. 




```console
git clone https://github.com/asobti/kube-monkey
```
<pre>

djkor@djkormoOnCloud MINGW64 /c/developing/containers/k8s-AKS-primer/examples/kube-monkey (master)
$ git clone https://github.com/asobti/kube-monkey
Cloning into 'kube-monkey'...
remote: Enumerating objects: 14267, done.
Receiving objects: 100% (14267/14267), 30.45 MiB | 3.16 MiB/s, done.Receiving objects: 100% (14267/14267), 27.97 MiB | 3.86 MiB/s

Resolving deltas: 100% (6310/6310), done.
Checking out files: 100% (5591/5591), done.

</pre>

```console
cd kube-monkey/helm
#helm install --name my-release kubemonkey -f values.yaml
helm install my-kubemonkey kubemonkey #-f values.yaml
```

<pre>
NAME: my-kubemonkey
LAST DEPLOYED: Tue Jan 14 23:02:18 2020
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
1. Wait until the application is rolled out:
  kubectl -n default rollout status deployment my-kubemonkey-kube-monkey
2. Check the logs:
  kubectl logs -f deployment.apps/my-kubemonkey-kube-monkey -n default
</pre>

```
kubectl logs -f deployment.apps/my-kubemonkey-kube-monkey -n default
```


Deploying via yaml files

```console
kubectl apply -f https://raw.githubusercontent.com/asobti/kube-monkey/master/examples/configmap.yaml -n kube-system
```
<pre>
configmap/kube-monkey-config-map created
</pre>

```console
kubectl apply -f https://raw.githubusercontent.com/asobti/kube-monkey/master/examples/deployment.yaml -n kube-system
```
<pre>
deployment.extensions/kube-monkey created
</pre>

```console
kubectl -n kube-system rollout status deployment kube-monkey
```
<pre>
deployment "kube-monkey" successfully rolled out
</pre>

```console
kubectl logs -f deployment.apps/kube-monkey -n kube-system
```
<pre>
I0114 22:28:13.713236       1 config.go:82] Successfully validated configs
I0114 22:28:13.713511       1 main.go:54] Starting kube-monkey with v logging level 5 and local log directory /var/log/kube-monkey
I0114 22:28:13.731418       1 kubemonkey.go:24] Status Update: Generating next schedule at 2020-01-15 08:00:00 -0800 PST
</pre>


Literature:

https://www.padok.fr/en/blog/kube-monkey-kubernetes