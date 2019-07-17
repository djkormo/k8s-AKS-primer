#### Create a service account

```console

kubectl apply -f helm-rbac.yaml

```

#### What is inside of helm-rbac.yaml

apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system
	


#### Install Helm on AKS

```console
helm init --service-account tiller --node-selectors "beta.kubernetes.io/os"="linux"
```

