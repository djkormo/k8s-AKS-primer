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
kubectl apply -f pod-volume.yaml
```

> pod/pod-share-volume created

```console
kubectl describe pod/pod-share-volume
```
...inside...
Name:               pod-share-volume
Namespace:          examples

Containers:
  c1:
    Image:         centos:7
    Command:
      bin/bash
      -c
      sleep 10000

    Mounts:
      /tmp/xchange from xchange (rw)

  c2:
    
    Image:         centos:7
    Command:
      bin/bash
      -c
      sleep 10000
    Mounts:
      /tmp/data from xchange (rw)	  

Volumes:
  xchange:
    Type:    EmptyDir (a temporary directory that shares a pod's lifetime)	  

...inside...
	
### Inside pod c1  -> remember path mountPath: "/tmp/xchange"

```console
kubectl exec -it pod-share-volume -c c1 -- bash
[root@pod-share-volume /]# mount | grep xchange
[root@pod-share-volume /]# echo 'from c1 to volume' > /tmp/xchange/c1.dat
[root@pod-share-volume /]# exit
```

### Inside pod c2 -> remember path mountPath: "/tmp/data"

```console
kubectl exec -it pod-share-volume -c c2 -- bash
[root@pod-share-volume /]# mount | grep /tmp/data
[root@pod-share-volume /]# ls -la /tmp/data/
total 12
drwxrwxrwx 2 root root 4096 Jul  8 07:48 .
drwxrwxrwt 1 root root 4096 Jul  8 07:42 ..
-rw-r--r-- 1 root root   18 Jul  8 07:48 c1.dat
[root@pod-share-volume /]# cat /tmp/data/c1.dat
from c1 to volume
```
### Delete pod 
```console
kubectl delete pod/pod-share-volume
```
> pod "pod-share-volume" deleted

### Pod volume will be deleted too.


### After all delete namespace examples 
 
```console
kubectl delete namespace examples 
```

> namespace "examples" deleted
