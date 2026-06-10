variable "vpc_name" {
  description = "Nombre de la VPC"
  type        = string
  default     = "VPC-Evaluacion"
}

variable "vpc_cidr" {
  description = "CIDR block de la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block de la subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "ssh_allowed_cidr" {
  description = "IP desde la que se permite SSH"
  type        = string
  default     = "192.168.1.50/32"
}