#!/bin/bash

# Check if the curl command exists and install it if it doesn't
if ! sudo command -v curl &> /dev/null; then
  echo "Error: curl command not found. Installing curl..."
  sudo apt-get update
  sudo apt-get install -y curl
fi

# Get the ip address of the current machine
IP_ADDRESS=$(curl -s ifconfig.me)/32

# Terraform variables file
TFVARS_FILE="terraform.tfvars"

# Check if the curl command was successful
if [ $? -eq 0 ]; then
  # Read existing content
  EXISTING_CONTENT=$(grep "allowed_source_addresses" "$TFVARS_FILE" 2>/dev/null)
  
  if [ -n "$EXISTING_CONTENT" ]; then
    # If the line exists, append the new IP inside the square brackets
    sudo sed -i "s|\(allowed_source_addresses = \[.*\)\]|\1, \"$IP_ADDRESS\"]|" "$TFVARS_FILE"
  else
    # If the line doesn't exist, append it
    echo "allowed_source_addresses = [\"$IP_ADDRESS\"]" >> "$TFVARS_FILE"
  fi

  # Check if writing to the file was successful
  if [ $? -eq 0 ]; then
    echo "Successfully updated allowed_source_addresses in $TFVARS_FILE"
  else
    echo "Error: Failed to write to $TFVARS_FILE"
  fi
else
  echo "Error: Failed to retrieve current ip address"
fi
