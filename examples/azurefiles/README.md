
### Based on https://zimmergren.net/mount-an-azure-storage-file-share-to-deployments-in-azure-kubernetes-services-aks/

https://talkcloudlytome.com/using-azure-file-shares-to-mount-a-volume-in-kubernetes/



##### create storage account and file shares
```console
AKS_PERS_STORAGE_ACCOUNT_NAME=mystorageaccount$RANDOM
AKS_PERS_RESOURCE_GROUP=rg-aks-simple
AKS_PERS_LOCATION=northeurope
AKS_PERS_SHARE_NAME=configfiles

# Create a resource group
az group create --name $AKS_PERS_RESOURCE_GROUP --location $AKS_PERS_LOCATION

# Create a storage account
az storage account create -n $AKS_PERS_STORAGE_ACCOUNT_NAME -g $AKS_PERS_RESOURCE_GROUP -l $AKS_PERS_LOCATION --sku Standard_LRS

# Export the connection string as an environment variable, this is used when creating the Azure file share
export AZURE_STORAGE_CONNECTION_STRING=`az storage account show-connection-string -n $AKS_PERS_STORAGE_ACCOUNT_NAME -g $AKS_PERS_RESOURCE_GROUP -o tsv`

# Create the file share
az storage share create -n $AKS_PERS_SHARE_NAME --connection-string $AZURE_STORAGE_CONNECTION_STRING

# Get storage account key
STORAGE_KEY=$(az storage account keys list --resource-group $AKS_PERS_RESOURCE_GROUP --account-name $AKS_PERS_STORAGE_ACCOUNT_NAME --query "[0].value" -o tsv)

# Echo storage account name and key
echo Storage account name: $AKS_PERS_STORAGE_ACCOUNT_NAME
echo Storage account key: $STORAGE_KEY
```


##### Create new namespace 
```console
kubectl create ns filesharetest
```
##### Create  secret for storing account name and account key

```console
YourAzureStorageAccountNameHere=$AKS_PERS_STORAGE_ACCOUNT_NAME
YourAzureStorageAccountKeyHere=$STORAGE_KEY
echo $YourAzureStorageAccountNameHere
echo $YourAzureStorageAccountKeyHere
kubectl create secret generic azure-fileshare-secret \
  --from-literal=azurestorageaccountname=$YourAzureStorageAccountNameHere  \
  --from-literal=azurestorageaccountkey=$YourAzureStorageAccountKeyHere -n filesharetest
```

##### You don't specify a namespace when creating a PV - they are cluster-level resources
```console
kubectl apply -f persistent-volume.yaml
```
<pre>
persistentvolume/fileshare-pv created
</pre>

```console
kubectl get pv fileshare-pv
```
<pre>
NAME           CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   REASON
AGE
fileshare-pv   10Gi       RWX            Retain           Available
79s
</pre>

#### Create persistent volume claim
```console
kubectl apply -f persistent-volume-claim.yaml
```
<pre>
persistentvolumeclaim/fileshare-pvc created
</pre>

```console
kubectl get pvc -n filesharetest
```
<pre>
NAME            STATUS   VOLUME         CAPACITY   ACCESS MODES   STORAGECLASS   AGE
fileshare-pvc   Bound    fileshare-pv   10Gi       RWX                           91s
</pre>


```console
kubectl apply -f persistent-volume-deployment.yaml
```
<pre>
deployment.apps/fileshare-deployment created
</pre>
```
kubectl get all --namespace=filesharetest
```
<pre>
NAME                                        READY   STATUS    RESTARTS   AGE
pod/fileshare-deployment-56f4bb47db-xd2tj   1/1     Running   0          34m

NAME                                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/fileshare-deployment   1/1     1            1           34m

NAME                                              DESIRED   CURRENT   READY   AGE
replicaset.apps/fileshare-deployment-56f4bb47db   1         1         1       34m
</pre>




##### Testing azure files from inside pod 
YOUR_POD_NAME=$(kubectl get pods -l app=fileshare-deployment -o jsonpath={.items[0].metadata.name})
echo $YOUR_POD_NAME
kubectl exec -it $YOUR_POD_NAME -n filesharetest  bash
<pre>
ls -la /configfiles/
drwxrwxrwx 2 root root    0 Aug  6 08:40 .
drwxr-xr-x 1 root root 4096 Aug  6 08:54 ..
touch test.txt
ls -la /configfiles/
drwxrwxrwx 2 root root    0 Aug  6 08:40 .
drwxr-xr-x 1 root root 4096 Aug  6 08:54 ..
-rwxrwxrwx 1 root root    0 Aug  6 08:56 test.txt


### after uploading file from Azure Portal
ls -la /configfiles/
drwxrwxrwx 2 root root      0 Aug  6 08:40 .
drwxr-xr-x 1 root root   4096 Aug  6 08:54 ..
-rwxrwxrwx 1 root root 136599 Aug  6 09:32 Creating a Kubernetes Cluster in Azure using Kubeadm.pdf
-rwxrwxrwx 1 root root      0 Aug  6 08:56 test.txt
</pre>

##### how to get credenentials from secret
```console
kubectl get secret  azure-fileshare-secret -o yaml

```

```yaml
apiVersion: v1
data:
  azurestorageaccountkey: disraDUzeTNSM0Q1aEJKQk5peExyRmZJVWhpTzdWRUdWcm1JOTVkOWNkQURNMGl2c2pSejAzWXJtblV0a2x2c0JpUG5vTGRVRDF1UE4yUzdWMW1MMlE9PQ==
  azurestorageaccountname: bXlzdG9yYWdlYWNjb3VudDE2Mzg5
kind: Secret
metadata:
  creationTimestamp: "2019-08-06T08:39:10Z"
  name: azure-fileshare-secret
  namespace: filesharetest
  resourceVersion: "1903952"
  selfLink: /api/v1/namespaces/filesharetest/secrets/azure-fileshare-secret
  uid: a96bec01-b825-11e9-8fb6-7a04c9d91c64
type: Opaque
```


#### how to change secret

#### hard way

##### delete
```
kubectl delete secret azure-fileshare-secret
```
#### and recreate
```
kubectl create secret generic azure-fileshare-secret \
  --from-literal=azurestorageaccountname=$YourAzureStorageAccountNameHere  \
  --from-literal=azurestorageaccountkey=$YourAzureStorageAccountKeyHere -n filesharetest
```

##### or patch the content

```console
echo "NewAccount" |base64
echo "NewKey" |base64
##### put values  to secret definitions
kubectl patch secret azure-fileshare-secret -p='{"data":{"azurestorageaccountname": "account"}}' -v=1
kubectl patch secret azure-fileshare-secret -p='{"data":{"azurestorageaccountkey": "key"}}' -v=1
```

