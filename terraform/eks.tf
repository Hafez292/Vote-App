module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"  # This version works with AWS provider 5.x

  cluster_name    = "myapp-${var.env}"
  cluster_version = var.k8s_version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  # Control plane logging for prod
  cluster_enabled_log_types = var.env == "prod" ? ["api", "audit", "authenticator", "controllerManager", "scheduler"] : []

  # EKS Managed Node Group
  eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = var.node_desired_capacity + 1
      desired_size = var.node_desired_capacity
      
      instance_types = [var.node_instance_type]
      
      labels = {
        environment = var.env
        nodepool    = "general"
      }
    }
  }

  tags = {
    Environment = var.env
    Terraform   = "true"
  }
}

data "aws_eks_cluster" "cluster" { 
  name = module.eks.cluster_id 
}

data "aws_eks_cluster_auth" "cluster" { 
  name = module.eks.cluster_id 
}