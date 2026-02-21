terraform {
  required_version = ">= 1.6.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

# Data source to check if zone already exists
data "cloudflare_zones" "existing" {
  filter {
    name   = var.domain
    status = "active"
  }
}

locals {
  zone_exists   = length(data.cloudflare_zones.existing.zones) > 0
  should_create = var.create_zone && !local.zone_exists
  zone_id = local.zone_exists ? data.cloudflare_zones.existing.zones[0].id : (
    local.should_create ? cloudflare_zone.main[0].id : null
  )
}

resource "cloudflare_zone" "main" {
  count      = local.should_create ? 1 : 0
  account_id = var.account_id
  zone       = var.domain
  plan       = var.plan
  type       = "full"
}
