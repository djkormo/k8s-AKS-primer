
### Based on https://zimmergren.net/mount-an-azure-storage-file-share-to-deployments-in-azure-kubernetes-services-aks/

### Create new namespace
```console
kubectl create namespace azure-files
```
### Create dedicated storage account
```console
az storage account create \
  --name myaksstorageaccount5129 \
  --resource-group rg-aks-simple \
  --location northeurope \
  --sku Standard_LRS \
  --encryption blob
```

### get account name and key from storage account
```console

az storage account keys list \
  --account-name myaksstorageaccount5129 \
  --resource-group rg-aks-simple \
  --output table


 storagekey=$(az storage account keys list \
    --resource-group "rg-aks-simple" \
    --account-name myaksstorageaccount5129 \
    --query "[0].value" | tr -d '"')   

echo $storagekey

az storage share create \
    --account-name myaksstorageaccount5129 \
    --account-key $storagekey \
    --name "myshareforpods" 

```
### convert to base64
echo myaksstorageaccount5129 | base64
echo $storagekey | base64

###  create secret for storing credentials
```console
kubectl create -f azure-secrets.yaml --namespace=azure-files
```

### Deploy an application

```console
kubectl apply -f azure-files-deployment.yaml --namespace=azure-files
```
### Verify deployment

```console
kubectl get deploy -n deployment-azurestorage-test -o json  --namespace=azure-files
```

```console
kubectl get pod -n azure-files
```

### cleaning objects


#### namespace in k8s
```console
kubectl delete namespace/azure-files
```

#### storage account in Azure
```console
az storage account delete -n myaksstorageaccount5129 -g rg-aks-simple
```

