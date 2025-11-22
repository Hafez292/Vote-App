## 📋 Project Overview

**Mission**: Build a Secure, Observable, Scalable Cloud Setup using a multi-service voting application.

### Architecture
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│ Vote App │ │ Result App │ │ Worker │
│ (Python) │ │ (Node.js) │ │ (.NET) │
│ Port: 8080 │ │ Port: 8081 │ │ │
└─────────────────┘ └─────────────────┘ └─────────────────┘
│ │ │
└───────────────────────┼───────────────────────┘
│
┌────────────┴────────────┐
│ Ingress │
│ (ALB Controller) │
└────────────┬────────────┘
│
┌───────────────────────┼───────────────────────┐
│ │ │
┌────────┴────────┐ ┌───────┴───────┐ ┌────────┴────────┐
│ Redis │ │ PostgreSQL │ │ Seed Data │
│ (Cache) │ │ (Database) │ │ (Job) │
└─────────────────┘ └───────────────┘ └─────────────────┘

text

## 🏗️ Project Structure
.
├── k8s/ # Kubernetes manifests
│ ├── apps/ # Application deployments
│ │ ├── vote/ # Voting frontend
│ │ ├── result/ # Results display
│ │ ├── worker/ # Background worker
│ │ └── seed-data/ # Database seeding job
│ ├── base/ # Base configurations
│ │ ├── namespace.yaml
│ │ ├── network-policies.yaml
│ │ └── psa.yaml # Pod Security Admission
│ ├── config/ # Configurations & Secrets
│ ├── helm/ # Helm values for dependencies
│ └── ingress/ # Ingress configuration
├── local-Setup/ # Local development
│ ├── docker-compose.yml # Local orchestration
│ ├── vote/ # Vote app source
│ ├── result/ # Result app source
│ ├── worker/ # Worker app source
│ ├── seed-data/ # Data seeding
│ └── healthchecks/ # Service health checks
├── scripts/ # Deployment & setup scripts
├── terraform/ # Infrastructure as Code
└── README.md

text

## 🚀 Quick Start

### Prerequisites

- Docker and Docker Compose
- Kubernetes cluster (EKS)
- Terraform
- Helm

### Local Development

1. **Clone and setup the project:**

```bash
git clone <repository-url>
cd devops-project
Run locally with Docker Compose:

bash
cd local-Setup
docker-compose up -d
Access the application:

Voting Interface: http://localhost:8080

Results Dashboard: http://localhost:8081

Verify services are running:

bash
docker-compose ps 
```
2.**☁️ Kubernetes Deployment**
Infrastructure Setup
Initialize and deploy infrastructure:

```bash
terraform init
terraform workspace new dev
terraform workspace new prod
terraform workspace select dev

terraform plan -var="env=dev"
terraform apply -target=module.vpc -target=module.eks

aws eks update-kubeconfig --region us-east-1 --name myapp-dev
#OR 
aws eks update-kubeconfig \
  --name $(terraform output -raw cluster_name) \
  --region $(terraform output -raw region)
# 2. Deploy only Helm charts

terraform apply -target=helm_release.nginx_ingress

```

Deploy base components:
```bash
kubectl apply -f k8s/base/
#Deploy configurations:
kubectl apply -f k8s/config/
#Install dependencies:
./scripts/deploy-alb-controller.sh
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install redis bitnami/redis -f k8s/helm/redis-values.yaml
helm install postgresql bitnami/postgresql -f k8s/helm/postgres-values.yaml
#Deploy applications:
kubectl apply -f k8s/apps/
#Verify deployment:
kubectl get all -n voting-app
```
🔧 Configuration
Environment Variables
```bash
Create a k8s/config/secrets.yaml file with your production secrets:
```
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
  namespace: voting-app
type: Opaque
data:
  postgres-password: <base64-encoded-password>
  redis-password: <base64-encoded-password>
Customizing Deployment
Edit the values files in k8s/helm/ to customize Redis and PostgreSQL configurations.
```
# Verify network policies
./scripts/verify-network-policies.sh


🔄 CI/CD Pipeline
The project includes automated CI/CD with:

Automated image builds and security scanning

Kubernetes deployment

Smoke tests

Infrastructure as Code validation

Manual Deployment Script
bash
./scripts/deploy-to-eks.sh
🚨 Troubleshooting
Common Issues
Pods stuck in pending state:

Check resource quotas and node capacity

Database connection errors:

Verify network policies and secrets

Check PostgreSQL readiness

Ingress not working:

Verify ALB controller installation

Check ingress resource status

Debug Commands
bash
# Get detailed pod information
kubectl describe pod <pod-name> -n voting-app

# Check service endpoints
kubectl get endpoints -n voting-app

# View ingress status
kubectl get ingress -n voting-app

# Check events
kubectl get events -n voting-app --sort-by=.metadata.creationTimestamp
📈 Scaling
Horizontal Pod Autoscaling
The application supports HPA. To enable:

bash
kubectl apply -f k8s/hpa/
Manual Scaling
bash
kubectl scale deployment/vote --replicas=3 -n voting-app
kubectl scale deployment/result --replicas=2 -n voting-app
🗂️ Service Details
Service	Port	Technology	Purpose
vote	8080	Python/Flask	Voting interface
result	8081	Node.js	Results display
worker	-	.NET Core	Background processing
Redis	6379	Redis	Caching & messaging
PostgreSQL	5432	PostgreSQL	Data persistence
🤝 Contributing
Fork the repository

Create a feature branch (git checkout -b feature/CodeQuest-feature)

Test changes locally with Docker Compose

Commit your changes (git commit -m 'Add CodeQuest-feature')

Push to the branch (git push origin feature/CodeQuest-feature)

Open a Pull Request


