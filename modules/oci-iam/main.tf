terraform {
  required_version = ">= 1.6.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.0.0"
    }
  }
}

resource "oci_identity_dynamic_group" "k8s_nodes" {
  compartment_id = var.tenancy_ocid
  name           = "${var.cluster_name}-nodes"
  description    = "Dynamic group for ${var.cluster_name} OKE worker nodes"
  matching_rule  = "ALL {instance.compartment.id = '${var.compartment_id}'}"
  freeform_tags  = var.tags
}

resource "oci_identity_dynamic_group" "k8s_cluster" {
  compartment_id = var.tenancy_ocid
  name           = "${var.cluster_name}-cluster"
  description    = "Dynamic group for ${var.cluster_name} OKE cluster"
  matching_rule  = "ALL {resource.type = 'cluster', resource.compartment.id = '${var.compartment_id}'}"
  freeform_tags  = var.tags
}

resource "oci_identity_policy" "k8s_volume_policy" {
  compartment_id = var.compartment_id
  name           = "${var.cluster_name}-volume-policy"
  description    = "Allow ${var.cluster_name} nodes to manage volumes"
  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.k8s_nodes.name} to use instance-family in compartment id ${var.compartment_id}",
    "Allow dynamic-group ${oci_identity_dynamic_group.k8s_nodes.name} to use volumes in compartment id ${var.compartment_id}",
    "Allow dynamic-group ${oci_identity_dynamic_group.k8s_nodes.name} to manage volume-attachments in compartment id ${var.compartment_id}"
  ]
  freeform_tags = var.tags
}

resource "oci_identity_policy" "k8s_metrics_policy" {
  compartment_id = var.compartment_id
  name           = "${var.cluster_name}-metrics-policy"
  description    = "Allow ${var.cluster_name} nodes to read metrics"
  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.k8s_nodes.name} to read metrics in compartment id ${var.compartment_id}",
    "Allow dynamic-group ${oci_identity_dynamic_group.k8s_nodes.name} to read compartments in compartment id ${var.compartment_id}"
  ]
  freeform_tags = var.tags
}

resource "oci_identity_policy" "k8s_lb_policy" {
  count          = var.enable_lb_policy ? 1 : 0
  compartment_id = var.compartment_id
  name           = "${var.cluster_name}-lb-policy"
  description    = "Allow ${var.cluster_name} to manage load balancers"
  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.k8s_cluster.name} to manage load-balancers in compartment id ${var.compartment_id}",
    "Allow dynamic-group ${oci_identity_dynamic_group.k8s_cluster.name} to use virtual-network-family in compartment id ${var.compartment_id}",
    "Allow dynamic-group ${oci_identity_dynamic_group.k8s_cluster.name} to read public-ips in compartment id ${var.compartment_id}"
  ]
  freeform_tags = var.tags
}
