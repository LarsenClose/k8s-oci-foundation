terraform {
  required_version = ">= 1.6.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

locals {
  # Build subdomain prefix for cluster-specific records
  cluster_prefix = var.cluster_subdomain
  has_lb_ip      = var.load_balancer_ip != ""
}

# Generic A records
resource "cloudflare_record" "a_records" {
  for_each = var.a_records

  zone_id = var.zone_id
  name    = each.key
  type    = "A"
  content = each.value.ip
  ttl     = each.value.proxied ? 1 : coalesce(each.value.ttl, 300)
  proxied = each.value.proxied
}

# Generic CNAME records
resource "cloudflare_record" "cname_records" {
  for_each = var.cname_records

  zone_id = var.zone_id
  name    = each.key
  type    = "CNAME"
  content = each.value.target
  ttl     = each.value.proxied ? 1 : coalesce(each.value.ttl, 300)
  proxied = each.value.proxied
}

# Cluster wildcard record (*.cluster-subdomain.domain)
resource "cloudflare_record" "cluster_wildcard" {
  count   = local.has_lb_ip ? 1 : 0
  zone_id = var.zone_id
  name    = "*.${local.cluster_prefix}"
  type    = "A"
  content = var.load_balancer_ip
  ttl     = 1
  proxied = var.enable_proxy
}

# Custom records - flexible map for any additional DNS entries
resource "cloudflare_record" "custom_records" {
  for_each = var.custom_records

  zone_id = var.zone_id
  name    = each.value.name
  type    = each.value.type
  content = each.value.content
  ttl     = each.value.proxied ? 1 : coalesce(each.value.ttl, 300)
  proxied = each.value.proxied
}
