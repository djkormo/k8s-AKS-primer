Examples



### Creating name space for examples

```console
kubectl create namespace examples
```

namespace/examples created


# switching to examples namespace

```console
kubectl config set-context --current  --namespace=examples
```
Context "***" modified.



### Create first pod

```console
kubectl run simple-service --image=mhausenblas/simpleservice:0.5.0 --port=9876
```

deployment.apps/simple-service created



### show  pod

NAME                              READY   STATUS              RESTARTS   AGE
simple-service-754cdf9949-qjsdg   0/1     ContainerCreating   0          46s

NAME                              READY   STATUS    RESTARTS   AGE
simple-service-754cdf9949-qjsdg   1/1     Running   0          70s

### show deployment

```console
kubectl get deployment

```
NAME             READY   UP-TO-DATE   AVAILABLE   AGE
simple-service   1/1     1            1           2m11s 

### show replicaset 

```console
kubectl get replicaset
```

NAME                        DESIRED   CURRENT   READY   AGE
simple-service-754cdf9949   1         1         1       3m

### show port and IP of simpleservice pod

```console
kubectl describe po |grep IP
```

IP:             10.244.1.43

```console
kubectl describe po |grep Port
```

Port:           10000/TCP
Host Port:      0/TCP



### how to get pod name 

kubectl get pod --namespace examples

NAME                              READY   STATUS    RESTARTS   AGE
simple-service-754cdf9949-qjsdg   1/1     Running   0          7m5s

### the same information in json format 

```console
kubectl get pod --namespace examples -o json
```
... inside ....

{
    "apiVersion": "v1",
    "items": [
        {
            "apiVersion": "v1",
            "kind": "Pod",
            "metadata": {
                "creationTimestamp": "2019-07-07T11:39:44Z",
                "generateName": "simple-service-754cdf9949-",
                "labels": {
                    "pod-template-hash": "754cdf9949",
                    "run": "simple-service"
                },
                "name": "simple-service-754cdf9949-qjsdg",
                "namespace": "examples"
                
            },
            "spec": {
                "containers": [
                    {
                        "image": "mhausenblas/simpleservice:0.5.0",
                        "imagePullPolicy": "IfNotPresent",
                        "name": "simple-service",
                        "ports": [
                            {
                                "containerPort": 9876,
                                "protocol": "TCP"
                            }
                        ]
                        
                    }
                ],
                
            
                "hostIP": "10.240.0.4",
                "phase": "Running",
                "podIP": "10.244.1.43",
                "
            }
        }
    ],
    
}


... inside ...

### the same information in yaml format 

```console
kubectl get pod --namespace examples -o yaml
```
... inside ...
apiVersion: v1
items:
- apiVersion: v1
  kind: Pod
  spec:
    containers:
    - image: mhausenblas/simpleservice:0.5.0
      imagePullPolicy: IfNotPresent
      name: simple-service
      ports:
      - containerPort: 9876
        protocol: TCP
... inside ...

### the same information using templates 


```console
kubectl get pod --namespace examples -o template --template "{{(index .items 0).metadata.name}}"

```

simple-service-754cdf9949-qjsdg

### forwarding port 

```console
kubectl port-forward $(kubectl get pod --namespace examples -o template --template "{{(index .items 0).metadata.name}}") 9876:9876

```
Forwarding from 127.0.0.1:9876 -> 9876
Forwarding from [::1]:9876 -> 9876

### Use brower -> http://localhost:9876/health


### You can do the sam in a simpler way

```console
kubectl port-forward deployment/simple-service 9876:6379 
```console 

### or
 
```console
kubectl port-forward rs/simple-service 9876:9876 
```

### After all delete namespace examples 
 
```console
kubectl delete namespace examples 
```

namespace "examples" deleted


### based on http://kubernetesbyexample.com/