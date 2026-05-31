# AUY1105 - Evaluación Parcial 1 - Grupo 1

## Propósito General
Este repositorio contiene la evaluación práctica de la asignatura **Infraestructura como Código II**. El propósito de este proyecto es implementar un pipeline automatizado mediante GitHub Actions, integrando herramientas de análisis de calidad, seguridad y prácticas modernas de infraestructura como código (IaC) utilizando Terraform y AWS.

## Objetivos del Repositorio
- Almacenar el código Terraform para el despliegue de infraestructura en la nube (AWS).
- Definir un flujo de trabajo automatizado (CI/CD) con GitHub Actions que se active mediante Pull Requests.
- Integrar herramientas de análisis estático (`tflint`) y análisis de seguridad (`checkov`).
- Implementar políticas de seguridad utilizando Open Policy Agent (OPA).
- Aplicar buenas prácticas de trabajo colaborativo mediante Pull Requests y revisiones de código.

## Definición del Código Terraform
La infraestructura como código definida en este repositorio está diseñada para ser desplegada en **AWS** (Amazon Web Services), utilizando la última versión mayor del proveedor (v5.x). 

La infraestructura comprende los siguientes recursos:
- **Proveedor Cloud:** AWS (`hashicorp/aws`).
- **Redes y Seguridad:**
  - **VPC:** Bloque CIDR `10.1.0.0/16`.
  - **Subred:** Rango de direcciones IP con máscara `/24` (ej. `10.1.1.0/24`).
  - **Security Group:** Configurado para permitir únicamente tráfico entrante por el protocolo SSH (Puerto 22).
- **Cómputo:**
  - **EC2:** Una instancia con sistema operativo Ubuntu 24.04 LTS y de tipo `t2.micro`.
  
*Nota: Todos los recursos creados siguen la nomenclatura: `<sigla-curso>-<nombre-aplicación>-<tipo-recurso>`.*

## Instrucciones Básicas de Uso

1. **Clonar el repositorio:**
   ```bash
   git clone [https://github.com/TuUsuario/AUY1105-Grupo1-EV-Codigo.git](https://github.com/TuUsuario/AUY1105-Grupo1-EV-Codigo.git)

## 🚀 Pipeline de Integración Continua (CI)
Este proyecto utiliza GitHub Actions para garantizar la calidad y seguridad de la infraestructura. El flujo de trabajo incluye:
1. **TFLint:** Análisis estático para detectar errores en el código Terraform.
2. **Checkov:** Análisis de seguridad para prevenir vulnerabilidades en AWS.
3. **Terraform Validate:** Verificación de sintaxis interna.
4. **Open Policy Agent (Conftest):** Validación estricta de políticas de seguridad (restringiendo puertos y tipos de instancias). 
