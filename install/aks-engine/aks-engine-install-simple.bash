#!/bin/bash

az account list  --query '[].{subscriptionId: id,isDefault: isDefault}'  -o tsv  |grep Tru

SUBSCRIPTION_ID=aaa-aaa-aaa-aaa
RESOURCE_GROUP_NAME=rg-aks-simple
az account set --subscription="${SUBSCRIPTION_ID}"

# Create a service principal and read in the application ID
SP=$(az ad sp create-for-rbac  --role="Contributor" --name aks-engine-sp --scopes="/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP_NAME}" --output json)
CLIENT_ID=$(echo $SP | jq -r .appId)
CLIENT_SECRET=$(echo $SP | jq -r .password)

echo "SUBSCRIPTION_ID :$SUBSCRIPTION_ID"
echo "RESOURCE_GROUP_NAME: $RESOURCE_GROUP_NAME"
echo "SP: $SP"
echo "CLIENT_ID: $CLIENT_ID"
echo "CLIENT_SECRET: $CLIENT_SECRET"


aks-engine deploy --subscription-id $SUBSCRIPTION_ID  \
    -g $RESOURCE_GROUP_NAME \
    --client-id $CLIENT_ID \
    --client-secret $CLIENT_SECRET \
    --dns-prefix simple-aks-engine --location northeurope \
    --api-model examples/kubernetes.json

	