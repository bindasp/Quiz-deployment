variable "cluster_name" {}
variable "vpc_id" {}
variable "subnet_ids" {
  type = list(string)
}
variable "eks_node_sg_id" {
  description = "Security group of EKS worker nodes"
}
variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}
