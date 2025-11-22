#!/bin/bash
set -e

CLUSTER_NAME="myapp-dev"
AWS_REGION="us-east-1"

echo "🚀 Deploying Voting App to EKS..."

# Configure kubectl
aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME

# Create namespace
kubectl apply -f k8s/base/namespace.yaml

# Add Helm repos
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Deploy databases
echo "Deploying PostgreSQL..."
helm upgrade --install postgresql bitnami/postgresql \
  --namespace voting-app \
  --values k8s/helm/postgres-values.yaml \
  --wait

echo "Deploying Redis..."
helm upgrade --install redis bitnami/redis \
  --namespace voting-app \
  --values k8s/helm/redis-values.yaml \
  --wait

# Create config
kubectl apply -f k8s/config/configmap.yaml
kubectl apply -f k8s/config/secrets.yaml

# Apply network policies
kubectl apply -f k8s/base/network-policies.yaml

# Wait for databases
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=postgresql -n voting-app --timeout=300s
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=redis -n voting-app --timeout=300s

# Deploy application
kubectl apply -f k8s/apps/vote/
kubectl apply -f k8s/apps/result/
kubectl apply -f k8s/apps/worker/
kubectl apply -f k8s/apps/seed-data/

# Wait for deployments
kubectl wait --for=condition=available deployment/vote -n voting-app --timeout=300s
kubectl wait --for=condition=available deployment/result -n voting-app --timeout=300s
kubectl wait --for=condition=available deployment/worker -n voting-app --timeout=300s

# Wait for seed data
kubectl wait --for=condition=complete job/seed-data -n voting-app --timeout=180s

# Deploy HPA (NEW SECTION)
echo "📈 Deploying Auto-scaling..."
kubectl apply -f k8s/apps/vote/hpa.yaml
kubectl apply -f k8s/apps/result/hpa.yaml

# Deploy ingress
kubectl apply -f k8s/ingress/alb-ingress.yaml

echo "✅ Deployment completed!"
echo "📊 HPA is now active for vote and result services"
echo "Run: ./scripts/setup-dns.sh after 2-3 minutes"