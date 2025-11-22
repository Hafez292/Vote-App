#!/bin/bash
set -e

CLUSTER_NAME="myapp-dev"
AWS_REGION="us-east-1"

echo "🚀 Deploying AWS Load Balancer Controller..."

# Create IAM service account
eksctl create iamserviceaccount \
  --cluster=$CLUSTER_NAME \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=arn:aws:iam::aws:policy/AWSLoadBalancerControllerIAMPolicy \
  --override-existing-serviceaccounts \
  --approve \
  --region $AWS_REGION

# Add Helm repo
helm repo add eks https://aws.github.io/eks-charts
helm repo update

# Install ALB Controller
helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=$CLUSTER_NAME \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --wait

echo "✅ AWS Load Balancer Controller deployed"