variable "resource_group_name" {
  description = "Nombre del Resource Group"
  type        = string
  default     = "rg-aks-demo"
}

variable "name_prefix" {
  description = "Prefijo para nombres de recursos"
  type        = string
  default     = "tfaks"
}

variable "location" {
  description = "Región de Azure"
  type        = string
  default     = "eastus2"
}

variable "vnet_cidr" {
  description = "CIDR de la VNet"
  type        = string
  default     = "10.240.0.0/16"
}

variable "aks_subnet_cidr" {
  description = "CIDR de la subnet para AKS"
  type        = string
  default     = "10.240.1.0/24"
}

variable "node_count" {
  description = "Número de nodos en el node pool"
  type        = number
  default     = 1
}

variable "node_vm_size" {
  description = "SKU de VM para los nodos"
  type        = string
  default     = "Standard_B4ms"
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

variable "tags" {
  description = "Tags comunes"
  type        = map(string)
  default     = {
    project = "terraform-aks-demo"
    env     = "demo"
  }
}
