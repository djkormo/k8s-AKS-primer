#!/bin/bash

# build_on_azure.bash -o build -n acr-123 -g rg-aks-simple

# build_on_azure.bash -o rebuild -n acr-123 -g rg-aks-simple

# build_on_azure.bash -o delete -n acr-123 -g rg-aks-simple

usage() { echo "Usage: $0 -o build -n acr-123 -g rg-aks-simple" 1>&2; exit 1; }

while getopts n:g:o: option
do
case "${option}"
in
n) ACR_NAME=${OPTARG};;
g) ACR_RG=${OPTARG};;
o) OPERATION=${OPTARG};;
esac
done


if [ -z "$OPERATION" ]
then
      echo "\$OPERATION is empty"
else
      echo "\$OPERATION is NOT empty"
fi

if [ -z "$ACR_NAME" ]
then
      echo "\$ACR_NAME is empty"
else
      echo "\$ACR_NAME is NOT empty"
fi

if [ -z "$ACR_RG" ]
then
      echo "\$ACR_RG is empty"
else
      echo "\$ACR_RG is NOT empty"
fi

echo "OPERATION: $OPERATION"
echo "AKS_NAME: $AKS_NAME"
echo "AKS_RG: $AKS_RG"

if [ -z "$ACR_NAME" ] || [ -z "$OPERATION" ]; then
    usage
fi


# budujemy obraz kontenerowy  na podstawie zawartości pliku Dockerfile

if [ "$OPERATION" = "build" ] ;
then
echo "Building image...";
az acr build --registry $ACR_NAME --image np-frontend:v1 .
# szczegoly 
az acr repository show -n $ACR_NAME -t np-frontend:v1
fi

if [ "$OPERATION" = "rebuild" ] ;
then
echo "Rebuilding image...";
az acr repository delete --name $ACR_NAME --repository np-frontend:v1
az acr build --registry $ACR_NAME --image np-frontend:v1 .
# szczegoly 
az acr repository show -n $ACR_NAME -t np-frontend:v1

fi


if [ "$OPERATION" = "delete" ] ;
then
echo "deleting  image...";
az acr repository delete --name $ACR_NAME --repository np-frontend:v1
fi



# lista zbudowanych obrazów
az acr repository list --name $ACR_NAME --output table

