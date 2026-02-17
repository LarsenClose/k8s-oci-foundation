# Unit tests for cloudflare-records module
# Tests DNS record configuration

mock_provider "cloudflare" {}

variables {
  zone_id           = "test-zone-id"
  domain            = "example.com"
  cluster_subdomain = "dev"
  load_balancer_ip  = ""
}

run "validates_required_variables" {
  command = plan

  module {
    source = "./modules/cloudflare-records"
  }

  assert {
    condition     = var.zone_id != ""
    error_message = "zone_id must be provided"
  }

  assert {
    condition     = var.domain != ""
    error_message = "domain must be provided"
  }

  assert {
    condition     = var.cluster_subdomain != ""
    error_message = "cluster_subdomain must be provided"
  }
}

run "no_records_without_load_balancer_ip" {
  command = plan

  module {
    source = "./modules/cloudflare-records"
  }

  variables {
    load_balancer_ip = ""
  }

  assert {
    condition     = length(cloudflare_record.cluster_wildcard) == 0
    error_message = "cluster_wildcard should not be created without load_balancer_ip"
  }
}

run "creates_wildcard_record_with_load_balancer_ip" {
  command = plan

  module {
    source = "./modules/cloudflare-records"
  }

  variables {
    load_balancer_ip = "10.0.1.100"
  }

  assert {
    condition     = length(cloudflare_record.cluster_wildcard) == 1
    error_message = "cluster_wildcard should be created with load_balancer_ip"
  }
}

run "custom_a_records_created" {
  command = plan

  module {
    source = "./modules/cloudflare-records"
  }

  variables {
    a_records = {
      "api" = {
        ip      = "10.0.1.50"
        proxied = true
      }
    }
  }

  assert {
    condition     = length(cloudflare_record.a_records) == 1
    error_message = "custom A records should be created"
  }
}

run "custom_cname_records_created" {
  command = plan

  module {
    source = "./modules/cloudflare-records"
  }

  variables {
    cname_records = {
      "www" = {
        target  = "example.com"
        proxied = true
      }
    }
  }

  assert {
    condition     = length(cloudflare_record.cname_records) == 1
    error_message = "custom CNAME records should be created"
  }
}

run "custom_records_map_creates_records" {
  command = plan

  module {
    source = "./modules/cloudflare-records"
  }

  variables {
    custom_records = {
      "app-endpoint" = {
        name    = "app.dev"
        type    = "A"
        content = "10.0.1.200"
        proxied = true
      }
      "txt-verification" = {
        name    = "_verify.dev"
        type    = "TXT"
        content = "verify-token-123"
        proxied = false
        ttl     = 3600
      }
    }
  }

  assert {
    condition     = length(cloudflare_record.custom_records) == 2
    error_message = "custom_records should create specified records"
  }
}
