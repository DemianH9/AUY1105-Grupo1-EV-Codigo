# 1. Configuración del proveedor AWS solicitando la última versión mayor (5.x)
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" 
    }
  }
}

provider "aws" {
  region = "us-east-1" 
}

# 2. Creación de la VPC con el bloque CIDR exigido
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    # Recuerda la nomenclatura obligatoria: <sigla-curso>-<nombre-aplicación>-<tipo-recurso>
    Name = "AUY1105-evaluacion-vpc" 
  }
}

# 3. Creación de la Subred (Máscara /24 dentro de la VPC)
resource "aws_subnet" "main_subnet" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.1.1.0/24"

  tags = {
    Name = "AUY1105-evaluacion-subnet"
  }
}

# 4. Security Group: Permitir solo SSH (Puerto 22)
resource "aws_security_group" "ssh_sg" {
  name        = "allow_ssh"
  description = "Permitir trafico entrante SSH"
  vpc_id      = aws_vpc.main_vpc.id

    ingress {
    description = "SSH restringido a IP especifica"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["192.168.1.50/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "AUY1105-evaluacion-sg"
  }
}

# Data source para obtener dinámicamente la última imagen (AMI) de Ubuntu 24.04 LTS
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

# 5. Cómputo: Instancia EC2 (Ubuntu 24.04 LTS, t2.micro)
resource "aws_instance" "main_ec2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main_subnet.id
  vpc_security_group_ids = [aws_security_group.ssh_sg.id]

  tags = {
    Name = "AUY1105-evaluacion-ec2"
  }
}