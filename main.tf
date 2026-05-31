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
  source = "github.com/DemianH9/terraform-aws-vpc-auy1105-grupo-1?ref=v1.0.0"

  vpc_name         = "VPC-Evaluacion"
  vpc_cidr         = "10.0.0.0/16"
  subnet_cidr      = "10.0.1.0/24"
  ssh_allowed_cidr = "192.168.1.50/32"
}

# 3. Módulo de Cómputo
module "computo" {
  source = "github.com/DemianH9/terraform-aws-ec2-auy1105-grupo-1?ref=v1.0.0"

  instance_name     = "Instancia-Ubuntu-Evaluacion"
  instance_type     = "t2.micro"
  subnet_id         = module.redes.subnet_ids[0]
  security_group_id = module.redes.security_group_id
}