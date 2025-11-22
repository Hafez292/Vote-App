resource "helm_release" "nginx_ingress" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "5.6.0" # pick a compatible chart version with your k8s
  namespace  = "ingress-nginx"
  create_namespace = true

  values = [yamlencode({
    controller = {
      service = {
        type = "LoadBalancer"
      }
      admissionWebhooks = { enabled = true }
    }
  })]

  depends_on = [module.eks]
}

# Optional: install Kubernetes External Secrets for production-ready secrets fetching (AWS Secrets Manager/SSM)
resource "helm_release" "external_secrets" {
  name       = "kubernetes-external-secrets"
  repository = "https://external-secrets.github.io/kubernetes-external-secrets/"
  chart      = "kubernetes-external-secrets"
  version    = "0.9.0"
  namespace  = "kube-system"
  create_namespace = false

  values = [yamlencode({
    # Configure IRSA and service account via extra objects if you use IRSA. See README for IRSA steps.
  })]

  depends_on = [module.eks]
}
