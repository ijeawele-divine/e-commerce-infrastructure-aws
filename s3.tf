module "s3" {
  for_each = var.s3_buckets

  source      = "./storage/aws-s3"
  environment = var.environment
  bucket_name = "teleios-divine-${var.environment}-${each.key}"
  versioning  = each.value.versioning
}