package terraform.policies

# Política 1: Denegar SSH Público
deny[msg] {
    # Busca recursos que sean Security Groups
    resource := input.resource_changes[_]
    resource.type == "aws_security_group"
    
    # Revisa las reglas de entrada (ingress)
    ingress := resource.change.after.ingress[_]
    
    # Verifica si el puerto 22 está abierto a 0.0.0.0/0
    ingress.from_port == 22
    ingress.cidr_blocks[_] == "0.0.0.0/0"
    
    msg := sprintf("PELIGRO: El Security Group '%v' permite SSH (puerto 22) desde 0.0.0.0/0. Esto no esta permitido.", [resource.name])
}