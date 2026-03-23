module "s3" {
  for_each = var.s3_buckets

  source      = "./storage/aws-s3"
  environment = var.environment
  bucket_name = var.bucket_name
  versioning  = each.value.versioning
}