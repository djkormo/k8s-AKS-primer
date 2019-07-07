### Creating name space for examples

```console
kubectl create namespace examples
```

> namespace/examples created


# switching to examples namespace

```console
kubectl config set-context --current  --namespace=examples
```

> Context "***" modified.



### Create first pod

```console
kubectl run chess-ai-blue --image=djkormo/chess-ai:blue --port=80
```

> deployment.apps/chess-ai-blue created




### After all delete namespace examples 
 
```console
kubectl delete namespace examples 
```

> namespace "examples" deleted
