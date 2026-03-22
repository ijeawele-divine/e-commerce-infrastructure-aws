output "rds_endpoint" {
  value = aws_rds_cluster.teleios-divine-rds.endpoint
}

output "rds_port" {
  value = aws_rds_cluster.teleios-divine-rds.port
}