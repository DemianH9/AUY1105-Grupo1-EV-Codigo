# Ejemplo de uso — Módulo EC2

## Descripción
Ejemplo funcional de uso del módulo de cómputo para desplegar una instancia EC2 Ubuntu en AWS.

## Requisitos previos
- Una subnet existente
- Un security group existente en la misma VPC

## Cómo ejecutar

```bash
cd examples/
terraform init
terraform plan
terraform apply
```

## Resultado esperado
- Una instancia EC2 t2.micro con Ubuntu 22.04
- Asociada a la subnet y security group indicados