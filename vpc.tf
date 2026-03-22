module "networking" {
  source          = "./networking/aws-vpc"
  environment     = var.environment
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}