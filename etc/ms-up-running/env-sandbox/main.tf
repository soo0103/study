terraform {
  backend "s3" {
    bucket = "{YOUR_S3_BUCKET_NAME}"
    key    = "terraform/backend"
    region = "{YOUR_AWS_REGION}"
  }
}

locals {
  env_name         = "sandbox"
  aws_region       = "{YOUR_AWS_REGION}"
  k8s_cluster_name = "ms-cluster"
}

# 네트워크 구성
module "aws-network" {
  source = "{YOUR_NETWORK_MODULE_REPO_PATH}"

  env_name = local.env_name
  vpc_name = "msur-VPC"
  cluster_name = local.k8s_cluster_name
  aws_region = local.aws_region
  main_vpc_cidr = "10.10.0.0/16"
  public_subnet_a_cidr = "10.10.0.0/18"
  public_subnet_b_cidr = "10.10.64.0/18"
  private_subnet_a_cidr = "10.10.128.0/18"
  private_subnet_b_cidr = "10.10.192.0/18"
}

# EKS 구성
module "aws-eks" {
  source = "{YOUR_EKS_MODULE_PATH}"

  ms_namespace = "microservices"
  env_name = local.env_name
  aws_region = local.aws_region
  cluster_name = local.k8s_cluster_name
  vpc_id = module.aws-network.vpc_id
  cluster_subnet_ids = module.aws-network.subnet_ids

  nodegroup_subnet_ids = module.aws-network.private_subnet_ids
  nodegroup_disk_size = "20"
  nodegroup_instance_types = ["t3.medium"]
  nodegroup_desired_size = 1
  nodegroup_min_size = 1
  nodegroup_max_size = 3
}

# 깃옵스 구성
module "argo-cd-server" {
  source = "{YOUR_EKS_MODULE_PATH}"

  kubernetes_cluster_id = module.aws-eks.eks_cluster_id
  kubernetes_cluster_name = module.aws-eks.eks_cluster_name
  kubernetes_cluster_cert_data = module.aws-eks.eks_cluster_certificate_data
  kubernetes_cluster_endpoint = module.aws-eks.eks_cluster_endpoint
  eks_nodegroup_id = module.aws-eks.eks_cluster_nodegroup_id
}