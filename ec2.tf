module "ec2" {
  for_each = var.ec2_instances   # loops over the map from variables.tf

  source        = "./compute/aws-ec2"
  environment   = var.environment
  instance_type = each.value.instance_type  # e.g. "t3.micro"
  key_name      = var.ec2_key_name
  instance_name = "teleios-divine-${var.environment}-${each.key}"  # e.g. teleios-divine-dev-web
  subnet_ids = module.networking.public_subnet_ids
}