terraform {
  required_version = ">= 1.6.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

data "cloudflare_zones" "existing" {
  filter {
    name   = var.domain
    status = "active"
  }
}

locals {
  # Determine if zone exists or needs to be created
  zone_exists = length(data.cloudflare_zones.existing.zones) > 0

  # Only create zone if explicitly requested AND it doesn't exist
  should_create = var.create_zone && !local.zone_exists

  # Get zone ID from existing zone or newly created zone
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

resource "cloudflare_zone_settings_override" "main" {
  count   = var.configure_settings && local.zone_id != null ? 1 : 0
  zone_id = local.zone_id

  settings {
    always_use_https         = "on"
    automatic_https_rewrites = "on"
    min_tls_version          = "1.2"
    ssl                      = "full"
    universal_ssl            = "on"
  }
}
