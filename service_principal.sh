#!/bin/bash

# Define variables
SERVICE_PRINCIPAL_NAME="capstone-service-principal"  # Change this to your desired service principal name
ROLE="Contributor"
SCOPE="/subscriptions/$(az account show --query id -o tsv)"  # Get the current subscription ID

# Create the service principal and assign the role
echo "Creating service principal with name: $SERVICE_PRINCIPAL_NAME"
SP_OUTPUT=$(az ad sp create-for-rbac --name "$SERVICE_PRINCIPAL_NAME" --role "$ROLE" --scopes "$SCOPE" --query "{appId: appId, password: password, tenant: tenant}" -o json)

# Extract the details from the output
APP_ID=$(echo $SP_OUTPUT | jq -r '.appId')
PASSWORD=$(echo $SP_OUTPUT | jq -r '.password')
TENANT=$(echo $SP_OUTPUT | jq -r '.tenant')

# Display the service principal details
echo "Service Principal created successfully!"
echo "App ID (Client ID): $APP_ID"
echo "Password (Client Secret): $PASSWORD"
echo "Tenant ID: $TENANT"

# Optional: Save the details to a file
echo "Saving service principal details to secrets.yaml"
echo "azure:
  client_id: \"$APP_ID\"
  client_secret: \"$PASSWORD\"
  tenant_id: \"$TENANT\"
" >> secrets.yaml

echo "Service principal details saved to secrets.yaml"
