output "vpc_id" {
  value = module.networking.vpc_id
}

output "public_subnet_ids" {
  value = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.networking.private_subnet_ids
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_cluster_version" {
  value = module.eks.cluster_version
}

output "eks_node_security_group_id" {
  value = module.eks.eks_node_security_group_id
}

output "ec2_instance_ids" {
  value = { for k, v in module.ec2 : k => v.instance_id }
}

output "ec2_public_ips" {
  value = { for k, v in module.ec2 : k => v.public_ip }
}

output "rds_endpoint" {
  value = module.rds.rds_endpoint
}

output "rds_port" {
  value = module.rds.rds_port
}

output "redis_primary_endpoint" {
  value = module.redis.redis_primary_endpoint
}

output "redis_port" {
  value = module.redis.redis_port
}

output "node_group_status" {
  value = aws_eks_node_group.teleios-divine-node-group.status
}