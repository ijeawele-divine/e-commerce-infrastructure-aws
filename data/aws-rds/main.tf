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

  ingress {
    description = "Temporary - PostgreSQL from Terraform Cloud"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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

resource "aws_db_subnet_group" "teleios-divine-rds-subnet-group" {
  name       = "teleios-divine-${var.environment}-rds-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "teleios-divine-${var.environment}-rds-subnet-group"
    Environment = var.environment
  }
}

resource "aws_rds_cluster" "teleios-divine-rds" {
  cluster_identifier      = "teleios-divine-${var.environment}-rds"
  engine                  = "aurora-postgresql"
  master_username         = var.master_username
  master_password         = var.master_password
  database_name           = var.database_name
  storage_encrypted       = true
  skip_final_snapshot     = var.skip_final_snapshot
  backup_retention_period = 7
  preferred_backup_window = "02:00-03:00"
  db_subnet_group_name    = aws_db_subnet_group.teleios-divine-rds-subnet-group.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
}

resource "aws_rds_cluster_instance" "teleios-divine-rds-instance" {
  identifier         = "teleios-divine-${var.environment}-rds-instance"
  cluster_identifier = aws_rds_cluster.teleios-divine-rds.id
  instance_class     = var.db_cluster_instance_class
  engine             = aws_rds_cluster.teleios-divine-rds.engine
  engine_version     = aws_rds_cluster.teleios-divine-rds.engine_version
  publicly_accessible = true
}