# 1. Configuración del proveedor AWS solicitando la última versión mayor (5.x)
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" 
    }
  }
}

provider "aws" {
  region = "us-east-1" # Puedes cambiar la región si tu profesor les indicó otra
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