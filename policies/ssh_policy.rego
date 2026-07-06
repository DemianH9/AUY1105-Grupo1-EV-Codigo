package terraform.policies

# Política 1: Denegar SSH Público
deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_security_group"

    ingress := resource.change.after.ingress[_]

    ingress.from_port == 22
    ingress.cidr_blocks[_] == "0.0.0.0/0"

    msg := sprintf("PELIGRO: El Security Group '%v' permite SSH (puerto 22) desde 0.0.0.0/0. Esto no esta permitido.", [resource.name])
}