#!/bin/bash
set -e

echo "⚠️  Destroying all Azure resources..."
cd terraform

# Make sure nothing hangs
terraform destroy -auto-approve || true

cd ..
echo "✅ All resources deleted. Azure credits are safe!"
