terraform {
  required_version = ">= 1.6.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.0.0"
    }
  }
}

resource "oci_containerengine_cluster" "main" {
  compartment_id     = var.compartment_id
  kubernetes_version = var.kubernetes_version
  name               = var.cluster_name
  vcn_id             = var.vcn_id

  endpoint_config {
    is_public_ip_enabled = var.public_endpoint
    subnet_id            = var.public_subnet_id
  }

  options {
    add_ons {
      is_kubernetes_dashboard_enabled = false
      is_tiller_enabled               = false
    }
    kubernetes_network_config {
      pods_cidr     = var.pods_cidr
      services_cidr = var.services_cidr
    }
    service_lb_subnet_ids = [var.public_subnet_id]
  }

  freeform_tags = var.tags
}

resource "oci_containerengine_node_pool" "arm" {
  count = var.arm_node_pool_count

  cluster_id         = oci_containerengine_cluster.main.id
  compartment_id     = var.compartment_id
  kubernetes_version = var.kubernetes_version
  name               = "${var.cluster_name}-arm-pool-${count.index}"

  node_config_details {
    placement_configs {
      availability_domain = var.availability_domains[count.index % length(var.availability_domains)]
      subnet_id           = var.private_subnet_id
    }
    size          = var.arm_node_pool_size
    freeform_tags = merge(var.tags, { "pool-type" = "arm" })
  }

  node_shape = "VM.Standard.A1.Flex"

  node_shape_config {
    memory_in_gbs = var.arm_memory_gbs
    ocpus         = var.arm_ocpus
  }

  node_source_details {
    image_id    = var.arm_image_id
    source_type = "image"
  }

  initial_node_labels {
    key   = "node-pool"
    value = "arm-${count.index}"
  }

  ssh_public_key = var.ssh_public_key

  lifecycle {
    ignore_changes = [kubernetes_version]
  }
}

data "oci_containerengine_cluster_kube_config" "main" {
  cluster_id = oci_containerengine_cluster.main.id
}
