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


### After all delete namespace examples 
 
```console
kubectl delete namespace examples 
```

> namespace "examples" deleted


