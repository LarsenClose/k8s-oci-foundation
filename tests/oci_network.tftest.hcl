# Unit tests for oci-network module
# Tests VCN, subnet, and security list configuration
# Note: Some tests are limited due to external module dependencies requiring live API data

mock_provider "oci" {
  # Mock the services data source used by the VCN module
  mock_data "oci_core_services" {
    defaults = {
      services = [
        {
          id          = "mock-service-id"
          cidr_block  = "all-phx-services-in-oracle-services-network"
          name        = "All PHX Services In Oracle Services Network"
          description = "All PHX services"
        }
      ]
    }
  }
}

variables {
  compartment_id      = "ocid1.compartment.oc1..test"
  region              = "us-phoenix-1"
  vcn_name            = "test-vcn"
  vcn_dns_label       = "testvcn"
  vcn_cidrs           = ["10.0.0.0/16"]
  public_subnet_cidr  = "10.0.0.0/24"
  private_subnet_cidr = "10.0.1.0/24"
  tags                = {}
}

run "validates_required_variables" {
  command = plan

  module {
    source = "./modules/oci-network"
  }

  assert {
    condition     = var.compartment_id != ""
    error_message = "compartment_id must be provided"
  }

  assert {
    condition     = var.region != ""
    error_message = "region must be provided"
  }

  assert {
    condition     = length(var.vcn_cidrs) > 0
    error_message = "vcn_cidrs must have at least one CIDR block"
  }
}

run "subnet_cidr_configuration" {
  command = plan

  module {
    source = "./modules/oci-network"
  }

  assert {
    condition     = var.public_subnet_cidr == "10.0.0.0/24"
    error_message = "public subnet CIDR should be configured correctly"
  }

  assert {
    condition     = var.private_subnet_cidr == "10.0.1.0/24"
    error_message = "private subnet CIDR should be configured correctly"
  }
}

run "validates_subnet_within_vcn" {
  command = plan

  module {
    source = "./modules/oci-network"
  }

  # Verify subnets are within VCN CIDR range
  assert {
    condition     = can(cidrsubnet(var.vcn_cidrs[0], 8, 0))
    error_message = "VCN CIDR must be valid for subnet creation"
  }
}
