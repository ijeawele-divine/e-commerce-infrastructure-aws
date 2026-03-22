module "redis" {
  source = "./data/aws-redis"

  environment        = var.environment
  availability_zones = var.availability_zones
  node_type          = var.redis_node_type

  # from networking
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids

  # from eks
  eks_node_security_group_id = module.eks.eks_node_security_group_id
}