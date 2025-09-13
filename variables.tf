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

variable "eks_subnet_cidr2" {
  description = "CIDR de la segunda subnet"
  type        = string
  default     = "10.240.2.0/24"
}

variable "tags" {
  description = "Tags comunes"
  type        = map(string)
  default = {
    project = "terraform-eks-demo"
    env     = "demo"
  }
}

variable "security_group_ids" {
  description = "IDs de los security groups"
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
