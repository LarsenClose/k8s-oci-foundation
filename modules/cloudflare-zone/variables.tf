variable "domain" {
  description = "Domain name to manage"
  type        = string
}

variable "account_id" {
  description = "Cloudflare account ID"
  type        = string
}

variable "create_zone" {
  description = "Whether to create a new zone (true) or use an existing one (false)"
  type        = bool
  default     = false
}

variable "plan" {
  description = "Cloudflare plan (free, pro, business, enterprise)"
  type        = string
  default     = "free"
}

