locals {
  namespace = "kube-system"
}

data "aws_iam_policy_document" "eks_cluster_autoscaler_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.aws_iam_openid_connect_provider_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${local.namespace}:${var.service_account_name}"]
    }

    principals {
      identifiers = [var.aws_iam_openid_connect_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "eks_cluster_autoscaler" {
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_autoscaler_assume_role_policy.json
  name               = "eks-cluster-autoscaler"
}

resource "aws_iam_policy" "eks_cluster_autoscaler" {
  name = "eks-cluster-autoscaler"

  policy = jsonencode({
    Statement = [{
      Action = [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeTags",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup",
        "ec2:DescribeLaunchTemplateVersions"
      ]
      Effect   = "Allow"
      Resource = "*"
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_autoscaler_attach" {
  role       = aws_iam_role.eks_cluster_autoscaler.name
  policy_arn = aws_iam_policy.eks_cluster_autoscaler.arn
}



resource "kubernetes_service_account" "cluster_autoscaler" {
  metadata {
    name      = var.service_account_name
    namespace = local.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.eks_cluster_autoscaler.arn
    }
  }
}

resource "helm_release" "cluster_autoscaler" {
  name       = var.helm_release_name
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = local.namespace

  set = [{
    name  = "autoDiscovery.clusterName"
    value = var.cluster_name
    },

    {
      name  = "awsRegion"
      value = var.region
    },

    {
      name  = "rbac.serviceAccount.create"
      value = "false"
    },

    {
      name  = "rbac.serviceAccount.name"
      value = var.service_account_name
    }
  ]
}
