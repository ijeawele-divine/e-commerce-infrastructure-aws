output "instance_id" {
  value = aws_instance.teleios-divine-ec2.id
}

output "public_ip" {
  value = aws_instance.teleios-divine-ec2.public_ip
}