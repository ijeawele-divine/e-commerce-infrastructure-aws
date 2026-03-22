module "eks" {
  source         = "./compute/aws-eks"
  environment    = var.environment
  instance_types = var.eks_instance_types
  subnet_ids = module.networking.public_subnet_ids
  alb_sg_id  = module.networking.alb_sg_id
}