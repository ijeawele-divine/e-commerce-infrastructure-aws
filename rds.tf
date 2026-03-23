# rds.tf depends on BOTH networking (for vpc_id and private_subnet_ids)
# AND eks (for eks_node_security_group_id).
# Terraform resolves this automatically — it will wait for both
# networking and eks to finish before creating RDS.

module "rds" {
  source = "./data/aws-rds"

  environment               = var.environment
  availability_zones        = var.availability_zones
  db_cluster_instance_class = var.db_cluster_instance_class
  database_name             = var.database_name
  skip_final_snapshot       = var.skip_final_snapshot
  # sensitive — injected from Terraform Cloud, not .tfvars
  master_username = var.master_username
  master_password = var.master_password

  # from networking
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids

  # from eks — RDS only allows traffic from EKS nodes
  eks_node_security_group_id = module.eks.eks_node_security_group_id
}