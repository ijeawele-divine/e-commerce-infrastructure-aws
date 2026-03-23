resource "aws_vpc" "teleios-divine-vpc"{
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"

    tags = {
        Name = "teleios-divine-${var.environment}-vpc"
    }
}

resource "aws_subnet" "teleios-divine-public-subnet" {
    for_each = var.public_subnets

    vpc_id = aws_vpc.teleios-divine-vpc.id
    cidr_block =  each.value.cidr_block
    availability_zone = each.value.availability_zone
    map_public_ip_on_launch = true

    tags = {
      Name = "teleios-divine-${var.environment}-public-subnet-${each.key}"
    }
}

resource "aws_internet_gateway" "teleios-divine-igw" {
    vpc_id = aws_vpc.teleios-divine-vpc.id

    depends_on = [
    aws_subnet.teleios-divine-public-subnet,
    aws_nat_gateway.teleios-divine-nat-gateway
    ]

    tags = {
        Name = "teleios-divine-${var.environment}-igw"
    }
}

resource "aws_route_table" "teleios-divine-rtb" {
    vpc_id = aws_vpc.teleios-divine-vpc.id

    route{
            cidr_block = "0.0.0.0/0"
            gateway_id = aws_internet_gateway.teleios-divine-igw.id
    }
    
    tags = {
        Name = "teleios-divine-${var.environment}-rtb"
    }
}

resource "aws_route_table_association" "teleios-divine-rtb-association" {
    for_each = aws_subnet.teleios-divine-public-subnet
    subnet_id = each.value.id
    route_table_id = aws_route_table.teleios-divine-rtb.id
}

resource "aws_subnet" "teleios-divine-private-subnet" {
  for_each = var.private_subnets
  vpc_id = aws_vpc.teleios-divine-vpc.id
  cidr_block = each.value.cidr_block
  availability_zone = each.value.availability_zone

  tags = {
      Name = "teleios-divine-${var.environment}-private-subnet-${each.key}"
    }
}

resource "aws_eip" "nat" {
  domain = "vpc"

  depends_on = [aws_internet_gateway.teleios-divine-igw]
}

resource "aws_nat_gateway" "teleios-divine-nat-gateway" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.teleios-divine-public-subnet["subnet-1"].id  # NAT Gateway lives in public subnet
}

resource "aws_route_table" "teleios-divine-private-rtb" {
  vpc_id = aws_vpc.teleios-divine-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.teleios-divine-nat-gateway.id
  }
}

resource "aws_route_table_association" "private" {
  for_each          = aws_subnet.teleios-divine-private-subnet
  subnet_id         = each.value.id
  route_table_id    = aws_route_table.teleios-divine-private-rtb.id
}

resource "aws_security_group" "teleios-divine-ssh-sg" {
  name   = "teleios-divine-${var.environment}-ssh-sg"
  vpc_id = aws_vpc.teleios-divine-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.teleios-divine-vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "teleios-divine-${var.environment}-ssh-sg"
  }
}

resource "aws_security_group" "teleios-divine-alb-sg" {
  name   = "teleios-divine-${var.environment}-alb-sg"
  vpc_id = aws_vpc.teleios-divine-vpc.id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "teleios-divine-${var.environment}-alb-sg"
  }
}