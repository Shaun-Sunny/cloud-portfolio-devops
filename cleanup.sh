#!/bin/bash
# ====== Cloud Portfolio Cleanup Script ======
# Author: Shaun
# Purpose: Delete Azure resources created by Terraform.

set -e

echo "⚠️  WARNING: This will delete your Azure resources!"
read -p "Press ENTER to continue or Ctrl+C to cancel..."

# Set subscription (replace with yours)
az account set --subscription 4dc08e1c-0e40-476c-8c86-a890893ab900

# Run Terraform destroy
cd ~/projects/cloud-portfolio/terraform
terraform destroy -auto-approve

# Double-check and remove any leftover groups
az group delete --name shaunsunny-rg --yes --no-wait || true
az group delete --name MC_shaunsunny-rg_shaunsunny-aks_southindia --yes --no-wait || true

echo "✅ All resources deleted! Your credits are safe 💰"
