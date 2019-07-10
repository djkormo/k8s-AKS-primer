#!/bin/bash

# set your name and resource group 
AKS_NAME=aks-simple18337
AKS_RG=rg-aks-simple
# get the resource group for VMs 
RG_VM_POOL=$(az aks show -g $AKS_RG -n $AKS_NAME --query nodeResourceGroup -o tsv)
  
echo $RG_VM_POOL

az vm list -d -g $RG_VM_POOL  | grep powerState

# stop VMs
az vm deallocate --ids $(az vm list -g $RG_VM_POOL --query "[].id" -o tsv) --no-wait

# or

# start VMS
az vm start --ids $(az vm list -g $RG_VM_POOL --query "[].id" -o tsv) --no-wait