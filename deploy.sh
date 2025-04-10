#!/bin/bash

########################################################################
# This script will deploy a vm to azure and configure it using ansible #
#                                                                      #
# Prerequisites:                                                       #
# 1. Azure CLI installed (and logged in!)                              #
# 2. Terraform installed                                               # 
# 3. Ansible installed                                                 #
########################################################################

echo "Starting deployment..."

PROJECT_ROOT=$(pwd)

cd $PROJECT_ROOT/terraform

terraform init
terraform apply -auto-approve

terraform output -json > $PROJECT_ROOT/terraform_outputs.json

echo "Terraform outputs saved to terraform_outputs.json."

echo "Terraform deployment completed."

PUBLIC_DNS=$(grep -o '"value": "[^"]*' $PROJECT_ROOT/terraform_outputs.json | grep ".com" | grep -o '[^"]*$')

cd $PROJECT_ROOT/ansible

echo "Starting Ansible deployment..."

ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u adminuser --private-key ~/.ssh/id_rsa -i "$PUBLIC_DNS," 00_complete_install.yml