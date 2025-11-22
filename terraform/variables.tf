variable "env" {
  type        = string
  description = "Environment name (dev|prod)"
  default     = "dev"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
}

variable "k8s_version" {
  type    = string
  default = "1.27"
}

variable "node_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "node_desired_capacity" {
  type    = number
  default = 2
}
