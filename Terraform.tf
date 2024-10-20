terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = "us-east-1"
  access_key = "{access_key}"
  secret_key = "{secret_key}"
}

# PEM file
resource "tls_private_key" "rsa_4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Key pair
variable "key_name" {
  description = "The name of the SSH key pair"
  type        = string
}

resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.rsa_4096.public_key_openssh
}

resource "local_file" "private_key" {
  content  = tls_private_key.rsa_4096.private_key_pem
  filename = "${var.key_name}.pem"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main-vpc"
  }
}

# Subnet
resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "main-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# Route Table
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "main-route-table"
  }
}

# Route Table Association
resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

# Security Group to allow SSH and HTTP access
resource "aws_security_group" "instance" {
  vpc_id = aws_vpc.main.id

#Inbound Rule
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

#Outbound Rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "instance-sg"
  }
}

# Number of instances variable
variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 1
}

# EC2 Instance
resource "aws_instance" "EC2_test_Docker" {
  count		= var.instance_count
  ami           = "ami-04b70fa74e45c3917"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main.id
  key_name      = aws_key_pair.key_pair.key_name
  
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.instance.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y nginx git
#	      sudo apt-get install docker.io
              EOF

  tags = {
    Name = "Servers_${count.index + 1}"
  }
}

# Output the public IP address of the instance
output "instance_public_ip" {
  value = aws_instance.EC2_test_Docker[*].public_ip
}
