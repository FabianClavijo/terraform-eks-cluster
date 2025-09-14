output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_id" {
  value = aws_subnet.aks.id
}

output "subnet_id_2" {
  value = aws_subnet.aks2.id
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
  value = [aws_subnet.aks.id, aws_subnet.aks2.id]
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "public_route_table_id" {
  value = aws_route_table.public.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.this.id
}

output "nat_gateway_id" {
  value = aws_nat_gateway.this.id
}

output "private_route_table_id" {
  value = aws_route_table.private.id
}

