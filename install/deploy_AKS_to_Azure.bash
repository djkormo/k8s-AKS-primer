#!/bin/bash

# based on https://docs.microsoft.com/en-us/azure/container-instances/container-instances-using-azure-container-registry


# -o create ,delete ,status. shutdown
# -n aks-name
# -g aks-rg
# set your name and resource group

# deploy_AKS_to_Azure.bash -n aks-simple2020 -g rg-aks-simple -l northeurope, -o create


display_usage() { 
	echo "Example of usage:" 
	echo -e "bash deploy_AKS_to_Azure.bash -n aks-simple2020 -g rg-aks-simple -l northeurope -o create" 
	echo -e "bash deploy_AKS_to_Azure.bash -n aks-simple2020 -g rg-aks-simple -l northeurope -o stop" 
	echo -e "bash deploy_AKS_to_Azure.bash -n aks-simple2020 -g rg-aks-simple -l northeurope -o start" 
	echo -e "bash deploy_AKS_to_Azure.bash -n aks-simple2020 -g rg-aks-simple -l northeurope -o status" 
	echo -e "bash deploy_AKS_to_Azure.bash -n aks-simple2020 -g rg-aks-simple -l northeurope -o delete" 
	} 

while getopts n:g:o:l: option
do
case "${option}"
in
n) AKS_NAME=${OPTARG};;
g) AKS_RG=${OPTARG};;
o) AKS_OPERATION=${OPTARG};;
l) AKS_LOCATION=${OPTARG};;
esac
done


if [ -z "$AKS_OPERATION" ]
then
      echo "\$AKS_OPERATION is empty"
	  display_usage
	  exit 1
else
      echo "\$AKS_OPERATION is NOT empty"
fi

if [ -z "$AKS_NAME" ]
then
      echo "\$AKS_NAME is empty"
	  display_usage
	  exit 
else
      echo "\$AKS_NAME is NOT empty"
fi

if [ -z "$AKS_RG" ]
then
      echo "\$AKS_RG is empty"
	  display_usage
	  exit 1
else
      echo "\$AKS_RG is NOT empty"
fi

if [ -z "$AKS_LOCATION" ]
then
      echo "\$AKS_LOCATION is empty"
	  display_usage
	  exit 1
else
      echo "\$AKS_LOCATION is NOT empty"
fi


echo "AKS_OPERATION: $AKS_OPERATION"
echo "AKS_NAME: $AKS_NAME"
echo "AKS_RG: $AKS_RG"
echo "AKS_LOCATION: $AKS_LOCATION"

# zmienne konfiguracyjne

RND=$RANDOM

ACR_LOCATION=$AKS_LOCATION
ACR_GROUP=$AKS_RG
ACR_NAME=acr$RND
AKV_NAME=keyvault$RND

# domyslna nazwa grupy 
az configure --defaults group=$AKS_RG

# domyslna lokalizacja rejestru z obrazami 
az configure --defaults location=$ACR_LOCATION



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


AKS_RG=$AKS_RG
AKS_NAME=$AKS_NAME
AKS_NODES=2
AKS_VM_SIZE=Standard_B2s


echo "AKS_NODES: $AKS_NODES"
echo "AKS_VERSION: $AKS_VERSION"
echo "AKS_VM_SIZE: $AKS_VM_SIZE"



if [ "$AKS_OPERATION" = "create" ] ;
then
echo "Creating AKS cluster...";

	# utworzenie nowej grupy 
	az group create --name $ACR_GROUP

	# tworzymy rejestr dla kontenerów 
	az acr create  --name $ACR_NAME --sku Basic

	# włączenie konta administratorskiego
	az acr update -n  $ACR_NAME --admin-enabled true
	# tworzymy klaster AKS 

	az aks create --resource-group $AKS_RG \
		--name  $AKS_NAME \
		--vm-set-type AvailabilitySet \
		--enable-addons monitoring \
		--kubernetes-version $AKS_VERSION \
		--generate-ssh-keys \
		--node-count $AKS_NODES \
		--node-vm-size $AKS_VM_SIZE \
		--tags 'environment=develop'  \
		--network-plugin kubenet \
		--network-policy calico 

		#--disable-rbac

	
	# 1. Grant the AKS-generated service principal pull access to our ACR, the AKS cluster will be able to pull images of our ACR

	CLIENT_ID=$(az aks show -g $AKS_RG -n $AKS_NAME --query "servicePrincipalProfile.clientId" -o tsv)

	ACR_ID=$(az acr show -n $ACR_NAME -g $AKS_RG --query "id" -o tsv)

	az role assignment create --assignee $CLIENT_ID --role acrpull --scope $ACR_ID

		
	# Grant for Azure Devops to push to ACR 	
	registryPassword=$(az ad sp create-for-rbac -n $ACR_NAME-push --scopes $ACR_ID --role acrpush --query password -o tsv)

	registryName=$(az acr show -n $ACR_NAME -g $AKS_RG --query name)

	registryLogin=$(az ad sp show --id http://$ACR_NAME-push --query appId -o tsv)

    LOG_FILE ='deploy_log_aks_simple.log' 
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


	echo "CLIENT_ID" >> $LOG_FILE
	echo $CLIENT_ID >> $LOG_FILE


	echo "ACR_ID" >> $LOG_FILE
	echo $ACR_ID >> $LOG_FILE

	echo "registryName" >> $LOG_FILE
	echo $registryName >> $LOG_FILE

	echo "registryLogin" >> $LOG_FILE
	echo $registryLogin >> $LOG_FILE


	echo "registryPassword" >> $LOG_FILE
	echo $registryPassword >> $LOG_FILE

fi



if [ "$AKS_OPERATION" = "start" ] ;
then
echo "starting VMs...";
  # get the resource group for VMs
  
  RG_VM_POOL=$(az aks show -g $AKS_RG -n $AKS_NAME --query nodeResourceGroup -o tsv)
  echo "RG_VM_POOL: $RG_VM_POOL"
  
  az vm list -d -g $RG_VM_POOL  | grep powerState 
  az vm start --ids $(az vm list -g $RG_VM_POOL --query "[].id" -o tsv) --no-wait
fi
 
if [ "$AKS_OPERATION" = "stop" ] ;
then
echo "stopping VMs...";
  # get the resource group for VMs
  RG_VM_POOL=$(az aks show -g $AKS_RG -n $AKS_NAME --query nodeResourceGroup -o tsv)

  echo "RG_VM_POOL: $RG_VM_POOL"

  az vm list -d -g $RG_VM_POOL  | grep powerState

  az vm deallocate --ids $(az vm list -g $RG_VM_POOL --query "[].id" -o tsv) --no-wait
fi


if [ "$AKS_OPERATION" = "status" ] ;
then
  echo "AKS cluster status";
  az aks show --name $AKS_NAME --resource-group $AKS_RG
  
  # get the resource group for VMs
  RG_VM_POOL=$(az aks show -g $AKS_RG -n $AKS_NAME --query nodeResourceGroup -o tsv)
  echo "RG_VM_POOL: $RG_VM_POOL"
  
  az vm list -d -g $RG_VM_POOL  | grep powerState 
  
fi 


if [ "$AKS_OPERATION" = "delete" ] ;
then
  echo "AKS cluster deleting ";
  az aks delete --name $AKS_NAME --resource-group $AKS_RG
  
fi 




