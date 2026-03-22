# Security Group (created internally per spec)

resource "aws_security_group" "rds_sg" {
  name        = "teleios-divine-${var.environment}-rds-sg"
  description = "Security group for Teleios Divine RDS PostgreSQL"
  vpc_id      = var.vpc_id

  ingress {
    description     = "PostgreSQL from app layer"
    from_port       = 5432
    to_port         = 5432
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
    Name        = "teleios-divine-${var.environment}-rds-sg"
    Environment = var.environment
  }
}

resource "aws_rds_cluster" "teleios-divine-rds" {
  cluster_identifier        = "teleios-divine-${var.environment}-rds"
  availability_zones        =  var.availability_zones
  engine                    = "postgres"
  db_cluster_instance_class =  var.db_cluster_instance_class
  storage_type              = "io1"
  allocated_storage         = 100
  iops                      = 1000

  master_username           = var.master_username
  master_password           = var.master_password
  database_name             = var.database_name

  storage_encrypted = true

  backup_retention_period = 7
  preferred_backup_window = "14:00-15:00"
}

