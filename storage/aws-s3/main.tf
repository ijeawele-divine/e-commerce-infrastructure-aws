resource "aws_s3_bucket" "teleios-divine-s3" {
  bucket = "teleios-divine-${var.environment}-bucket"

  tags = {
    Name        = "teleios-divine-${var.environment}-bucket"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "teleios-divine-s3" {
  bucket = aws_s3_bucket.teleios-divine-s3.id
  versioning_configuration {
    status = "Enabled"
  }
  depends_on = [aws_s3_bucket.teleios-divine-s3]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "teleios-divine-s3" {
  bucket = aws_s3_bucket.teleios-divine-s3.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "teleios-divine-s3" {
  bucket = aws_s3_bucket.teleios-divine-s3.id

  depends_on = [aws_s3_bucket_versioning.teleios-divine-s3]

  rule {
    id     = "current-version-rule"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    expiration {
      days = 365
    }
  }

  rule {
    id     = "noncurrent-version-rule"
    status = "Enabled"

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_expiration {
      noncurrent_days = 180
    }
  }
}
