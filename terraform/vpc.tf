module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"  # Use VPC module compatible with AWS provider 5.x

  name = "eks-${var.env}"
  cidr = var.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = true
  single_nat_gateway = var.env == "dev" ? true : false

  tags = {
    Environment = var.env
    Terraform   = "true"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}