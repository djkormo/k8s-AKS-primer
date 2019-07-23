
### Based on https://zimmergren.net/mount-an-azure-storage-file-share-to-deployments-in-azure-kubernetes-services-aks/

### Create new namespace
```console
kubectl create namespace azure-files
```

### get account name and key from storage account
```console

```
###  create secret for storing credentials
```console
kubectl create -f azure-secrets.yaml
```

### Deploy an application
```console
kubectl apply -f azure-files-deployment.yaml --namespace=azure-files
```
### Verify deployment
```console
kubectl get deploy -n blogdemodeployments -o json
```

kubectl get pod -n azure-files