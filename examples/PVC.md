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


```console
kubectl apply -f pvc.yaml
```
> persistentvolumeclaim/my-pvc-claim created

```console
kubectl get pvc
```

> NAME           STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
>
> my-pvc-claim   Bound    pvc-03ac39f2-a158-11e9-924c-c6faaeeca8f6   1Gi        RWO            default        6m32s
```console
kubectl apply -f pod-pvc-deployment.yaml
```
> deployment.apps/pod-pvc-deploy created

```console
kubectl get deployment,rs,po
```

> NAME                                   READY   UP-TO-DATE   AVAILABLE   AGE
> deployment.extensions/pod-pvc-deploy   1/1     1            1           90s
> 
> NAME                                             DESIRED   CURRENT   READY   AGE
> replicaset.extensions/pod-pvc-deploy-f59598774   1         1         1       90s
>
> NAME                                 READY   STATUS    RESTARTS   AGE
> pod/pod-pvc-deploy-f59598774-f79g8   1/1     Running   0          90s

```console
kubectl exec -it pod-pvc-deploy-f59598774-f79g8 -- bash


[root@pod-pvc-deploy-f59598774-f79g8 /]# ls -la /tmp/persistent/
total 24
drwxr-xr-x 3 root root  4096 Jul  8 08:25 .
drwxrwxrwt 1 root root  4096 Jul  8 08:25 ..
drwx------ 2 root root 16384 Jul  8 08:25 lost+found
[root@pod-pvc-deploy-f59598774-f79g8 /]# echo "from container to pvc ">>/tmp/persistent/container.dat
[root@pod-pvc-deploy-f59598774-f79g8 /]# ls -la /tmp/persistent/total 28
drwxr-xr-x 3 root root  4096 Jul  8 08:28 .
drwxrwxrwt 1 root root  4096 Jul  8 08:25 ..
-rw-r--r-- 1 root root    23 Jul  8 08:28 container.dat
drwx------ 2 root root 16384 Jul  8 08:25 lost+found
[root@pod-pvc-deploy-f59598774-f79g8 /]#
[root@pod-pvc-deploy-f59598774-f79g8 /]# exit
exit
```

### Delete pod but not deployment 

```console
kubectl delete po pod-pvc-deploy-f59598774-f79g8
```

> pod "pod-pvc-deploy-f59598774-f79g8" deleted

```console
kubectl get deployment,rs,po
```

> NAME                                   READY   UP-TO-DATE   AVAILABLE   AGE
> deployment.extensions/pod-pvc-deploy   1/1     1            1           11m
>
> NAME                                             DESIRED   CURRENT   READY   AGE
> replicaset.extensions/pod-pvc-deploy-f59598774   1         1         1       11m
>
> NAME                                 READY   STATUS    RESTARTS   AGE
> pod/pod-pvc-deploy-f59598774-tftjs   1/1     Running   0          2m26s


```console`
kubectl exec -it pod-pvc-deploy-f59598774-tftjs -- bash

[root@pod-pvc-deploy-f59598774-tftjs /]# cd /tmp/persistent
[root@pod-pvc-deploy-f59598774-tftjs persistent]# cat container.dat
from container to pvc
[root@pod-pvc-deploy-f59598774-tftjs persistent]#
[root@pod-pvc-deploy-f59598774-tftjs persistent]# exit
exit
```
```console`
kubectl delete deployment/pod-pvc-deploy
```

> deployment.extensions "pod-pvc-deploy" deleted

### After all delete namespace examples 
 
```console
kubectl delete namespace examples 
```

> namespace "examples" deleted