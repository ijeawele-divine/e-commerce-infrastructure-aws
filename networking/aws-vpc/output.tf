output "vpc_id" {
  value = aws_vpc.teleios-divine-vpc.id
}

output "public_subnet_ids" {
    value = [ for subnet in aws_subnet.teleios-divine-public-subnet : subnet.id ]
}

output "alb_sg_id" {
  value = aws_security_group.teleios-divine-alb-sg.id
}

output "ssh_sg_id" {
  value = aws_security_group.teleios-divine-ssh-sg.id
}

output "private_subnet_ids" {
  value = [ for subnet in aws_subnet.teleios-divine-private-subnet : subnet.id ]
}

output "vpc_cidr" {
  value = aws_vpc.teleios-divine-vpc.cidr_block
}