variable "tenancy_ocid" {
  description = "OCI tenancy OCID"
  type        = string
}

variable "compartment_id" {
  description = "OCI compartment OCID"
  type        = string
}

variable "region" {
  description = "OCI region"
  type        = string
  default     = "us-phoenix-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare account ID"
  type        = string
}

variable "cloudflare_domain" {
  description = "Domain for DNS records (e.g., example.com)"
  type        = string
}

variable "cloudflare_create_zone" {
  description = "Whether to create a new Cloudflare zone or use existing"
  type        = bool
  default     = false
}

variable "load_balancer_ip" {
  description = "Istio Gateway LoadBalancer IP (set after first deployment)"
  type        = string
  default     = ""
}

variable "custom_dns_records" {
  description = "Custom DNS records for applications"
  type = map(object({
    name    = string
    type    = string
    content = string
    proxied = optional(bool, true)
    ttl     = optional(number)
  }))
  default = {}
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "v1.31.1"
}

variable "vcn_cidrs" {
  description = "VCN CIDR blocks"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "public_subnet_cidr" {
  description = "Public subnet CIDR"
  type        = string
  default     = "10.0.0.0/24"
}

variable "private_subnet_cidr" {
  description = "Private subnet CIDR"
  type        = string
  default     = "10.0.1.0/24"
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
  description = "Memory per ARM node"
  type        = number
  default     = 12
}

variable "ssh_public_key" {
  description = "SSH public key"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
