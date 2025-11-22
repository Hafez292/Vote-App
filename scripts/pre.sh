#!/bin/bash

echo "🔍 Checking Prerequisites..."

# Check tools
echo "AWS CLI: $(aws --version 2>/dev/null | head -n1 || echo '❌ NOT INSTALLED')"
echo "kubectl: $(kubectl version --client 2>/dev/null | head -n1 | cut -d' ' -f3- || echo '❌ NOT INSTALLED')"
echo "Helm: $(helm version --short 2>/dev/null || echo '❌ NOT INSTALLED')"
echo "eksctl: $(eksctl version 2>/dev/null || echo '❌ NOT INSTALLED')"

# Check AWS access
if aws sts get-caller-identity &> /dev/null; then
    echo "✅ AWS Authentication: CONFIGURED"
else
    echo "❌ AWS Authentication: NOT CONFIGURED - Run: aws configure"
fi

# Check EKS cluster
CLUSTER_NAME="myapp-dev"
AWS_REGION="us-east-1"

if aws eks describe-cluster --name $CLUSTER_NAME --region $AWS_REGION &> /dev/null; then
    echo "✅ EKS Cluster: FOUND ($CLUSTER_NAME in $AWS_REGION)"
else
    echo "❌ EKS Cluster: NOT FOUND - Run Terraform first"
fi

echo ""
echo "📋 Run: ./scripts/deploy-alb-controller.sh to start deployment"