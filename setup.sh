#!/bin/bash
# ====== Cloud Portfolio Setup Script ======
# Author: Shaun
# Purpose: Automate Azure login, Terraform infra setup, Docker push, and AKS deployment.

set -e

# -------------------
# 1. Azure login
# -------------------
echo "🔹 Logging into Azure..."
az login --use-device-code

# Set your subscription (replace with your ID)
az account set --subscription 4dc08e1c-0e40-476c-8c86-a890893ab900

# -------------------
# 2. Terraform setup
# -------------------
echo "🔹 Initializing Terraform..."
cd ~/projects/cloud-portfolio/terraform
terraform init

echo "🔹 Applying Terraform configuration..."
terraform apply -auto-approve

# -------------------
# 3. Connect to AKS
# -------------------
echo "🔹 Connecting to AKS..."
az aks get-credentials --resource-group shaunsunny-rg --name shaunsunny-aks --overwrite-existing

# -------------------
# 4. Docker build & push
# -------------------
echo "🔹 Logging into Azure Container Registry..."
az acr login --name shaunsunnyacr

echo "🔹 Building Docker image..."
cd ~/projects/cloud-portfolio
docker build -t cloud-portfolio:latest .

echo "🔹 Tagging and pushing to ACR..."
docker tag cloud-portfolio:latest shaunsunnyacr.azurecr.io/cloud-portfolio:v1
docker push shaunsunnyacr.azurecr.io/cloud-portfolio:v1

# -------------------
# 5. Deploy to Kubernetes
# -------------------
echo "🔹 Deploying to AKS..."
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

# -------------------
# 6. Verify deployment
# -------------------
echo "🔹 Checking pod and service status..."
kubectl get pods
kubectl get svc

echo "✅ Deployment complete!"
echo "🌍 Wait a minute and check your app using the EXTERNAL-IP shown above."
