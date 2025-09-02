terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

  }

  backend "s3" {
    bucket         = "quiz-app-eks-state-bucket"
    key            = "terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "quiz-app-eks-state-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.region
}

provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
    token                  = module.eks.cluster_auth_token
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
  token                  = module.eks.cluster_auth_token
}

module "secrets" {
  source = "./modules/secrets"
}

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
  cluster_name         = var.cluster_name
}

module "eks" {
  source = "./modules/eks"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnet_ids
  node_groups     = var.node_groups
  region          = var.region

  depends_on = [module.vpc]
}

module "rds" {
  source         = "./modules/rds"
  cluster_name   = var.cluster_name
  vpc_id         = module.vpc.vpc_id
  subnet_ids     = module.vpc.private_subnet_ids
  eks_node_sg_id = module.eks.eks_node_sg_id
  db_username    = var.db_username
  db_password    = module.secrets.rds_password

  depends_on = [module.vpc]
}

module "alb-controller" {
  source                              = "./modules/alb-controller"
  region                              = var.region
  vpc_id                              = module.vpc.vpc_id
  aws_iam_openid_connect_provider_arn = module.eks.aws_iam_openid_connect_provider_arn
  aws_iam_openid_connect_provider_url = module.eks.aws_iam_openid_connect_provider_url
  helm_release_name                   = "aws-load-balancer-controller"
  service_account_name                = "aws-load-balancer-controller"
  cluster_name                        = var.cluster_name

  depends_on = [module.eks]
}

module "external-secrets-manager" {
  source                              = "./modules/external-secrets-manager"
  aws_iam_openid_connect_provider_arn = module.eks.aws_iam_openid_connect_provider_arn
  aws_iam_openid_connect_provider_url = module.eks.aws_iam_openid_connect_provider_url
  helm_release_name                   = "external-secrets"
  service_account_name                = "external-secrets"
  external_secrets_version            = "v0.19.2"
  depends_on                          = [module.eks, module.alb-controller]
}

module "cluster-autoscaler" {
  source                              = "./modules/cluster-autoscaler"
  aws_iam_openid_connect_provider_arn = module.eks.aws_iam_openid_connect_provider_arn
  aws_iam_openid_connect_provider_url = module.eks.aws_iam_openid_connect_provider_url
  helm_release_name                   = "cluster-autoscaler"
  region                              = var.region
  cluster_name                        = var.cluster_name
  service_account_name                = "cluster-autoscaler"

  depends_on = [module.eks]
}

module "argocd" {
  source            = "./modules/argocd"
  argocd_version    = "8.3.1"
  namespace         = "argocd"
  helm_release_name = "argocd"
  argocd_password   = module.secrets.argocd_password

  depends_on = [module.secrets, module.eks, module.alb-controller]
}
