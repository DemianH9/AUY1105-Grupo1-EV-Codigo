# Ejemplo de uso — Módulo VPC

## Descripción
Ejemplo funcional de uso del módulo de redes para crear una VPC básica en AWS.

## Cómo ejecutar

```bash
cd examples/
terraform init
terraform plan
terraform apply
```

## Resultado esperado
- Una VPC con CIDR 10.0.0.0/16
- Una subnet pública 10.0.1.0/24
- Un security group con SSH restringido