# 0. Configuración de versiones requeridas (Para que TFLint pase)
terraform {
  required_version = ">= 1.2.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# 1. Configuración del Proveedor AWS
provider "aws" {
  region = "us-east-1"
}

# 2. Creación de la VPC (Red)
resource "aws_vpc" "mi_red" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "VPC-Evaluacion"
  }
}

# 3. Creación de la Subred (/24 según la pauta)
resource "aws_subnet" "mi_subred" {
  vpc_id     = aws_vpc.mi_red.id
  cidr_block = "10.0.1.0/24"
  
  tags = {
    Name = "Subred-Evaluacion"
  }
}

# 4. Creación del Security Group Seguro (Para pasar el test de OPA)
resource "aws_security_group" "mi_sg_seguro" {
  name        = "sg_reglas_estrictas"
  description = "Permitir SSH solo desde IP especifica"
  vpc_id      = aws_vpc.mi_red.id

  # Regla de Entrada: Solo SSH desde una IP específica (NO 0.0.0.0/0)
  ingress {
    description = "SSH restringido"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["192.168.1.50/32"] 
  }

  # Regla de Salida: Permitir todo el tráfico hacia afuera
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 5. Buscar la imagen oficial de Ubuntu
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# 6. Creación de la Instancia EC2 (t2.micro según la pauta)
resource "aws_instance" "mi_servidor" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  
  # Aquí se enlazan automáticamente los nombres creados arriba
  subnet_id              = aws_subnet.mi_subred.id
  vpc_security_group_ids = [aws_security_group.mi_sg_seguro.id]

  tags = {
    Name = "Instancia-Ubuntu-Evaluacion"
  }
}