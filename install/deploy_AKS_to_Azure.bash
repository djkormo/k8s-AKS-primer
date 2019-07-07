#!/bin/bash

# based on https://docs.microsoft.com/en-us/azure/container-instances/container-instances-using-azure-container-registry

# zmienne konfiguracyjne

RND=$RANDOM

ACR_LOCATION=northeurope
ACR_GROUP=rg-aks-simple
ACR_NAME=acr$RND
ACI_NAME=aci$RND
AKV_NAME=keyvault$RND

# domyslna nazwa grupy 
az configure --defaults group=$ACR_GROUP

# domyslna lokalizacja rejestru z obrazami 
az configure --defaults location=$ACR_LOCATION

# utworzenie nowej grupy 
az group create --name $ACR_GROUP

# tworzymy rejestr dla kontenerów 
az acr create  --name $ACR_NAME --sku Basic

# włączenie konta administratorskiego
az acr update -n  $ACR_NAME --admin-enabled true


# service principal 
#az keyvault secret set \
#  --vault-name $AKV_NAME \
#  --name $ACR_NAME-pull-pwd \
#  --value $(az ad sp create-for-rbac \
#                --name http://$ACR_NAME-pull \
#                --scopes $(az acr show --name $ACR_NAME --query id --output tsv) \
#                --role acrpull \
#                --query password \
#                --output tsv)

				
#az keyvault secret set \
#    --vault-name $AKV_NAME \
#    --name $ACR_NAME-pull-usr \
#    --value $(az ad sp show --id http://$ACR_NAME-pull --query appId --output tsv)				




# pobranie najnowszej wersji AKS w danym regionie

AKS_VERSION=$(az aks get-versions -l $ACR_LOCATION --query 'orchestrators[-1].orchestratorVersion' -o tsv)


AKS_RG=$ACR_GROUP
AKS_NAME=aks-simple$RND
AKS_NODES=1
AKS_VM_SIZE=Standard_B2s





echo "$AKS_RG"
echo "$AKS_NAME"
echo "$AKS_NODES"
echo "$INIT_DIR"
echo "$SP_PASSWORD"
echo "$AKS_VERSION"
echo "$APP_ID"
echo "$AKS_VM_SIZE"



az aks create --resource-group $AKS_RG \
    --name  $AKS_NAME \
    --enable-addons monitoring \
    --kubernetes-version $AKS_VERSION \
    --generate-ssh-keys \
	--node-count $AKS_NODES \
	--node-vm-size $AKS_VM_SIZE \
	--tags 'environment=develop'  \
	--disable-rbac

	
# 1. Grant the AKS-generated service principal pull access to our ACR, the AKS cluster will be able to pull images of our ACR

CLIENT_ID=$(az aks show -g $AKS_RG -n $AKS_NAME --query "servicePrincipalProfile.clientId" -o tsv)

ACR_ID=$(az acr show -n $ACR_NAME -g $AKS_RG --query "id" -o tsv)

az role assignment create --assignee $CLIENT_ID --role acrpull --scope $ACR_ID

	
# Grant for Azure Devops to push to ACR 	
registryPassword=$(az ad sp create-for-rbac -n $ACR_NAME-push --scopes $ACR_ID --role acrpush --query password -o tsv)

registryName=$(az acr show -n $ACR_NAME -g $AKS_RG --query name)

registryLogin=$(az ad sp show --id http://$ACR_NAME-push --query appId -o tsv)


echo "CLIENT_ID"
echo $CLIENT_ID


echo "ACR_ID"
echo $ACR_ID

echo "registryName"
echo $registryName


echo "registryLogin"
echo $registryLogin

echo "registryPassword"
echo $registryPassword 


echo "CLIENT_ID" >> deploy_aks_simple.log
echo $CLIENT_ID >> deploy_aks_simple.log


echo "ACR_ID" >> deploy_aks_simple.log
echo $ACR_ID >> deploy_aks_simple.log

echo "registryName" >> deploy_aks_simple.log
echo $registryName >> deploy_aks_simple.log

echo "registryLogin" >> deploy_aks_simple.log
echo $registryLogin >> deploy_aks_simple.log


echo "registryPassword" >> deploy_aks_simple.log
echo $registryPassword >> deploy_aks_simple.log





