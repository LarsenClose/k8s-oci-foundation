variable "compartment_id" {
  description = "OCI compartment OCID"
  type        = string
}

variable "vcn_id" {
  description = "VCN OCID"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet OCID for API endpoint"
  type        = string
}

variable "private_subnet_id" {
  description = "Private subnet OCID for worker nodes"
  type        = string
}

variable "cluster_name" {
  description = "OKE cluster name"
  type        = string
  default     = "k8s-cluster"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "v1.31.1"
}

variable "public_endpoint" {
  description = "Enable public API endpoint"
  type        = bool
  default     = true
}

variable "pods_cidr" {
  description = "CIDR for pod network"
  type        = string
  default     = "10.244.0.0/16"
}

variable "services_cidr" {
  description = "CIDR for service network"
  type        = string
  default     = "10.96.0.0/16"
}

variable "availability_domains" {
  description = "List of availability domains"
  type        = list(string)
}

variable "arm_node_pool_count" {
  description = "Number of ARM node pools"
  type        = number
  default     = 2
}

variable "arm_node_pool_size" {
  description = "Nodes per ARM pool"
  type        = number
  default     = 1
}

variable "arm_ocpus" {
  description = "OCPUs per ARM node"
  type        = number
  default     = 2
}

variable "arm_memory_gbs" {
  description = "Memory (GB) per ARM node"
  type        = number
  default     = 12
}

variable "arm_image_id" {
  description = "ARM node image OCID"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key for nodes"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Freeform tags"
  type        = map(string)
  default     = {}
}
