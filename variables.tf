# ── Shared ────────────────────────────────────────────────────────

variable "environment" {
  type        = string
  description = "Deployment environment (dev, staging, prod)"
}

variable "availability_zones" {
  type        = list(string)
  description = "AZs to deploy into"
}

# ── Networking ────────────────────────────────────────────────────

variable "public_subnets" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
  description = "Map of public subnets. Key is a label e.g. 'subnet-1'"
}

variable "private_subnets" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
  description = "Map of private subnets"
}

# ── EKS ───────────────────────────────────────────────────────────

variable "eks_instance_types" {
  type        = list(string)
  description = "EC2 instance types for EKS node group"
}

# ── EC2 ───────────────────────────────────────────────────────────

variable "ec2_instances" {
  type = map(object({
    instance_type = string
  }))
  description = "Map of EC2 instances to provision. Key becomes part of the resource name"
}

variable "ec2_key_name" {
  type        = string
  description = "SSH key pair name for EC2 instances"
}

# ── RDS ───────────────────────────────────────────────────────────
# Not a map - one RDS cluster per environment

variable "db_cluster_instance_class" {
  type        = string
  description = "RDS instance class e.g. db.t3.medium"
}

variable "database_name" {
  type        = string
  description = "Initial database name"
}

variable "master_username" {
  type        = string
  sensitive   = true
  description = "RDS master username - set in Terraform Cloud, not in .tfvars"
}

variable "skip_final_snapshot" {
  type    = bool
}

variable "master_password" {
  type        = string
  sensitive   = true
  description = "RDS master password - set in Terraform Cloud, not in .tfvars"
}

# ── Redis ─────────────────────────────────────────────────────────
# Not a map - one Redis replication group per environment

variable "redis_node_type" {
  type        = string
  description = "ElastiCache node type e.g. cache.t3.micro"
}

# ── S3 ────────────────────────────────────────────────────────────

variable "s3_buckets" {
  type = map(object({
    versioning = bool
  }))
  description = "Map of S3 buckets to provision. Key becomes part of the bucket name"
}

variable "jwt_secret" {
  type      = string
  sensitive = true
}

variable "google_client_id" {
  type      = string
  sensitive = true
}

variable "google_client_secret" {
  type      = string
  sensitive = true
}

variable "azure_email_connection_string" {
  type      = string
  sensitive = true
}

variable "sender_email" {
  type = string
}

variable "next_public_mapbox_access_token" {
  type      = string
  sensitive = true
}