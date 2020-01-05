Using kubernetes API

```console
kubectl proxy --port 8080
```
<pre>
Starting to serve on 127.0.0.1:8080
</pre>
List all namespaces
curl --request GET \
  --url http://localhost:8080/api/v1/namespaces/

<pre>
{
      "metadata": {
        "name": "kube-system",
        "selfLink": "/api/v1/namespaces/kube-system",
        "uid": "a4217a1e-db7f-480f-b078-ca237113d659",
        "resourceVersion": "7375",
        "creationTimestamp": "2020-01-04T16:09:10Z",
        "labels": {
          "addonmanager.kubernetes.io/mode": "Reconcile",
          "control-plane": "true",
          "kubernetes.io/cluster-service": "true",
          "name": "kube-system"
        },
        "annotations": {
          "kubectl.kubernetes.io/last-applied-configuration": "{\"apiVersion\":\"v1\",\"kind\":\"Namespace\",\"metadata\":{\"annotations\":{},\"labels\":{\"addonmanager.kubernetes.io/mode\":\"Reconcile\",\"control-plane\":\"true\",\"kubernetes.io/cluster-service\":\"true\"},\"name\":\"kube-system\"}}\n"
        }
      },
      "spec": {
        "finalizers": [
          "kubernetes"
        ]
      },
      "status": {
        "phase": "Active"
      }
    }
</pre>

List all pods in kube-system namespace
curl --request GET \
  --url http://localhost:8080/api/v1/namespaces/kube-system/pods

Get a single pod in kube-system

curl --request GET \
  --url http://localhost:8080/api/v1/namespaces/kube-system/pods/calico-node-2nskn/

Creating pod

```yaml
apiVersion: v1
kind: Pod
metadata:
    name: ngnix-pod
spec:
   containers:
   - name: ngnix
     image: nginx:1.7.9
     ports:
     - containerPort: 80
```

kubectl run ngnix-pod  --generator=run-pod/v1 --port=80 --image=nginx:1.7.9 --dry-run -o yaml

```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: ngnix-pod
  name: ngnix-pod
spec:
  containers:
  - image: nginx:1.7.9
    name: ngnix-pod
    ports:
    - containerPort: 80
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```

kubectl run nginx-pod  --generator=run-pod/v1 --port=80 --image=nginx:1.7.9 --dry-run -o json

```json
{
    "kind": "Pod",
    "apiVersion": "v1",
    "metadata": {
        "name": "nginx-pod",
        "creationTimestamp": null,
        "labels": {
            "run": "nginx-pod"
        }
    },
    "spec": {
        "containers": [
            {
                "name": "nginx-pod",
                "image": "nginx:1.7.9",
                "ports": [
                    {
                        "containerPort": 80
                    }
                ],
                "resources": {}
            }
        ],
        "restartPolicy": "Always",
        "dnsPolicy": "ClusterFirst"
    },
    "status": {}
}
```

Creating pod in default namespace
```console
curl --request POST \
  --url http://localhost:8080/api/v1/namespaces/default/pods \
  --header 'content-type: application/json' \
  --data '{
    "kind": "Pod",
    "apiVersion": "v1",
    "metadata": {
        "name": "nginx-pod",
        "creationTimestamp": null,
        "labels": {
            "run": "nginx-pod"
        }
    },
    "spec": {
        "containers": [
            {
                "name": "nginx-pod",
                "image": "nginx:1.7.9",
                "ports": [
                    {
                        "containerPort": 80
                    }
                ],
                "resources": {}
            }
        ],
        "restartPolicy": "Always",
        "dnsPolicy": "ClusterFirst"
    },
    "status": {}
}'

'''
```console
kubectl get pods -n default
```
<pre>
NAME        READY   STATUS    RESTARTS   AGE
nginx-pod   1/1     Running   0          42s
</pre>

Deleting pod from default namespace

```console
curl --request DELETE \
  --url http://localhost:8080/api/v1/namespaces/default/pods/nginx-pod
```
<pre>

</pre>

```console
kubectl get pods -n default
```
<pre>
No resources found.
</pre>


List all deployment in kube-system namespace

```console
curl --request GET \
  --url http://localhost:8080/apis/apps/v1/namespaces/kube-system/deployments
```

```json
...
  "status": {
        "observedGeneration": 1,
        "replicas": 1,
        "updatedReplicas": 1,
        "readyReplicas": 1,
        "availableReplicas": 1,
        "conditions": [
          {
            "type": "Available",
            "status": "True",
            "lastUpdateTime": "2020-01-04T16:09:33Z",
            "lastTransitionTime": "2020-01-04T16:09:33Z",
            "reason": "MinimumReplicasAvailable",
            "message": "Deployment has minimum availability."
          }
        ]
      }
...
```

Listing details of coredns deployment in kube-system namespace

```console
curl --request GET \
  --url http://localhost:8080/apis/apps/v1/namespaces/kube-system/deployments/coredns
```

```json
...

"strategy": {
      "type": "RollingUpdate",
      "rollingUpdate": {
        "maxUnavailable": 1,
        "maxSurge": 1
      }

...

"status": {
    "observedGeneration": 2,
    "replicas": 2,
    "updatedReplicas": 2,
    "readyReplicas": 2,
    "availableReplicas": 2,
    "conditions": [
      {
        "type": "Available",
        "status": "True",
        "lastUpdateTime": "2020-01-05T13:27:12Z",
        "lastTransitionTime": "2020-01-05T13:27:12Z",
        "reason": "MinimumReplicasAvailable",
        "message": "Deployment has minimum availability."
      }
    ]
  }
...
```

Creating ddeployment in default namespace
```console
kubectl run nginx-deployment  --port=80 \
  --image=nginx:1.7.9 --dry-run -o yaml
```
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    run: nginx-deployment
  name: nginx-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      run: nginx-deployment
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        run: nginx-deployment
    spec:
      containers:
      - image: nginx:1.7.9
        name: nginx-deployment
        ports:
        - containerPort: 80
        resources: {}
status: {}
```


```console
kubectl run nginx-deployment  --port=80   \
  --image=nginx:1.7.9 --dry-run -o json
```

```json

{
    "kind": "Deployment",
    "apiVersion": "apps/v1",
    "metadata": {
        "name": "nginx-deployment",
        "creationTimestamp": null,
        "labels": {
            "run": "nginx-deployment"
        }
    },
    "spec": {
        "replicas": 1,
        "selector": {
            "matchLabels": {
                "run": "nginx-deployment"
            }
        },
        "template": {
            "metadata": {
                "creationTimestamp": null,
                "labels": {
                    "run": "nginx-deployment"
                }
            },
            "spec": {
                "containers": [
                    {
                        "name": "nginx-deployment",
                        "image": "nginx:1.7.9",
                        "ports": [
                            {
                                "containerPort": 80
                            }
                        ],
                        "resources": {}
                    }
                ]
            }
        },
        "strategy": {}
    },
    "status": {}
}

```
```console
curl --request POST \
  --url http://localhost:8080/apis/apps/v1/namespaces/default/deployments \
  --header 'content-type: application/json' \
  --data '
  {
    "kind": "Deployment",
    "apiVersion": "apps/v1",
    "metadata": {
        "name": "nginx-deployment",
        "creationTimestamp": null,
        "labels": {
            "run": "nginx-deployment"
        }
    },
    "spec": {
        "replicas": 1,
        "selector": {
            "matchLabels": {
                "run": "nginx-deployment"
            }
        },
        "template": {
            "metadata": {
                "creationTimestamp": null,
                "labels": {
                    "run": "nginx-deployment"
                }
            },
            "spec": {
                "containers": [
                    {
                        "name": "nginx-deployment",
                        "image": "nginx:1.7.9",
                        "ports": [
                            {
                                "containerPort": 80
                            }
                        ],
                        "resources": {}
                    }
                ]
            }
        },
        "strategy": {}
    },
    "status": {}
}
  '
```

```console
kubectl get deploy -n default
```
<pre>
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   1/1     1            1           83s
</pre>

Deleting deployment nginx-deployment in default namespace

```console
curl --request DELETE \
  --url http://localhost:8080/apis/apps/v1/namespaces/default/deployments/nginx-deployment
```

```console
kubectl get deploy -n default
```
<pre>
No resources found.
</pre>
Literature:

http://blog.madhukaraphatak.com/understanding-k8s-api-part-1/
http://blog.madhukaraphatak.com/understanding-k8s-api-part-2/
http://blog.madhukaraphatak.com/understanding-k8s-api-part-3/

