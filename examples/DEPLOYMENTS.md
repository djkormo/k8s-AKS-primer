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
kubectl apply -f chess-ai-deployment_v1.yaml
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




### change  from 1.0 in chess-ai-deployment.yaml
```sh
        env:
        - name: APP_VERSION
          value: "1.0"
```

# to 2.0
```sh
        env:
        - name: APP_VERSION
          value: "1.0"
```

### change deployment by applying yaml file once again

```console
kubectl apply -f chess-ai-deployment_v2.yaml
```

> deployment.apps/chess-ai-deployment configured

### Look what is going on 

```console
kubectl get deployments,rs,pods
```

> NAME                                        READY   UP-TO-DATE   AVAILABLE   AGE
> deployment.extensions/chess-ai-deployment   2/2     2            2           53m
>
> NAME                                                   DESIRED   CURRENT   READY   AGE
> replicaset.extensions/chess-ai-deployment-5fdbfc5b86   2         2         2       2m45s
> replicaset.extensions/chess-ai-deployment-5ffcd6665    0         0         0       53m
>
> NAME                                       READY   STATUS    RESTARTS   AGE
> pod/chess-ai-deployment-5fdbfc5b86-5vfnn   1/1     Running   0          2m44s
> pod/chess-ai-deployment-5fdbfc5b86-gvq8p   1/1     Running   0          2m42s

### We can check if changing in deployment is done

```console
kubectl rollout status deploy/chess-ai-deployment
```

> deployment "chess-ai-deployment" successfully rolled out


### We can check history of change 

```console
kubectl rollout history deploy/chess-ai-deployment
```

> deployment.extensions/chess-ai-deployment
> REVISION  CHANGE-CAUSE
> 1         <none>
> 2         <none>


### We can also undo our new  version
```console
kubectl rollout undo deploy/chess-ai-deployment --to-revision=1
```

> deployment.extensions/chess-ai-deployment rolled back

### In history we can see version 3

```console
kubectl rollout history deploy/chess-ai-deployment
```

> deployment.extensions/chess-ai-deployment
> REVISION  CHANGE-CAUSE
> 2         <none>
> 3         <none>


### Look what is going on 

```console
kubectl get deployments,rs,pods
```

> NAME                                        READY   UP-TO-DATE   AVAILABLE   AGE
> deployment.extensions/chess-ai-deployment   2/2     2            2           69m
>
> NAME                                                   DESIRED   CURRENT   READY   AGE
> replicaset.extensions/chess-ai-deployment-5fdbfc5b86   0         0         0       18m
> replicaset.extensions/chess-ai-deployment-5ffcd6665    2         2         2       69m
>
> NAME                                      READY   STATUS    RESTARTS   AGE
> pod/chess-ai-deployment-5ffcd6665-jsm4m   1/1     Running   0          2m28s
> pod/chess-ai-deployment-5ffcd6665-jw892   1/1     Running   0          2m25s



### After all delete namespace examples 
 
```console
kubectl delete namespace examples 
```

> namespace "examples" deleted