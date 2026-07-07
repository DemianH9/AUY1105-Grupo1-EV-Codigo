# AUY1105-Grupo1-EV-Codigo

> **Repositorio principal — Evaluación Final Transversal (EFT)**
> Asignatura: AUY1105 — Infraestructura como Código II | DuocUC

---

## Descripción

Este repositorio consolida el trabajo desarrollado en los Parciales 1, 2 y 3 de la asignatura, e implementa una solución de infraestructura en AWS mediante Terraform como tecnología de Infraestructura como Código (IaC), con un pipeline de CI/CD que valida calidad, seguridad y políticas antes de cada despliegue.

En lugar de definir los recursos directamente, el `main.tf` principal orquesta dos módulos reutilizables mantenidos como subcarpetas versionadas dentro de este mismo repositorio:

- **Módulo de Redes** (`modules/vpc`) → VPC, Subnet pública y Security Group
- **Módulo de Cómputo** (`modules/ec2`) → Instancia EC2 con Ubuntu 22.04 (AMI dinámica de Canonical)

Los outputs del módulo de redes se pasan directamente como inputs al módulo de cómputo, garantizando el encadenamiento correcto entre ambos.

> **Nota sobre la estructura:** los módulos se mantienen como subcarpetas de un único repositorio (monorepo) en lugar de repositorios independientes por módulo. Esto simplifica la gestión para un proyecto académico, a cambio de no cumplir la convención `terraform-<PROVIDER>-<NAME>` que exige la publicación pública en el Terraform Registry. El versionado semántico (Releases `v1.0.0`/`v1.0.1`) se aplica igualmente sobre este repositorio.

---

## Arquitectura

```
AUY1105-Grupo1-EV-Codigo/
├── main.tf                        ← Orquesta los módulos con bloques module {}
├── .github/workflows/
│   └── terraform.yml              ← CI/CD: TFLint + Checkov + terraform validate
├── policies/
│   ├── ec2_policy.rego            ← Política OPA: solo instancias t2.micro
│   └── ssh_policy.rego            ← Política OPA: SSH nunca abierto a 0.0.0.0/0
├── modules/
│   ├── vpc/                       ← Módulo de red (README y CHANGELOG propios)
│   └── ec2/                       ← Módulo de cómputo (README y CHANGELOG propios)
├── .gitignore                     ← Ignora tfplan, tfplan.json y binarios de conftest
├── CHANGELOG.md
└── README.md
```

---

## Módulos utilizados

### Módulo de Redes (VPC) — `modules/vpc`

**Propósito:** Crea la VPC, subnet pública y security group con SSH restringido a una IP específica.

```hcl
module "redes" {
  source = "./modules/vpc"

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

### Módulo de Cómputo (EC2) — `modules/ec2`

**Propósito:** Despliega una instancia EC2 con Ubuntu 22.04, usando una AMI resuelta dinámicamente vía `data source` (siempre la última imagen oficial de Canonical, evitando IDs hardcodeados).

```hcl
module "computo" {
  source = "./modules/ec2"

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
| Conftest (OPA) | `>= 0.51.0` |
| Región AWS | `us-east-1` |

---

## Uso — Despliegue completo

```bash
# 1. Clonar el repositorio
git clone https://github.com/DemianH9/AUY1105-Grupo1-EV-Codigo.git
cd AUY1105-Grupo1-EV-Codigo

# 2. Configurar credenciales temporales de AWS Academy Learner Lab
aws configure
aws configure set aws_session_token TU_SESSION_TOKEN

# 3. Inicializar
terraform init

# 4. Validar sintaxis y coherencia
terraform validate

# 5. Generar el plan de ejecución (4 recursos: VPC, Subnet, SG, EC2)
terraform plan -out=tfplan

# 6. Evaluar las políticas de seguridad (OPA/Rego) contra el plan
terraform show -json tfplan > tfplan.json
conftest test tfplan.json -p policies/ --namespace terraform.policies

# 7. Desplegar infraestructura (solo si el paso anterior pasa)
terraform apply tfplan

# 8. Destruir recursos al finalizar (buena práctica en Learner Lab)
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

## Políticas de seguridad como código (OPA / Rego)

La carpeta `policies/` define dos políticas evaluadas automáticamente contra el plan de Terraform mediante `conftest`, actuando como un sistema de permisos automatizado sobre los cambios propuestos:

| Política | Regla |
|---|---|
| `ssh_policy.rego` | Deniega cualquier Security Group que abra el puerto 22 a `0.0.0.0/0` |
| `ec2_policy.rego` | Deniega cualquier instancia EC2 que no sea de tipo `t2.micro` |

Ambas políticas están escritas en sintaxis Rego v1 (`deny contains msg if { ... }`), compatible con las versiones actuales de OPA/conftest.

```bash
conftest test tfplan.json -p policies/ --namespace terraform.policies
```

---

## Automatización CI/CD — GitHub Actions

El workflow **Terraform Quality & Security Analysis** (`.github/workflows/terraform.yml`) se dispara automáticamente en cada Pull Request hacia `main`.

**Etapas del pipeline:**

| Etapa | Herramienta | Descripción |
|---|---|---|
| 1 | `terraform validate` | Validación de sintaxis y coherencia HCL |
| 2 | TFLint `v0.50.0` | Análisis estático de buenas prácticas |
| 3 | Checkov | Análisis de seguridad de la configuración |

> La evaluación de políticas OPA (`conftest`) se ejecuta hoy de forma manual antes de cada `apply` (ver sección anterior). Su integración como etapa automática dentro del pipeline de GitHub Actions está documentada como mejora en el `CHANGELOG.md`.

---

## Versionado semántico

Este repositorio implementa **SemVer (MAJOR.MINOR.PATCH)** mediante Releases de GitHub:

| Versión | Descripción |
|---|---|
| `v1.0.0` | Primera versión estable del módulo de cómputo (EC2) |
| `v1.0.1` | Primera versión estable del módulo de red (VPC) |

Ver [Releases](https://github.com/DemianH9/AUY1105-Grupo1-EV-Codigo/releases) para el detalle de cada versión.

---

## Verificación en AWS (EFT — Julio 2026)

Última verificación exitosa de despliegue completo:

**Instancia EC2:**
- Nombre: `Instancia-Ubuntu-Evaluacion`
- ID: `i-060ae8d0fa85c6d81`
- Tipo: `t2.micro` — Estado verificado: `running`, 2/2 checks passed
- Security Group: `VPC-Evaluacion-sg`

Posterior a la verificación se ejecutó `terraform destroy -auto-approve`, eliminando los 4 recursos en orden inverso de dependencias (EC2 primero, VPC al último). El historial completo de despliegues previos (incluyendo el de la Evaluación Parcial N°2) se encuentra documentado en `CHANGELOG.md`.

---

## Historial de cambios

Ver [CHANGELOG.md](./CHANGELOG.md) para el historial completo de versiones.

