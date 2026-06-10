module "redes" {
  source = "../"

  vpc_name         = "ejemplo-vpc"
  vpc_cidr         = "10.0.0.0/16"
  subnet_cidr      = "10.0.1.0/24"
  ssh_allowed_cidr = "192.168.1.50/32"
}

output "vpc_id" {
  value = module.redes.vpc_id
}