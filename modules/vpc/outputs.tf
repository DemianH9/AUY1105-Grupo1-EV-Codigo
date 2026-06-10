output "vpc_id" {
  description = "ID de la VPC creada"
  value       = aws_vpc.main.id
}

output "subnet_ids" {
  description = "ID de la subnet creada"
  value       = [aws_subnet.main.id]
}

output "security_group_id" {
  description = "ID del security group"
  value       = aws_security_group.main.id
}