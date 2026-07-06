package terraform.policies

# Política 2: Restringir tipo de instancia EC2
deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_instance"

    instance_type := resource.change.after.instance_type
    instance_type != "t2.micro"

    msg := sprintf("ERROR: La instancia '%v' es de tipo '%v'. Solo se permite el uso de 't2.micro'.", [resource.name, instance_type])
}