# 🗳️ Vote-App: Secure, Observable, Scalable Cloud Setup

**Mission**: Build a Secure, Observable, Scalable Cloud Setup using a multi-service voting application.

## 📋 Project Overview

This project demonstrates a production-ready, multi-phase DevOps implementation of a voting application. The application consists of four microservices (vote, result, worker, seed-data) deployed using modern containerization and orchestration practices.

## 🏗️ Project Structure

```
.
├── k8s/                    # Kubernetes manifests
│   ├── apps/              # Application deployments
│   │   ├── vote/          # Voting frontend
│   │   ├── result/        # Results display
│   │   ├── worker/        # Background worker
│   │   └── seed-data/     # Database seeding job
│   ├── base/              # Base configurations
│   │   ├── namespace.yaml
│   │   ├── network-policies.yaml
│   │   └── psa.yaml       # Pod Security Admission
│   ├── config/            # Configurations & Secrets
│   ├── helm/              # Helm values for dependencies
│   └── ingress/           # Ingress configuration
├── local-Setup/           # Local development
│   ├── docker-compose.yml # Local orchestration
│   ├── vote/              # Vote app source & Dockerfile
│   ├── result/            # Result app source & Dockerfile
│   ├── worker/            # Worker app source & Dockerfile
│   ├── seed-data/         # Data seeding service
│   └── healthchecks/      # Service health checks
├── scripts/               # Deployment & setup scripts
│   ├── pre.sh             # Prerequisites checker
│   ├── deploy-alb-controller.sh
│   ├── deploy-to-eks.sh
│   ├── setup-dns.sh
│   └── verify-network-policies.sh
├── terraform/             # Infrastructure as Code
│   ├── vpc.tf             # VPC configuration
│   ├── eks.tf             # EKS cluster
│   ├── helm_installs.tf   # Helm chart installations
│   └── variables.tf       # Environment variables
├── .github/workflows/     # CI/CD pipelines
│   ├── ci.yaml            # Continuous Integration
│   ├── cd.yml             # Continuous Deployment
│   └── infrastructure.yml # Infrastructure automation
└── README.md
```

---

# 🚀 How This Project Works

This project is organized into three distinct phases, each building upon the previous one to create a complete, production-ready deployment pipeline.

---

## 📦 Phase 1 – Containerization & Local Setup

**Goal**: Running locally with all services healthy and communicating.

### ✅ Containerization

Each service is containerized with **efficient, non-root Dockerfiles** for security best practices:

- **vote** (Python/Flask): Non-root user, minimal base image
- **result** (Node.js): Non-root user, optimized layers
- **worker** (.NET Core): Non-root user, minimal runtime
- **seed-data**: Lightweight seeding service

**Example Dockerfile Structure**:
```dockerfile
FROM python:3.12-slim
RUN useradd -m vote
USER vote
WORKDIR /vote
COPY . /vote/
EXPOSE 8080
RUN pip install --no-cache-dir -r requirements.txt
CMD ["python", "app.py"]
```

### 🐳 Docker Compose Orchestration

The `docker-compose.yml` orchestrates all services with:

#### **Two-Tier Networking Architecture**:
- **Frontend Network**: `vote` + `result` services (user-facing)
- **Backend Network**: `worker` + `redis` + `postgres` (internal services)

#### **Health Checks**:
- **Redis**: `redis-cli ping` with 5s intervals
- **PostgreSQL**: `pg_isready` with 5s intervals
- Services wait for dependencies to be healthy before starting

#### **Exposed Ports**:
- **Port 8080**: Vote service (mapped from container port 80)
- **Port 8081**: Result service (mapped from container port 4000)

#### **Service Dependencies**:
- `vote` depends on `redis` being healthy
- `result` depends on `db` (PostgreSQL) being healthy
- `worker` depends on both `redis` and `db` being healthy

### 🚀 Running Locally

```bash
# Clone the repository
git clone <repository-url>
cd Vote-App

# Start all services
cd local-Setup
docker compose up -d

# Verify services are running
docker compose ps

# Check service health
docker compose logs -f
```

**Access the application**:
- **Voting Interface**: http://localhost:8080
- **Results Dashboard**: http://localhost:8081

### 🌱 Seed Data Service

The seed-data service is available as an **optional profile** to populate test data:

```bash
# Run with seed profile to populate test data
docker compose --profile seed up seed-data

# Or run seed-data separately after services are up
docker compose up seed-data
```

### ✅ Phase 1 Verification

```bash
# Check all containers are running
docker compose ps

# Verify health checks
docker compose ps --format "table {{.Name}}\t{{.Status}}"

# Test endpoints
curl http://localhost:8080
curl http://localhost:8081

# View logs
docker compose logs vote
docker compose logs result
docker compose logs worker
```

**✅ Goal Achieved**: All services running locally, healthy, and communicating through the two-tier network architecture.

---

## ☁️ Phase 2 – Infrastructure & Deployment

**Goal**: Production-grade Kubernetes deployment with security, networking, and multi-environment support.

### 🏗️ Infrastructure Provisioning

#### **Terraform for EKS Cluster**

The infrastructure is provisioned using Terraform with support for **multi-environment setup** (dev, prod):

```bash
# Initialize Terraform
terraform init

# Create workspaces for different environments
terraform workspace new dev
terraform workspace new prod

# Select environment
terraform workspace select dev

# Plan infrastructure
terraform plan -var="env=dev"

# Deploy VPC and EKS cluster
terraform apply -target=module.vpc -target=module.eks

# Configure kubectl
aws eks update-kubeconfig \
  --name $(terraform output -raw cluster_name) \
  --region $(terraform output -raw region)
```

#### **Infrastructure Components**:
- **VPC**: Isolated network with public/private subnets
- **EKS Cluster**: Managed Kubernetes cluster
- **Security Groups**: Network access controls
- **Ingress Controller**: AWS Load Balancer Controller (via Helm)

### 🔐 Kubernetes Deployment

#### **1. Base Components**

Deploy foundational Kubernetes resources:

```bash
# Create namespace with Pod Security Admission
kubectl apply -f k8s/base/namespace.yaml

# Apply Pod Security Admission (PSA) policies
kubectl apply -f k8s/base/psa.yaml

# Deploy network policies for service isolation
kubectl apply -f k8s/base/network-policies.yaml
```

**Pod Security Admission (PSA)**:
- Enforces **non-root policies** at the namespace level
- Baseline enforcement with restricted audit/warn
- Ensures all pods run as non-root users

**Network Policies**:
- **Default deny-all** traffic policy
- **Database isolation**: Only worker and result can access PostgreSQL
- **Redis isolation**: Only vote and worker can access Redis
- **Frontend ingress**: Allows external access to vote and result services
- **DNS resolution**: Allows DNS queries for all pods

#### **2. Configuration & Secrets**

Production-grade secret management:

```bash
# Deploy ConfigMaps
kubectl apply -f k8s/config/configmap.yaml

# Deploy Secrets (base64-encoded, production-ready)
kubectl apply -f k8s/config/secrets.yaml
```

**Secrets Management**:
- PostgreSQL passwords
- Redis passwords
- Application secrets
- Base64 encoded for Kubernetes compatibility

#### **3. Dependencies (Helm Charts)**

Deploy managed services using Helm:

```bash
# Add Helm repositories
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Deploy PostgreSQL with custom values
helm install postgresql bitnami/postgresql \
  --namespace voting-app \
  --values k8s/helm/postgres-values.yaml \
  --wait

# Deploy Redis with custom values
helm install redis bitnami/redis \
  --namespace voting-app \
  --values k8s/helm/redis-values.yaml \
  --wait
```

#### **4. Application Deployment**

Deploy microservices with production configurations:

```bash
# Deploy all applications
kubectl apply -f k8s/apps/

# Or deploy individually
kubectl apply -f k8s/apps/vote/
kubectl apply -f k8s/apps/result/
kubectl apply -f k8s/apps/worker/
kubectl apply -f k8s/apps/seed-data/
```

**Production Features in Manifests**:
- **Resource Limits**: CPU and memory requests/limits
- **Health Probes**: Liveness and readiness probes
- **Non-root Users**: Security contexts enforcing non-root
- **ConfigMaps & Secrets**: Environment variable injection
- **Service Accounts**: Dedicated service accounts per service
- **Replica Sets**: High availability configurations

#### **5. Ingress Controller**

Deploy AWS Load Balancer Controller:

```bash
# Deploy ALB Controller
./scripts/deploy-alb-controller.sh

# Deploy Ingress resources
kubectl apply -f k8s/ingress/
```

#### **6. Automated Deployment Script**

Use the provided script for complete deployment:

```bash
# Check prerequisites first
./scripts/pre.sh

# Deploy everything
./scripts/deploy-to-eks.sh
```

### 🔒 Security Features

1. **Pod Security Admission (PSA)**: Enforces non-root policies
2. **Network Policies**: Isolates database and restricts traffic
3. **Secrets Management**: Production-grade secret handling
4. **Resource Limits**: Prevents resource exhaustion
5. **Non-root Containers**: All services run as non-root users
6. **Service Isolation**: Network policies restrict inter-service communication

### ✅ Phase 2 Verification

```bash
# Verify all pods are running
kubectl get all -n voting-app

# Check pod security
kubectl get pods -n voting-app -o jsonpath='{.items[*].spec.securityContext}'

# Verify network policies
./scripts/verify-network-policies.sh

# Check ingress
kubectl get ingress -n voting-app

# View application logs
kubectl logs -f deployment/vote -n voting-app
kubectl logs -f deployment/result -n voting-app
kubectl logs -f deployment/worker -n voting-app
```

**✅ Goal Achieved**: Production-grade Kubernetes deployment with security, networking, and multi-environment support.

---

## 🔄 Phase 3 – Automation, Security & Observability

**Goal**: Fully automated CI/CD pipeline with security scanning and automated deployments.

### 🚀 CI/CD Pipeline (GitHub Actions)

The project includes comprehensive CI/CD automation:

#### **Continuous Integration (CI) Pipeline**

**Location**: `.github/workflows/ci.yaml`

**What it does**:
1. **Builds Docker Images**: For all services (vote, result, worker, seed-data)
2. **Security Scanning**: Uses Trivy to scan for vulnerabilities
3. **Image Tagging**: Tags images with `latest` and version tags
4. **Pushes to Registry**: Pushes to Docker Hub
5. **Triggers CD**: Automatically triggers deployment pipeline

**Features**:
- **Matrix Strategy**: Builds all services in parallel
- **Trivy Security Scan**: Scans for CRITICAL and HIGH severity vulnerabilities
- **Artifact Upload**: Saves security scan reports
- **Multi-tag Support**: Tags images with both `latest` and version numbers

**Workflow Steps**:
```yaml
1. Checkout code
2. Set up Docker Buildx
3. Log in to Docker Hub
4. Build Docker images (matrix: vote, result, worker, seed-data)
5. Run Trivy security scan
6. Upload security reports
7. Push images to Docker Hub
8. Trigger CD workflow
```

#### **Continuous Deployment (CD) Pipeline**

**Location**: `.github/workflows/cd.yml`

**What it does**:
1. **Configures AWS**: Sets up AWS credentials
2. **Updates Kubeconfig**: Connects to EKS cluster
3. **Updates Images**: Updates deployment images with latest builds
4. **Applies Manifests**: Ensures all Kubernetes resources are up-to-date
5. **Waits for Rollout**: Verifies successful deployment

**Features**:
- **Environment Protection**: Uses GitHub environments for production
- **Idempotent Operations**: Safe to run multiple times
- **Rollout Verification**: Waits for deployments to be ready
- **Automatic Updates**: Updates images from CI pipeline

**Workflow Steps**:
```yaml
1. Checkout code
2. Configure AWS credentials
3. Update kubeconfig for EKS
4. Update application images
5. Apply Kubernetes manifests
6. Wait for deployment rollouts
```

### 🔒 Security Scanning

**Trivy Integration**:
- Scans all Docker images for vulnerabilities
- Focuses on CRITICAL and HIGH severity issues
- Generates JSON reports for analysis
- Uploads reports as GitHub Actions artifacts

**Security Best Practices**:
- Images scanned before deployment
- Reports stored for compliance
- Non-blocking scans (exit-code: 0) for visibility
- Can be configured to fail on critical vulnerabilities

### 🏗️ Infrastructure Automation

**Location**: `.github/workflows/infrastructure.yml`

Automates infrastructure provisioning and updates:
- Terraform validation
- Infrastructure planning
- Controlled infrastructure deployments

### 📊 Observability Features

1. **Health Checks**: Liveness and readiness probes
2. **Logging**: Centralized logging via kubectl logs
3. **Monitoring**: Ready for Prometheus/Grafana integration
4. **HPA**: Horizontal Pod Autoscaling configured
5. **Resource Monitoring**: Resource limits and requests

### 🚀 Automated Workflow

**Complete Flow**:
```
1. Developer pushes code to main branch
   ↓
2. CI Pipeline triggers
   ↓
3. Builds Docker images for all services
   ↓
4. Runs Trivy security scans
   ↓
5. Pushes images to Docker Hub
   ↓
6. CD Pipeline triggers automatically
   ↓
7. Updates EKS cluster with new images
   ↓
8. Verifies deployment success
```

### ✅ Phase 3 Verification

```bash
# Check GitHub Actions runs
# View in GitHub Actions tab

# Verify images in Docker Hub
docker pull <username>/vote:latest
docker pull <username>/result:latest

# Check deployment status
kubectl get deployments -n voting-app
kubectl rollout status deployment/vote -n voting-app

# View security scan reports
# Download from GitHub Actions artifacts
```

**✅ Goal Achieved**: Fully automated CI/CD pipeline with security scanning and automated deployments.

---

## 🗂️ Service Details

| Service | Port | Technology | Purpose |
|---------|------|------------|---------|
| **vote** | 8080 | Python/Flask | Voting interface |
| **result** | 8081 | Node.js | Results display |
| **worker** | - | .NET Core | Background processing |
| **Redis** | 6379 | Redis | Caching & messaging |
| **PostgreSQL** | 5432 | PostgreSQL | Data persistence |

---

## 📈 Scaling

### Horizontal Pod Autoscaling (HPA)

The application supports HPA for automatic scaling:

```bash
# Deploy HPA configurations
kubectl apply -f k8s/apps/vote/hpa.yaml
kubectl apply -f k8s/apps/result/hpa.yaml
kubectl apply -f k8s/apps/worker/hpa.yaml

# Check HPA status
kubectl get hpa -n voting-app
```

### Manual Scaling

```bash
# Scale vote service
kubectl scale deployment/vote --replicas=3 -n voting-app

# Scale result service
kubectl scale deployment/result --replicas=2 -n voting-app
```

---

## 🚨 Troubleshooting

### Common Issues

**Pods stuck in pending state**:
- Check resource quotas and node capacity
- Verify node availability: `kubectl get nodes`

**Database connection errors**:
- Verify network policies: `./scripts/verify-network-policies.sh`
- Check secrets: `kubectl get secrets -n voting-app`
- Verify PostgreSQL readiness: `kubectl get pods -l app.kubernetes.io/name=postgresql -n voting-app`

**Ingress not working**:
- Verify ALB controller: `kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller`
- Check ingress status: `kubectl get ingress -n voting-app`
- Verify DNS setup: `./scripts/setup-dns.sh`

### Debug Commands

```bash
# Get detailed pod information
kubectl describe pod <pod-name> -n voting-app

# Check service endpoints
kubectl get endpoints -n voting-app

# View ingress status
kubectl get ingress -n voting-app

# Check events
kubectl get events -n voting-app --sort-by=.metadata.creationTimestamp

# View pod logs
kubectl logs -f deployment/vote -n voting-app

# Check network policies
kubectl get networkpolicies -n voting-app
```

---

## 🔧 Configuration

### Environment Variables

Create a `k8s/config/secrets.yaml` file with your production secrets:

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
```

### Customizing Deployment

- **Redis/PostgreSQL**: Edit values files in `k8s/helm/`
- **Resource Limits**: Modify deployment manifests in `k8s/apps/`
- **Scaling**: Adjust HPA configurations in `k8s/apps/*/hpa.yaml`

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Test changes locally with Docker Compose
4. Commit your changes (`git commit -m 'Add amazing feature'`)
5. Push to the branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

---

## 📚 Additional Resources

- **Scripts Documentation**: See `scripts/README.md` for detailed script documentation
- **Kubernetes Manifests**: All manifests are documented with comments
- **Terraform**: Infrastructure code is modular and well-organized
- **CI/CD**: Workflows are self-documenting with clear step names

----
## 🎯 Summary

This project demonstrates:

✅ **Phase 1**: Containerized microservices with Docker Compose, two-tier networking, health checks, and non-root security  
✅ **Phase 2**: Production-grade Kubernetes deployment with Terraform, PSA, NetworkPolicies, Helm charts, and multi-environment support  
✅ **Phase 3**: Fully automated CI/CD with security scanning (Trivy), automated deployments, and observability  

**Result**: A secure, observable, and scalable cloud-native voting application ready for production use.
