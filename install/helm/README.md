#### Create a service account

```console

kubectl apply -f helm-rbac.yaml

```

#### What is inside of helm-rbac.yaml
```yaml 
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
	
```

#### Install Helm on AKS

```console
helm init --service-account tiller --node-selectors "beta.kubernetes.io/os"="linux"
```


#### Install sample application

```console
kubectl create namespace wordpress
```

```console
helm install --namespace wordpress --name wordpress stable/wordpress
```

####  Get IP of Wordpress site
```console
kubectl get svc --namespace wordpress wordpress-wordpress
kubectl describe svc --namespace wordpress wordpress-wordpress |grep Ingress
echo http://$(kubectl get svc --namespace wordpress wordpress-wordpress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
```

#### Get password of user (Wordpress admin role)

```console
echo Password: $(kubectl get secret --namespace wordpress wordpress-wordpress -o jsonpath="{.data.wordpress-password}" | base64 --decode)
```





