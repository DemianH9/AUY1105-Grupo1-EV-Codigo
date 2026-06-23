# terraform-aws-ec2-auy1105-grupo-1

Módulo Terraform para el despliegue de instancias EC2 en AWS con Ubuntu 22.04.

## Uso

```hcl
module "computo" {
  source = "github.com/DemianH9/AUY1105-Grupo1-EV-Codigo/tree/main/modules/vpc"

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
