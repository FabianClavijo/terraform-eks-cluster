variable "aws_region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"
}
variable "vnet_cidr" {
  description = "CIDR de la VPC"
  type        = string
  default     = "10.240.0.0/16"
}

variable "eks_subnet_cidr" {
  description = "CIDR de la subnet"
  type        = string
  default     = "10.240.1.0/24"
}

variable "tags" {
  description = "Tags comunes"
  type        = map(string)
  default = {
    project = "terraform-eks-demo"
    env     = "demo"
  }
}
variable "region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"
}

variable "subnet_ids" {
  description = "IDs de las subnets donde desplegar el clúster"
  type        = list(string)
  default     = []
}

variable "desired_node_count" {
  description = "Número de nodos en el node group"
  type        = number
  default     = 2
}

variable "node_instance_type" {
  description = "Tipo de instancia para los nodos"
  type        = string
  default     = "t3.medium"
}

variable "service_ipv4_cidr" {
  description = "CIDR para los servicios de Kubernetes"
  type        = string
  default     = "10.100.0.0/16"
}
variable "cluster_name" {
  description = "Nombre del clúster EKS"
  type        = string
  default     = "eks-demo"
}

variable "name_prefix" {
  description = "Prefijo para nombres de recursos"
  type        = string
  default     = "tfeks"
}

variable "vpc_cidr" {
  description = "CIDR de la VPC"
  type        = string
  default     = "10.240.0.0/16"
}

variable "node_count" {
  description = "Número de nodos en el node pool"
  type        = number
  default     = 1
}

variable "instance_type" {
  description = "Tipo de instancia para los nodos"
  type        = string
  default     = "t3.medium"
}

variable "availability_zones" {
  description = "Zonas de disponibilidad para el node pool (opcional)"
  type        = list(string)
  default     = ["1", "2"]
}

# Red de servicios de Kubernetes (no debe solaparse con la VNet)
variable "service_cidr" {
  description = "CIDR para servicios de Kubernetes"
  type        = string
  default     = "10.2.0.0/16"
}

variable "dns_service_ip" {
  description = "IP del CoreDNS dentro del service CIDR"
  type        = string
  default     = "10.2.0.10"
}

variable "docker_bridge_cidr" {
  description = "CIDR del docker bridge en nodos"
  type        = string
  default     = "172.17.0.1/16"
}

# Features opcionales
variable "oidc_issuer_enabled" {
  description = "Habilitar OIDC issuer para federación"
  type        = bool
  default     = true
}

variable "workload_identity_enabled" {
  description = "Habilitar Workload Identity"
  type        = bool
  default     = true
}