variable "environment" {
    type = string
}

variable "subnet_ids" {
    type = list(string)
}

variable "alb_sg_id" {
  type        = string
}

variable "instance_types" {
    type = list(string)
}

