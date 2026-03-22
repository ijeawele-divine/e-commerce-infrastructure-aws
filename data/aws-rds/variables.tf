variable environment {
    type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "master_username" {
  type = string
  sensitive = true
}

variable "master_password" {
    type = string
    sensitive = true
}

variable "db_cluster_instance_class" {
  type = string 
}

variable "vpc_id" {
  type = string
}

variable "eks_node_security_group_id" {
  type = string
}

variable "database_name" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}