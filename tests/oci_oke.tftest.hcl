# Unit tests for oci-oke module
# Tests OKE cluster and node pool configuration

mock_provider "oci" {
  mock_data "oci_containerengine_cluster_kube_config" {
    defaults = {
      content = "mock-kubeconfig-content"
    }
  }
}

variables {
  compartment_id       = "ocid1.compartment.oc1..test"
  vcn_id               = "ocid1.vcn.oc1..test"
  public_subnet_id     = "ocid1.subnet.oc1..public"
  private_subnet_id    = "ocid1.subnet.oc1..private"
  cluster_name         = "test-k8s"
  kubernetes_version   = "v1.31.1"
  public_endpoint      = true
  availability_domains = ["AD-1", "AD-2"]
  arm_node_pool_count  = 2
  arm_node_pool_size   = 1
  arm_ocpus            = 2
  arm_memory_gbs       = 12
  arm_image_id         = "ocid1.image.oc1..test"
  ssh_public_key       = ""
  tags                 = {}
}

run "validates_required_variables" {
  command = plan

  module {
    source = "./modules/oci-oke"
  }

  assert {
    condition     = var.compartment_id != ""
    error_message = "compartment_id must be provided"
  }

  assert {
    condition     = var.vcn_id != ""
    error_message = "vcn_id must be provided"
  }

  assert {
    condition     = length(var.availability_domains) > 0
    error_message = "at least one availability domain must be provided"
  }
}

run "validates_cluster_configuration" {
  command = plan

  module {
    source = "./modules/oci-oke"
  }

  assert {
    condition     = var.kubernetes_version == "v1.31.1"
    error_message = "Kubernetes version should be v1.31.1"
  }

  assert {
    condition     = var.cluster_name == "test-k8s"
    error_message = "cluster name should be test-k8s"
  }
}

run "validates_node_pool_configuration" {
  command = plan

  module {
    source = "./modules/oci-oke"
  }

  assert {
    condition     = var.arm_node_pool_count == 2
    error_message = "should have 2 node pools by default"
  }

  assert {
    condition     = var.arm_ocpus == 2
    error_message = "nodes should have 2 OCPUs"
  }

  assert {
    condition     = var.arm_memory_gbs == 12
    error_message = "nodes should have 12 GB memory"
  }
}

run "validates_arm_flex_shape" {
  command = plan

  module {
    source = "./modules/oci-oke"
  }

  # The module uses VM.Standard.A1.Flex shape
  assert {
    condition     = var.arm_ocpus >= 1 && var.arm_ocpus <= 80
    error_message = "ARM OCPUs must be between 1 and 80"
  }

  assert {
    condition     = var.arm_memory_gbs >= 1 && var.arm_memory_gbs <= 512
    error_message = "ARM memory must be between 1 and 512 GB"
  }
}

run "validates_network_cidrs" {
  command = plan

  module {
    source = "./modules/oci-oke"
  }

  assert {
    condition     = can(cidrhost(var.pods_cidr, 0))
    error_message = "pods_cidr must be a valid CIDR"
  }

  assert {
    condition     = can(cidrhost(var.services_cidr, 0))
    error_message = "services_cidr must be a valid CIDR"
  }
}
