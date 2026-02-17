# Unit tests for oci-iam module
# Tests IAM dynamic groups and policies for OKE

mock_provider "oci" {}

variables {
  tenancy_ocid     = "ocid1.tenancy.oc1..test"
  compartment_id   = "ocid1.compartment.oc1..test"
  cluster_name     = "test-k8s"
  enable_lb_policy = true
  tags             = {}
}

run "validates_required_variables" {
  command = plan

  module {
    source = "./modules/oci-iam"
  }

  assert {
    condition     = var.tenancy_ocid != ""
    error_message = "tenancy_ocid must be provided"
  }

  assert {
    condition     = var.compartment_id != ""
    error_message = "compartment_id must be provided"
  }

  assert {
    condition     = var.cluster_name != ""
    error_message = "cluster_name must be provided"
  }
}

run "creates_node_dynamic_group" {
  command = plan

  module {
    source = "./modules/oci-iam"
  }

  assert {
    condition     = oci_identity_dynamic_group.k8s_nodes.name == "test-k8s-nodes"
    error_message = "node dynamic group should have correct name"
  }

  assert {
    condition     = can(regex("instance.compartment.id", oci_identity_dynamic_group.k8s_nodes.matching_rule))
    error_message = "node dynamic group should match instances in compartment"
  }
}

run "creates_cluster_dynamic_group" {
  command = plan

  module {
    source = "./modules/oci-iam"
  }

  assert {
    condition     = oci_identity_dynamic_group.k8s_cluster.name == "test-k8s-cluster"
    error_message = "cluster dynamic group should have correct name"
  }

  assert {
    condition     = can(regex("resource.type = 'cluster'", oci_identity_dynamic_group.k8s_cluster.matching_rule))
    error_message = "cluster dynamic group should match cluster resources"
  }
}

run "creates_volume_policy" {
  command = plan

  module {
    source = "./modules/oci-iam"
  }

  assert {
    condition     = oci_identity_policy.k8s_volume_policy.name == "test-k8s-volume-policy"
    error_message = "volume policy should have correct name"
  }

  assert {
    condition     = length(oci_identity_policy.k8s_volume_policy.statements) == 3
    error_message = "volume policy should have 3 statements"
  }
}

run "creates_lb_policy_when_enabled" {
  command = plan

  module {
    source = "./modules/oci-iam"
  }

  variables {
    enable_lb_policy = true
  }

  assert {
    condition     = length(oci_identity_policy.k8s_lb_policy) == 1
    error_message = "load balancer policy should be created when enabled"
  }
}

run "skips_lb_policy_when_disabled" {
  command = plan

  module {
    source = "./modules/oci-iam"
  }

  variables {
    enable_lb_policy = false
  }

  assert {
    condition     = length(oci_identity_policy.k8s_lb_policy) == 0
    error_message = "load balancer policy should not be created when disabled"
  }
}

run "applies_tags_to_resources" {
  command = plan

  module {
    source = "./modules/oci-iam"
  }

  variables {
    tags = {
      environment = "test"
      team        = "platform"
    }
  }

  assert {
    condition     = oci_identity_dynamic_group.k8s_nodes.freeform_tags["environment"] == "test"
    error_message = "dynamic groups should have the specified tags"
  }

  assert {
    condition     = oci_identity_policy.k8s_volume_policy.freeform_tags["team"] == "platform"
    error_message = "policies should have the specified tags"
  }
}
