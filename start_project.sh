#!/bin/bash
set -e

# --- CONFIG ---
RESOURCE_GROUP="shaunsunny-rg"
AKS_NAME="shaunsunny-aks"
ACR_NAME="shaunsunnyacr"
LOCATION="southindia"
IMAGE_TAG="v1"

echo "🔹 Starting Cloud Portfolio deployment..."

# Step 1: Recreate infrastructure with Terraform
cd terraform
echo "🚀 Running Terraform apply..."
terraform init -upgrade -input=false
terraform apply -auto-approve

# Step 2: Connect kubectl to AKS
echo "🔗 Fetching AKS credentials..."
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME --overwrite-existing

# Step 3: Build, tag, and push Docker image
cd ..
echo "🐳 Building and pushing Docker image to ACR..."
az acr login --name $ACR_NAME
docker build -t cloud-portfolio:latest .
docker tag cloud-portfolio:latest ${ACR_NAME}.azurecr.io/cloud-portfolio:${IMAGE_TAG}
docker push ${ACR_NAME}.azurecr.io/cloud-portfolio:${IMAGE_TAG}

# Step 4: Deploy app with Ansible
echo "⚙️  Deploying Kubernetes manifests via Ansible..."
ansible-playbook deploy_k8s.yml

# Step 5: Wait for LoadBalancer IP
echo "🌐 Waiting for LoadBalancer external IP..."
sleep 10
EXTERNAL_IP=""

for i in {1..20}; do
    EXTERNAL_IP=$(kubectl get svc cloud-portfolio-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)
    if [[ -n "$EXTERNAL_IP" ]]; then
        echo "✅ External IP acquired: $EXTERNAL_IP"
        break
    else
        echo "⏳ Waiting for LoadBalancer IP... ($i/20)"
        sleep 15
    fi
done

if [[ -z "$EXTERNAL_IP" ]]; then
    echo "❌ LoadBalancer IP not ready yet. Try running 'kubectl get svc' manually."
else
    echo "🌍 Opening app in browser..."
    xdg-open "http://${EXTERNAL_IP}" >/dev/null 2>&1 || echo "Open http://${EXTERNAL_IP} in your browser."
fi

echo "🎉 Deployment complete!"
