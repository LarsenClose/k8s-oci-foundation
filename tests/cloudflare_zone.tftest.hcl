# Unit tests for cloudflare-zone module
# Tests zone creation and lookup logic

mock_provider "cloudflare" {
  mock_data "cloudflare_zones" {
    defaults = {
      zones = []
    }
  }
}

variables {
  domain      = "example.com"
  account_id  = "test-account-id"
  create_zone = true
  plan        = "free"
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

run "zone_uses_full_type" {
  command = plan

  module {
    source = "./modules/cloudflare-zone"
  }

  variables {
    create_zone = true
  }

  assert {
    condition     = cloudflare_zone.main[0].type == "full"
    error_message = "zone should use type full"
  }
}

run "zone_account_id_set" {
  command = plan

  module {
    source = "./modules/cloudflare-zone"
  }

  variables {
    create_zone = true
  }

  assert {
    condition     = cloudflare_zone.main[0].account_id == var.account_id
    error_message = "zone account_id should match input variable"
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
