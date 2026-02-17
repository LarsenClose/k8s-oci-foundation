variable "compartment_id" {
  description = "OCI compartment OCID"
  type        = string
}

variable "region" {
  description = "OCI region"
  type        = string
}

variable "vcn_name" {
  description = "VCN display name"
  type        = string
  default     = "k8s-vcn"
}

variable "vcn_dns_label" {
  description = "VCN DNS label"
  type        = string
  default     = "k8svcn"
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

variable "tags" {
  description = "Freeform tags"
  type        = map(string)
  default     = {}
}
