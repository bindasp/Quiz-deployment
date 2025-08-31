locals {
  namespace = "kube-system"
}

resource "aws_iam_policy" "alb_controller" {
  name   = "AWSLoadBalancerControllerIAMPolicy"
  policy = file("${path.module}/iam_policy.json") # <-- tu podaj swój plik JSON
}

resource "aws_iam_role" "alb_controller" {
  name = "AmazonEKSLoadBalancerControllerRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = var.aws_iam_openid_connect_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(var.aws_iam_openid_connect_provider_url, "https://", "")}:sub" = "system:serviceaccount:${local.namespace}:${var.service_account_name}"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "alb_controller_attach" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = aws_iam_policy.alb_controller.arn
}


resource "kubernetes_service_account" "alb_controller" {
  metadata {
    name      = var.service_account_name
    namespace = local.namespace

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller.arn
    }
  }
}

resource "helm_release" "alb_controller" {
  name       = var.helm_release_name
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = local.namespace

  set = [{
    name  = "clusterName"
    value = var.cluster_name
    },

    {
      name  = "region"
      value = var.region
    },

    {
      name  = "vpcId"
      value = var.vpc_id
    },

    {
      name  = "serviceAccount.create"
      value = "false"
    },

    {
      name  = "serviceAccount.name"
      value = var.service_account_name
    }

  ]
}
