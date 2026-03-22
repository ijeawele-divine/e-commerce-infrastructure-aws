# ── Cache Security Group ──────────────────────────────────────────
resource "aws_security_group" "teleios-divine-redis-sg" {
  name        = "teleios-divine-${var.environment}-redis-sg"
  description = "Security group for Teleios Divine ElastiCache Redis"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Redis from EKS nodes"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [var.eks_node_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "teleios-divine-${var.environment}-redis-sg"
    Environment = var.environment
  }
}

# ── Cache Subnet Group ────────────────────────────────────────────
resource "aws_elasticache_subnet_group" "teleios-divine-redis-subnet-group" {
  name       = "teleios-divine-${var.environment}-redis-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "teleios-divine-${var.environment}-redis-subnet-group"
    Environment = var.environment
  }
}

# ── Replication Group (primary + replica) ─────────────────────────
resource "aws_elasticache_replication_group" "teleios-divine-redis" {
  replication_group_id       = "teleios-divine-${var.environment}-redis"   # ✅ consistent namin
  description                = "Teleios Divine ${var.environment} Redis replication group"

  engine_version             = "7.1"                    
  node_type                  = var.node_type             
  parameter_group_name       = "default.redis7"          
  port                       = 6379

  automatic_failover_enabled = true
  num_cache_clusters         = 2                         
  preferred_cache_cluster_azs = var.availability_zones

  subnet_group_name          = aws_elasticache_subnet_group.teleios-divine-redis-subnet-group.name  # ✅ Added
  security_group_ids         = [aws_security_group.teleios-divine-redis-sg.id]                      # ✅ Added

  at_rest_encryption_enabled = true    
  transit_encryption_enabled = true   

  lifecycle {
    ignore_changes = [num_cache_clusters]
  }

  tags = {
    Name        = "teleios-divine-${var.environment}-redis"
    Environment = var.environment
  }
}