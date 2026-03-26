output "cluster_name" {
  value = aws_eks_cluster.teleios-divine-eks.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.teleios-divine-eks.endpoint
}

output "cluster_ca_certificate" {
  value     = aws_eks_cluster.teleios-divine-eks.certificate_authority[0].data
  sensitive = true
}

output "cluster_version" {
  value = aws_eks_cluster.teleios-divine-eks.version
}

output "cluster_iam_role_arn" {
  value = aws_iam_role.teleios-divine-eks-role.arn
}

output "cluster_security_group_id" {
  value = aws_eks_cluster.teleios-divine-eks.vpc_config[0].cluster_security_group_id
}

output "eks_node_security_group_id" {
  value = aws_eks_cluster.teleios-divine-eks.vpc_config[0].cluster_security_group_id
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.teleios-divine-eks.arn
}

output "oidc_provider_url" {
  value = aws_iam_openid_connect_provider.teleios-divine-eks.url
}

output "node_group_status" {
  value = aws_eks_node_group.teleios-divine-node-group.status
}