#!/bin/bash

# bash controlling_VM_on_AKS.bash -o start -n aks-simple5129 -g rg-aks-simple

##1  start or stop
#$2  aks_name
#$3 ars-rg
# set your name and resource group 

while getopts n:g:o: option
do
case "${option}"
in
n) AKS_NAME=${OPTARG};;
g) AKS_RG=${OPTARG};;
o) OPERATION=${OPTARG};;
esac
done

echo "OPERATION: $OPERATION"
echo "AKS_NAME: $AKS_NAME"
echo "AKS_RG: $AKS_RG"

#AKS_NAME=aks-simple
#AKS_RG=rg-aks-simple

if [ -z "$OPERATION" ]
then
      echo "\$OPERATION is empty"
else
      echo "\$OPERATION is NOT empty"
fi

if [ -z "$AKS_NAME" ]
then
      echo "\$AKS_NAME is empty"
else
      echo "\$AKS_NAME is NOT empty"
fi

if [ -z "$AKS_RG" ]
then
      echo "\$AKS_RG is empty"
else
      echo "\$AKS_RG is NOT empty"
fi

# get the resource group for VMs 

RG_VM_POOL=$(az aks show -g $AKS_RG -n $AKS_NAME --query nodeResourceGroup -o tsv)
  
echo "RG_VM_POOL: $RG_VM_POOL"

az vm list -d -g $RG_VM_POOL  | grep powerState

# stop VMs
#az vm deallocate --ids $(az vm list -g $RG_VM_POOL --query "[].id" -o tsv) --no-wait

# or

# start VMS
#az vm start --ids $(az vm list -g $RG_VM_POOL --query "[].id" -o tsv) --no-wait


if [ "$OPERATION" -eq "start" ] ; 
then 
echo "starting VMs..."; 
az vm start --ids $(az vm list -g $RG_VM_POOL --query "[].id" -o tsv) --no-wait
else 
echo "stopping VM..."; 
az vm deallocate --ids $(az vm list -g $RG_VM_POOL --query "[].id" -o tsv) --no-wait
fi
