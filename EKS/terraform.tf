terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~>3.0.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~>2.0"
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
