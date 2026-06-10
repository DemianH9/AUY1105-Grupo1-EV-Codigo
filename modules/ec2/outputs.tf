output "instance_id" {
  description = "ID de la instancia EC2 creada"
  value       = aws_instance.main.id
}

output "instance_ip" {
  description = "IP publica de la instancia EC2"
  value       = aws_instance.main.public_ip
}