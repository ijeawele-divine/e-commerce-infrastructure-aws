environment = "dev"

availability_zones = ["eu-north-1a", "eu-north-1b"]

public_subnets = {
  "subnet-1" = { cidr_block = "10.0.1.0/24", availability_zone = "eu-north-1a" }
  "subnet-2" = { cidr_block = "10.0.2.0/24", availability_zone = "eu-north-1b" }
}

private_subnets = {
  "subnet-1" = { cidr_block = "10.0.3.0/24", availability_zone = "eu-north-1a" }
  "subnet-2" = { cidr_block = "10.0.4.0/24", availability_zone = "eu-north-1b" }
}

eks_instance_types        = ["t3.medium"]
ec2_key_name              = "teleios-divine-dev-key"
db_cluster_instance_class = "db.t3.medium"
database_name             = "teleios_dev"
redis_node_type           = "cache.t3.micro"

ec2_instances = {
  "web" = { instance_type = "t3.micro" }
}

s3_buckets = {
  "assets" = { versioning = true }
  "logs"   = { versioning = false }
}