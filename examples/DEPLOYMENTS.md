LABELS

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


### Create first deployment


```console
kubectl apply -f chess-ai-deployment.yaml
```

> deployment.apps/chess-ai-deployment created


```console
kubectl get deployment
```

> NAME                  READY   UP-TO-DATE   AVAILABLE   AGE

>chess-ai-deployment   2/2     2            2           3m1s

```console
kubectl get replicaset
```

> NAME                            DESIRED   CURRENT   READY   AGE
>
> chess-ai-deployment-5ffcd6665   2         2         2       3m23s

```console
kubectl get pod
```

> NAME                                  READY   STATUS    RESTARTS   AGE
>
> chess-ai-deployment-5ffcd6665-jbzdx   1/1     Running   0          3m51s
>
> chess-ai-deployment-5ffcd6665-njh8h   1/1     Running   0          3m51s


### We can also do it in one request

```console
kubectl get deploy,rs,po
```


> NAME                                        READY   UP-TO-DATE   AVAILABLE   AGE
>
> deployment.extensions/chess-ai-deployment   2/2     2            2           4m39s
>
> NAME                                                  DESIRED   CURRENT   READY   AGE
>
> replicaset.extensions/chess-ai-deployment-5ffcd6665   2         2         2       4m39s
>
> NAME                                      READY   STATUS    RESTARTS   AGE
> pod/chess-ai-deployment-5ffcd6665-jbzdx   1/1     Running   0          4m39s
>
> pod/chess-ai-deployment-5ffcd6665-njh8h   1/1     Running   0          4m39s




### After all delete namespace examples 
 
```console
kubectl delete namespace examples 
```

> namespace "examples" deleted