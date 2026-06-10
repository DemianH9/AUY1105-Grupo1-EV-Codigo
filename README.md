# AUY1105-Grupo1-EV-Codigo

> **Repositorio principal — Evaluación Parcial N°2**
> Asignatura: AUY1105 — Infraestructura como Código II | DuocUC
> Estudiante: Demian Hurtubia · GitHub: [DemianH9](https://github.com/DemianH9)

---

## Descripción

Este repositorio actúa como **controlador central** de la infraestructura en AWS, refactorizado desde una arquitectura monolítica (Parcial 1) hacia una arquitectura **completamente modular** en Terraform.

En lugar de definir recursos directamente, el `main.tf` principal orquesta dos módulos independientes y versionados:

- **Módulo de Redes** → VPC, Subnet pública y Security Group
- **Módulo de Cómputo** → Instancia EC2 con Ubuntu 22.04 (AMI dinámica de Canonical)

Los outputs del módulo de redes son pasados directamente como inputs al módulo de cómputo, garantizando el encadenamiento correcto entre ambos.

---

## Arquitectura

```
AUY1105-Grupo1-EV-Codigo/          ← Repositorio principal (orquestador)
│
├── main.tf                        ← Llama a los dos módulos con bloques module {}
├── .github/workflows/
│   └── terraform.yml              ← CI/CD: TFLint + Checkov + terraform validate
├── policies/
│   ├── ec2_policy.rego            ← Política OPA para instancias EC2
│   └── ssh_policy.rego            ← Política OPA para reglas SSH
├── modules/                       ← Carpeta de módulos consolidados (EP2)
│   ├── vpc/                       ← Copia local del módulo de redes
│   └── ec2/                       ← Copia local del módulo de cómputo
├── CHANGELOG.md
├── .gitignore
└── README.md

Módulos externos versionados en GitHub:
  ├── Terraform-AWS-VPC-AUY1105-grupo-1   (ref: v1.0.0)
  └── Terraform-AWS-EC2-AUY1105-grupo-1   (ref: v1.0.0)
```

---

## Módulos utilizados

### Módulo de Redes (VPC)

**Repositorio:** [Terraform-AWS-VPC-AUY1105-grupo-1](https://github.com/DemianH9/Terraform-AWS-VPC-AUY1105-grupo-1)
**Versión:** `v1.0.0`
**Propósito:** Crea la VPC, subnet pública y security group con SSH restringido.

```hcl
module "redes" {
  source = "github.com/DemianH9/Terraform-AWS-VPC-AUY1105-grupo-1?ref=v1.0.0"

  vpc_name         = "VPC-Evaluacion"
  vpc_cidr         = "10.0.0.0/16"
  subnet_cidr      = "10.0.1.0/24"
  ssh_allowed_cidr = "192.168.1.50/32"
}
```

**Variables:**

| Variable | Descripción | Default |
|---|---|---|
| `vpc_name` | Nombre de la VPC | `VPC-Evaluacion` |
| `vpc_cidr` | CIDR block de la VPC | `10.0.0.0/16` |
| `subnet_cidr` | CIDR block de la subnet | `10.0.1.0/24` |
| `ssh_allowed_cidr` | IP permitida para SSH | `192.168.1.50/32` |

**Outputs exportados:**

| Output | Descripción |
|---|---|
| `vpc_id` | ID de la VPC creada |
| `subnet_ids` | Lista de IDs de las subnets |
| `security_group_id` | ID del Security Group |

---

### Módulo de Cómputo (EC2)

**Repositorio:** [Terraform-AWS-EC2-AUY1105-grupo-1](https://github.com/DemianH9/Terraform-AWS-EC2-AUY1105-grupo-1)
**Versión:** `v1.0.0`
**Propósito:** Despliega una instancia EC2 con Ubuntu 22.04 usando AMI dinámica de Canonical.

```hcl
module "computo" {
  source = "github.com/DemianH9/Terraform-AWS-EC2-AUY1105-grupo-1?ref=v1.0.0"

  instance_name     = "Instancia-Ubuntu-Evaluacion"
  instance_type     = "t2.micro"
  subnet_id         = module.redes.subnet_ids[0]
  security_group_id = module.redes.security_group_id
}
```

**Variables:**

| Variable | Descripción | Tipo | Default |
|---|---|---|---|
| `instance_name` | Nombre de la instancia EC2 | `string` | `Instancia-Ubuntu-Evaluacion` |
| `instance_type` | Tipo de instancia EC2 | `string` | `t2.micro` |
| `subnet_id` | ID de la subnet de destino | `string` | requerido |
| `security_group_id` | ID del security group | `string` | requerido |

**Outputs exportados:**

| Output | Descripción |
|---|---|
| `instance_id` | ID de la instancia EC2 creada |
| `instance_ip` | IP privada de la instancia |

---

## Requisitos

| Herramienta | Versión mínima |
|---|---|
| Terraform | `>= 1.2.0` |
| Provider `hashicorp/aws` | `~> 5.0` |
| Región AWS | `us-east-1` |

---

## Uso — Despliegue completo

```bash
# 1. Clonar el repositorio
git clone https://github.com/DemianH9/AUY1105-Grupo1-EV-Codigo.git
cd AUY1105-Grupo1-EV-Codigo

# 2. Inicializar — descarga módulos externos y proveedor AWS
terraform init

# 3. Validar sintaxis y coherencia
terraform validate

# 4. Revisar el plan de ejecución (4 recursos: VPC, Subnet, SG, EC2)
terraform plan

# 5. Desplegar infraestructura
terraform apply -auto-approve

# 6. Destruir recursos al finalizar (buena práctica en Learner Lab)
terraform destroy -auto-approve
```

---

## Recursos creados

Al ejecutar `terraform apply`, se crean exactamente **4 recursos** en AWS:

| # | Recurso | Nombre | Detalles |
|---|---|---|---|
| 1 | `aws_vpc` | VPC-Evaluacion | CIDR: `10.0.0.0/16`, región `us-east-1` |
| 2 | `aws_subnet` | VPC-Evaluacion-subnet | CIDR: `10.0.1.0/24` |
| 3 | `aws_security_group` | VPC-Evaluacion-sg | Ingress SSH puerto 22 restringido |
| 4 | `aws_instance` | Instancia-Ubuntu-Evaluacion | Ubuntu 22.04, tipo `t2.micro` |

Los módulos se crean y destruyen respetando el **orden de dependencias** (EC2 depende de la red).

---

## Automatización CI/CD — GitHub Actions

El workflow **Terraform Quality & Security Analysis** se dispara automáticamente en cada Pull Request hacia `main`.

**Archivo:** `.github/workflows/terraform.yml`

**Etapas del pipeline:**

| Etapa | Herramienta | Descripción |
|---|---|---|
| 1 | `terraform validate` | Validación de sintaxis y coherencia HCL |
| 2 | TFLint `v0.50.0` | Análisis estático de buenas prácticas |
| 3 | Checkov | Análisis de seguridad de la configuración |

Las políticas de seguridad se definen en la carpeta `policies/` usando **OPA (Open Policy Agent)**:

- `ec2_policy.rego` — Validaciones sobre instancias EC2
- `ssh_policy.rego` — Validaciones sobre reglas de acceso SSH

**Resultado en evaluación (31-05-2026):** ✅ éxito en 41 segundos (workflow #12).

---

## Versionado semántico

Este repositorio y sus módulos implementan **SemVer (MAJOR.MINOR.PATCH)**:

| Repositorio | v0.1.0 | v1.0.0 |
|---|---|---|
| `AUY1105-Grupo1-EV-Codigo` | Estructura base del Parcial 1 | Refactorización modular (EP2) |
| `Terraform-AWS-VPC-AUY1105-grupo-1` | Archivos base creados | Módulo VPC funcional y estable |
| `Terraform-AWS-EC2-AUY1105-grupo-1` | Archivos base creados | Módulo EC2 funcional y estable |

Los releases formales están publicados en GitHub con descripción detallada de cambios por versión.

---

## Verificación en AWS (EP2 — 31 de Mayo, 2026)

Recursos creados y verificados en consola AWS:

**VPC:**
- Nombre: `VPC-Evaluacion`
- ID: `vpc-02a50fe976f00f7a2`
- CIDR: `10.0.0.0/16` — Estado: Available

**Instancia EC2:**
- Nombre: `Instancia-Ubuntu-Evaluacion`
- ID: `i-0ee1fb533958d5c69`
- Tipo: `t2.micro` — Estado: running
- IP Privada: `10.0.1.131`

Posterior a la verificación se ejecutó `terraform destroy -auto-approve`, eliminando los 4 recursos en orden inverso de dependencias (EC2 primero, VPC al último).

---

## Historial de cambios

Ver [CHANGELOG.md](./CHANGELOG.md) para el historial completo de versiones.

---

## Estructura del equipo

| Campo | Detalle |
|---|---|
| Asignatura | AUY1105 — Infraestructura como Código II |
| Evaluación | Parcial N°2 — Implementación de Módulos Terraform |
| Estudiante | Demian Hurtubia |
| GitHub | [DemianH9](https://github.com/DemianH9) |
| Institución | DuocUC |
| Fecha entrega | 31 de Mayo, 2026 |
