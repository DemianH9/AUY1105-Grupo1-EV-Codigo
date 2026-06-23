# terraform-aws-vpc-auy1105-grupo-1

Módulo Terraform para gestión de red en AWS: VPC, Subnet y Security Group.

## Uso

```hcl
module "redes" {
  source = "github.com/DemianH9/AUY1105-Grupo1-EV-Codigo/tree/main/modules/vpc"

  vpc_name         = "mi-vpc"
  vpc_cidr         = "10.0.0.0/16"
  subnet_cidr      = "10.0.1.0/24"
  ssh_allowed_cidr = "192.168.1.50/32"
}
```

## Variables

| Variable | Descripción | Default |
|---|---|---|
| vpc_name | Nombre de la VPC | VPC-Evaluacion |
| vpc_cidr | CIDR de la VPC | 10.0.0.0/16 |
| subnet_cidr | CIDR de la subnet | 10.0.1.0/24 |
| ssh_allowed_cidr | IP permitida para SSH | 192.168.1.50/32 |

## Outputs

| Output | Descripción |
|---|---|
| vpc_id | ID de la VPC |
| subnet_ids | IDs de las subnets |
| security_group_id | ID del Security Group |
