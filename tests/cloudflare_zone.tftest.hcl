# Unit tests for cloudflare-zone module
# Tests zone creation and settings configuration

mock_provider "cloudflare" {
  mock_data "cloudflare_zones" {
    defaults = {
      zones = []
    }
  }
}

variables {
  domain             = "example.com"
  account_id         = "test-account-id"
  create_zone        = true
  plan               = "free"
  configure_settings = true
}

run "validates_required_variables" {
  command = plan

  module {
    source = "./modules/cloudflare-zone"
  }

  assert {
    condition     = var.domain != ""
    error_message = "domain must be provided"
  }

  assert {
    condition     = var.account_id != ""
    error_message = "account_id must be provided"
  }
}

run "creates_zone_when_requested" {
  command = plan

  module {
    source = "./modules/cloudflare-zone"
  }

  variables {
    create_zone = true
  }

  assert {
    condition     = length(cloudflare_zone.main) == 1
    error_message = "zone should be created when create_zone is true and zone doesn't exist"
  }
}

run "skips_zone_creation_when_not_requested" {
  command = plan

  module {
    source = "./modules/cloudflare-zone"
  }

  variables {
    create_zone = false
  }

  assert {
    condition     = length(cloudflare_zone.main) == 0
    error_message = "zone should not be created when create_zone is false"
  }
}

run "configures_settings_when_enabled" {
  command = plan

  module {
    source = "./modules/cloudflare-zone"
  }

  variables {
    create_zone        = true
    configure_settings = true
  }

  assert {
    condition     = length(cloudflare_zone_settings_override.main) == 1
    error_message = "zone settings should be configured when configure_settings is true"
  }
}

run "skips_settings_when_disabled" {
  command = plan

  module {
    source = "./modules/cloudflare-zone"
  }

  variables {
    create_zone        = true
    configure_settings = false
  }

  assert {
    condition     = length(cloudflare_zone_settings_override.main) == 0
    error_message = "zone settings should not be configured when configure_settings is false"
  }
}

run "uses_correct_plan" {
  command = plan

  module {
    source = "./modules/cloudflare-zone"
  }

  variables {
    create_zone = true
    plan        = "pro"
  }

  assert {
    condition     = cloudflare_zone.main[0].plan == "pro"
    error_message = "zone should use the specified plan"
  }
}
