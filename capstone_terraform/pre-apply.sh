#!/bin/bash

RESOURCE_GROUP_NAME=backend-rg
STORAGE_ACCOUNT_NAME=tfbackend101
CONTAINER_NAME=tfstate
REGION=southafricanorth

# Create resource group
sudo az group create --name $RESOURCE_GROUP_NAME --location $REGION

# Create storage account
sudo az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

# Create blob container
sudo az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME