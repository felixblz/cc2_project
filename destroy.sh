#!/bin/bash

########################################################################
# This script will destroy the terraform deployment                    #
#                                                                      #
# Prerequisites:                                                       #
# 1. Azure CLI installed (and logged in!)                              #
# 2. Terraform installed                                               # 
# 3. Ansible installed                                                 #
########################################################################

echo "Starting destroying..."

PROJECT_ROOT=$(pwd)

cd $PROJECT_ROOT/terraform

terraform destroy -auto-approve

echo "Terraform environment destroyed!"
