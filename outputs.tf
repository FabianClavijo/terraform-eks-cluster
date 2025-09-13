output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_id" {
  value = aws_subnet.aks.id
}

output "security_group_id" {
  value = aws_security_group.eks.id
}

output "cluster_name" {
  value = aws_eks_cluster.eks.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "node_group_name" {
  value = aws_eks_node_group.node_group.node_group_name
}
output "cluster_role_arn" {
  value = aws_iam_role.eks_cluster.arn
}

output "subnet_ids" {
  value = var.subnet_ids
}
