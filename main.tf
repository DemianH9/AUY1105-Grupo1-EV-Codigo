# 0. Versiones requeridas
terraform {
  required_version = ">= 1.2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# 1. Proveedor AWS
provider "aws" {
  region = "us-east-1"
}

# 2. Módulo de Redes
module "redes" {
  source = "./modules/vpc"

  vpc_name         = "VPC-Evaluacion"
  vpc_cidr         = "10.0.0.0/16"
  subnet_cidr      = "10.0.1.0/24"
  ssh_allowed_cidr = "192.168.1.50/32"
}

module "computo" {
  source = "./modules/ec2"

  instance_name     = "Instancia-Ubuntu-Evaluacion"
  instance_type     = "t2.micro"
  subnet_id         = module.redes.subnet_ids[0]
  security_group_id = module.redes.security_group_id
}