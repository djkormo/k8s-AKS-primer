### Creating name space for examples

```console
kubectl create namespace examples
```

> namespace/examples created


### switching to examples namespace

```console
kubectl config set-context --current  --namespace=examples
```

> Context "***" modified.



### Create first pod
#### here I've changed  request to create only  pod without deplyment

```console
kubectl run --generator=run-pod/v1 --image=djkormo/chess-ai:blue  chess-ai-blue --port=80
```

> deployment.apps/chess-ai-blue created

#### Trying the second time 

> Error from server (AlreadyExists): pods "chess-ai-blue" already exists

```console
kubectl get pods --show-labels
```


> NAME            READY   STATUS    RESTARTS   AGE     LABELS

> chess-ai-blue   1/1     Running   0          3m57s   run=chess-ai-blue


### delete our pod 

```console
kubectl delete pod/chess-ai-blue
```
> pod "chess-ai-blue" deleted

### It is much better to use creating pods from  files in yaml format.


#### from localfile

```console
kubectl apply -f chess-ai-blue.yaml
```

> pod/chess-ai-blue-labeled created

#### from github

``` console
kubectl apply -f https://raw.githubusercontent.com/djkormo/k8s-AKS-primer/master/examples/labels/chess-ai-blue.yaml
```

> pod/chess-ai-blue-labeled created


```console
kubectl get pods --show-labels
```

> NAME                    READY   STATUS    RESTARTS   AGE   LABELS

> chess-ai-blue-labeled   1/1     Running   0          87s   env=development,owner=djkormo,type=game


### Now we can filter list of pods by  labels

```console
kubectl get pod --selector env=development  --show-labels
```

> NAME                    READY   STATUS    RESTARTS   AGE     LABELS

> chess-ai-blue-labeled   1/1     Running   0          2m37s   env=development,owner=djkormo,type=game


### Let's create another pod 

```console
 kubectl apply -f https://raw.githubusercontent.com/djkormo/k8s-AKS-primer/master/examples/labels/chess-ai-green.yaml
```

#### or

```console
kubectl apply -f chess-ai-green.yaml
```

> pod/chess-ai-green-labeled created


```console
kubectl get pod --show-labels
```

> NAME                     READY   STATUS    RESTARTS   AGE     LABELS
>
> chess-ai-blue-labeled    1/1     Running   0          7m27s   env=development,owner=djkormo,type=game
>
> chess-ai-green-labeled   1/1     Running   0          10s     env=production,owner=djkormo,type=game

```console
kubectl get pods -l 'env in (production, development)' --show--labels 
```

> NAME                     READY   STATUS    RESTARTS   AGE     LABELS

> chess-ai-blue-labeled    1/1     Running   0          10m     env=development,owner=djkormo,type=game
>
> chess-ai-green-labeled   1/1     Running   0          3m23s   env=production,owner=djkormo,type=game


```console
kubectl get pods -l 'env in (production, development)' 
```

>NAME                     READY   STATUS    RESTARTS   AGE

> chess-ai-blue-labeled    1/1     Running   0          11m

> chess-ai-green-labeled   1/1     Running   0          4m7s



### Now we can forward ports for two pods to localhost
```console
kubectl port-forward chess-ai-blue-labeled 30001:80
```

> Forwarding from 127.0.0.1:30001 -> 80
>
> Forwarding from [::1]:30001 -> 80
>
> Handling connection for 30001
>
> Handling connection for 30001

### in second console

```console
kubectl port-forward chess-ai-green-labeled 30002:80
```

> Forwarding from 127.0.0.1:30002 -> 80
>
> Forwarding from [::1]:30002 -> 80
>
> Handling connection for 30002
>
> Handling connection for 30002


### Instead of deleting whole namespace delete pods by label filter

```console
kubectl delete pods -l 'env in (production, development)'
```

> pod "chess-ai-blue-labeled" deleted

> pod "chess-ai-green-labeled" deleted



### After all delete namespace examples 
 
```console
kubectl delete namespace examples 
```

> namespace "examples" deleted


