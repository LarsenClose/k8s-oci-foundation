variable "compartment_id" {
  description = "OCI compartment OCID"
  type        = string
}

variable "vcn_id" {
  description = "VCN OCID"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet OCID for secondary VNICs"
  type        = string
}

variable "lighthouse_count" {
  description = "Number of nebula lighthouses (must match number of node_instance_ids)"
  type        = number
  default     = 2
}

variable "node_instance_ids" {
  description = "List of OKE worker node instance OCIDs"
  type        = list(string)
}

variable "tags" {
  description = "Freeform tags"
  type        = map(string)
  default     = {}
}
