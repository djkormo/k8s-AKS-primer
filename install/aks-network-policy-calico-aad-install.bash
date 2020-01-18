#!/bin/bash

RESOURCE_GROUP_NAME=rg-aks-simple
CLUSTER_NAME=aks-simple2020
LOCATION=northeurope

AKS_VERSION=$(az aks get-versions -l $LOCATION --query 'orchestrators[-1].orchestratorVersion' -o tsv)

AKS_NODES=2
AKS_VM_SIZE=Standard_B2s

echo "RESOURCE_GROUP_NAME :$RESOURCE_GROUP_NAME"
echo "CLUSTER_NAME: $CLUSTER_NAME"
echo "LOCATION: $LOCATION"
echo "AKS_NODES: $AKS_NODES"
echo "AKS_VM_SIZE: $AKS_VM_SIZE"

# Create the Azure AD application
serverApplicationId=$(az ad app create \
    --display-name "${CLUSTER_NAME}Server" \
    --identifier-uris "https://${CLUSTER_NAME}Server" \
    --query appId -o tsv)
echo "serverApplicationId: $serverApplicationId"

# Update the application group memebership claims
az ad app update --id $serverApplicationId --set groupMembershipClaims=All



# Create a service principal for the Azure AD application
az ad sp create --id $serverApplicationId

# Get the service principal secret
serverApplicationSecret=$(az ad sp credential reset \
    --name $serverApplicationId \
    --credential-description "AKSPassword" \
    --query password -o tsv)


az ad app permission grant --id $serverApplicationId --api 00000003-0000-0000-c000-000000000000
az ad app permission admin-consent --id  $serverApplicationId

clientApplicationId=$(az ad app create \
    --display-name "${CLUSTER_NAME}Client" \
    --native-app \
    --reply-urls "https://${CLUSTER_NAME}Client" \
    --query appId -o tsv)

echo "clientApplicationId: $clientApplicationId"

az ad sp create --id $clientApplicationId

oAuthPermissionId=$(az ad app show --id $serverApplicationId --query "oauth2Permissions[0].id" -o tsv)

az ad app permission add --id $clientApplicationId --api $serverApplicationId --api-permissions $oAuthPermissionId=Scope
az ad app permission grant --id $clientApplicationId --api $serverApplicationId



# Create a resource group
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION

# Create a virtual network and subnet
az network vnet create \
    --resource-group $RESOURCE_GROUP_NAME \
    --name myVnet \
    --address-prefixes 10.0.0.0/8 \
    --subnet-name myAKSSubnet \
    --subnet-prefix 10.240.0.0/16

# Create a service principal and read in the application ID
SP=$(az ad sp create-for-rbac --output json)
SP_ID=$(echo $SP | jq -r .appId)
SP_PASSWORD=$(echo $SP | jq -r .password)

echo "SP: $SP" 
echo "SP_ID: $SP_ID" 
echo "SP_PASSWORD: $SP_PASSWORD" 

# Wait 15 seconds to make sure that service principal has propagated
echo "Waiting for service principal to propagate..."
sleep 15

# Get the virtual network resource ID
VNET_ID=$(az network vnet show --resource-group $RESOURCE_GROUP_NAME --name myVnet --query id -o tsv)
echo "VNET_ID: $VNET_ID"
# Assign the service principal Contributor permissions to the virtual network resource
az role assignment create --assignee $SP_ID --scope $VNET_ID --role Contributor

# Get the virtual network subnet resource ID
SUBNET_ID=$(az network vnet subnet show --resource-group $RESOURCE_GROUP_NAME --vnet-name myVnet --name myAKSSubnet --query id -o tsv)
echo "SUBNET_ID: $SUBNET_ID"

# Create the AKS cluster and specify the virtual network and service principal information
# Enable network policy by using the `--network-policy` parameter

tenantId=$(az account show --query tenantId -o tsv)


echo "RESOURCE_GROUP_NAME: $RESOURCE_GROUP_NAME"
echo "CLUSTER_NAME: $CLUSTER_NAME"
echo "AKS_VERSION: $AKS_VERSION"
echo "AKS_VM_SIZE: $AKS_VM_SIZE"
echo "SUBNET_ID: $SUBNET_ID"
echo "SP_ID: $SP_ID"
echo "SP_PASSWORD: $SP_PASSWORD"
echo "serverApplicationId: $serverApplicationId"
echo "serverApplicationSecret: $serverApplicationSecret"
echo "clientApplicationId: $clientApplicationId"
echo "tenantId: $tenantId"

az aks create \
    --resource-group $RESOURCE_GROUP_NAME \
    --name $CLUSTER_NAME \
	--vm-set-type AvailabilitySet \
	--enable-addons monitoring \
	--kubernetes-version $AKS_VERSION \
    --node-vm-size $AKS_VM_SIZE \
    --node-count $AKS_NODES \
    --generate-ssh-keys \
    --network-plugin azure \
    --service-cidr 10.0.0.0/16 \
    --dns-service-ip 10.0.0.10 \
    --docker-bridge-address 172.17.0.1/16 \
    --vnet-subnet-id $SUBNET_ID \
    --service-principal $SP_ID \
    --client-secret $SP_PASSWORD \
    --aad-server-app-id $serverApplicationId \
    --aad-server-app-secret $serverApplicationSecret \
    --aad-client-app-id $clientApplicationId \
    --aad-tenant-id $tenantId \
    --network-policy calico 


RESOURCE_GROUP_NAME=rg-aks-simple
CLUSTER_NAME=aks-simple2020
LOCATION=northeurope



### TODO Adding Azure Container Registry

RND=$RANDOM

ACR_LOCATION=$LOCATION
ACR_GROUP=$RESOURCE_GROUP_NAME
ACR_NAME=acr$RND
AKV_NAME=keyvault$RND

echo "ACR_LOCATION: $ACR_LOCATION"
echo "ACR_GROUP: $ACR_GROUP"
echo "ACR_NAME: $ACR_NAME"
echo "AKV_NAME: $AKV_NAME"

# domyslna nazwa grupy 
az configure --defaults group=$ACR_GROUP

# domyslna lokalizacja rejestru z obrazami 
az configure --defaults location=$ACR_LOCATION


az acr create --resource-group $ACR_GROUP --name $ACR_NAME --sku Basic --location $ACR_LOCATION 

CLIENT_ID=$(az aks show -g $AKS_RG -n $AKS_NAME --query "servicePrincipalProfile.clientId" -o tsv)

ACR_ID=$(az acr show -n $ACR_NAME -g $AKS_RG --query "id" -o tsv)

az role assignment create --assignee $CLIENT_ID --role acrpull --scope $ACR_ID


# Grant for Azure Devops to push to ACR 	
registryPassword=$(az ad sp create-for-rbac -n $ACR_NAME-push --scopes $ACR_ID --role acrpush --query password -o tsv)

registryName=$(az acr show -n $ACR_NAME -g $AKS_RG --query name)

registryLogin=$(az ad sp show --id http://$ACR_NAME-push --query appId -o tsv)

##  Adding Azure Key vault


az keyvault create --resource-group $ACR_GROUP --name $AKV_NAME

# Create Service Principal to access Azure Key Vault
SP_KV=$(az ad sp create-for-rbac --name "http://$AKV_NAME-pull" --skip-assignment --output json )

SP_KV_ID=$(echo $SP_KV | jq -r .appId)
SP_KV_PASSWORD=$(echo $SP_KV | jq -r .password)

echo "SP_KV: $SP_KV"
echo "SP_KV_ID: $SP_KV_ID"
echo "SP_KV_PASSWORD: $SP_KV_PASSWORD"


KEYVAULT_ID=$(az keyvault show --name $AKV_NAME --query id --output tsv)

echo "KEYVAULT_ID: $KEYVAULT_ID"

az role assignment create --role Reader --assignee "http://$AKV_NAME-pull" --scope "$KEYVAULT_ID"

az keyvault set-policy -n $AKV_NAME --secret-permissions get --spn $SP_KV_ID # how to get appId ?



    #https://docs.microsoft.com/en-us/azure/aks/azure-ad-integration-cli
    # https://aksworkshop.io/