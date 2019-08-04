#!/bin/bash

# bash controlling_VM_on_AKS.bash -o start -n aks-simple5129 -g rg-aks-simple

# -o start , stop, status
# -n aks-name
# -g aks-rg
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

echo "OPERATION: $OPERATION"
echo "AKS_NAME: $AKS_NAME"
echo "AKS_RG: $AKS_RG"


# get the resource group for VMs

RG_VM_POOL=$(az aks show -g $AKS_RG -n $AKS_NAME --query nodeResourceGroup -o tsv)

echo "RG_VM_POOL: $RG_VM_POOL"

az vm list -d -g $RG_VM_POOL  | grep powerState


if [ "$OPERATION" = "start" ] ;
then
echo "starting VMs...";
az vm start --ids $(az vm list -g $RG_VM_POOL --query "[].id" -o tsv) --no-wait
fi

if [ "$OPERATION" = "stop" ] ;
then
echo "stopping VMs...";
az vm deallocate --ids $(az vm list -g $RG_VM_POOL --query "[].id" -o tsv) --no-wait
fi

if [ "$OPERATION" = "status" ] ;
then
echo "listing VMs...";
az vm list -g $RG_VM_POOL -o table
fi