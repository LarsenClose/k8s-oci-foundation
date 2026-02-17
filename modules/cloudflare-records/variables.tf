variable "zone_id" {
  description = "Cloudflare zone ID"
  type        = string
}

variable "cluster_subdomain" {
  description = "Environment-specific subdomain (e.g., 'dev', 'staging', 'prod')"
  type        = string
}

variable "a_records" {
  description = "Map of A records to create"
  type = map(object({
    ip      = string
    proxied = optional(bool, true)
    ttl     = optional(number)
  }))
  default = {}
}

variable "cname_records" {
  description = "Map of CNAME records to create"
  type = map(object({
    target  = string
    proxied = optional(bool, true)
    ttl     = optional(number)
  }))
  default = {}
}

variable "custom_records" {
  description = "Map of custom DNS records for application-specific needs"
  type = map(object({
    name    = string
    type    = string # A, AAAA, CNAME, TXT, etc.
    content = string
    proxied = optional(bool, true)
    ttl     = optional(number)
  }))
  default = {}
}

variable "load_balancer_ip" {
  description = "Load balancer IP for wildcard and service records"
  type        = string
  default     = ""
}

variable "enable_proxy" {
  description = "Enable Cloudflare proxy for records"
  type        = bool
  default     = true
}
