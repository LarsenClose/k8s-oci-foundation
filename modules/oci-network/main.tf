terraform {
  required_version = ">= 1.6.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.0.0"
    }
  }
}

module "vcn" {
  source  = "oracle-terraform-modules/vcn/oci"
  version = "3.6.0"

  compartment_id = var.compartment_id
  region         = var.region

  vcn_name      = var.vcn_name
  vcn_dns_label = var.vcn_dns_label
  vcn_cidrs     = var.vcn_cidrs

  create_internet_gateway = true
  create_nat_gateway      = true
  create_service_gateway  = true

  freeform_tags = var.tags
}

resource "oci_core_subnet" "public" {
  compartment_id    = var.compartment_id
  vcn_id            = module.vcn.vcn_id
  cidr_block        = var.public_subnet_cidr
  display_name      = "${var.vcn_name}-public"
  dns_label         = "public"
  security_list_ids = [oci_core_security_list.public.id]
  route_table_id    = module.vcn.ig_route_id

  freeform_tags = var.tags
}

resource "oci_core_subnet" "private" {
  compartment_id             = var.compartment_id
  vcn_id                     = module.vcn.vcn_id
  cidr_block                 = var.private_subnet_cidr
  display_name               = "${var.vcn_name}-private"
  dns_label                  = "private"
  prohibit_public_ip_on_vnic = true
  security_list_ids          = [oci_core_security_list.private.id]
  route_table_id             = module.vcn.nat_route_id

  freeform_tags = var.tags
}

resource "oci_core_security_list" "public" {
  compartment_id = var.compartment_id
  vcn_id         = module.vcn.vcn_id
  display_name   = "${var.vcn_name}-public-sl"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 443
      max = 443
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 6443
      max = 6443
    }
    description = "Kubernetes API"
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.vcn_cidrs[0]
    tcp_options {
      min = 10250
      max = 10250
    }
    description = "Kubelet API"
  }

  freeform_tags = var.tags
}

resource "oci_core_security_list" "private" {
  compartment_id = var.compartment_id
  vcn_id         = module.vcn.vcn_id
  display_name   = "${var.vcn_name}-private-sl"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  ingress_security_rules {
    protocol = "all"
    source   = var.vcn_cidrs[0]
  }

  freeform_tags = var.tags
}
