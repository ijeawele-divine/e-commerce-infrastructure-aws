data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-22.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "teleios-divine-ec2" {
    ami = data.aws_ami.ubuntu.id
    instance_type = var.instance_type
    key_name = var.key_name
    tags = {
        Name = "teleios-divine-${var.environment}-ec2"
    }
}

resource "aws_launch_template" "teleios-divine-launch-template" {
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
}

resource "aws_autoscaling_group" "teleios-divine-asg" {
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1

  vpc_zone_identifier = var.subnet_ids

  launch_template {
    id      = aws_launch_template.teleios-divine-launch-template.id
    version = "$Latest"
  }
}