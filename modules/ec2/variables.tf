variable "instance_name" {
  description = "Nombre de la instancia EC2"
  type        = string
  default     = "Instancia-Ubuntu-Evaluacion"
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "ID de la subnet donde se desplegara la instancia"
  type        = string
}

variable "security_group_id" {
  description = "ID del security group a asociar"
  type        = string
}