
# terraform-aws-vpc-auy1105-grupo-1

Módulo Terraform para gestión de red en AWS: VPC, Subnet y Security Group.

## Uso

```hcl
module "redes" {
  source = "github.com/DemianH9/terraform-aws-vpc-auy1105-grupo-1?ref=v1.0.0"

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


# terraform-aws-ec2-auy1105-grupo-1

Módulo Terraform para el despliegue de instancias EC2 en AWS con Ubuntu 22.04.

## Uso

```hcl
module "computo" {
  source = "github.com/DemianH9/terraform-aws-ec2-auy1105-grupo-1?ref=v1.0.0"

  instance_name     = "mi-servidor"
  instance_type     = "t2.micro"
  subnet_id         = module.redes.subnet_ids[0]
  security_group_id = module.redes.security_group_id
}
```

## Variables

| Variable | Descripción | Tipo | Default |
|---|---|---|---|
| instance_name | Nombre de la instancia EC2 | string | Instancia-Ubuntu-Evaluacion |
| instance_type | Tipo de instancia EC2 | string | t2.micro |
| subnet_id | ID de la subnet donde se desplegará | string | requerido |
| security_group_id | ID del security group a asociar | string | requerido |

## Outputs

| Output | Descripción |
|---|---|
| instance_id | ID de la instancia EC2 creada |
| instance_ip | IP pública de la instancia EC2 |

## Dependencias

Este módulo requiere que existan previamente:
- Una subnet (puede usar el módulo `terraform-aws-vpc-auy1105-grupo-1`)
- Un security group asociado a la misma VPC
