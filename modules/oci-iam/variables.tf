variable "tenancy_ocid" {
  description = "Tenancy OCID (required for dynamic groups)"
  type        = string
}

variable "compartment_id" {
  description = "Compartment OCID for policies"
  type        = string
}

variable "cluster_name" {
  description = "Cluster name prefix for resources"
  type        = string
}

variable "cluster_ocid" {
  description = "OKE cluster OCID for IAM policies"
  type        = string
  default     = ""
}

variable "enable_lb_policy" {
  description = "Enable load balancer management policy"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Freeform tags"
  type        = map(string)
  default     = {}
}
