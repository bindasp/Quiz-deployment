output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.main.name
}

output "cluster_sg" {
  description = "EKS cluster_sg id"
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "eks_node_sg_id" {
  description = "Security Group ID for EKS worker nodes"
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "cluster_auth_token" {
  value = data.aws_eks_cluster_auth.cluster_auth.token
}

output "cluster_ca_certificate" {
  value = aws_eks_cluster.main.certificate_authority[0].data
}

output "aws_iam_openid_connect_provider_url" {
  value = aws_iam_openid_connect_provider.eks.url
}

output "aws_iam_openid_connect_provider_arn" {
  value = aws_iam_openid_connect_provider.eks.arn
}
