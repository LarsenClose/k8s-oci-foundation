terraform {
  required_version = ">= 1.6.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.0.0"
    }
  }
}

# NSG for nebula lighthouse VNICs -- restricts traffic to UDP 4242 only
resource "oci_core_network_security_group" "nebula" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "nebula-lighthouse-nsg"
  freeform_tags  = var.tags
}

resource "oci_core_network_security_group_security_rule" "nebula_udp_ingress" {
  network_security_group_id = oci_core_network_security_group.nebula.id
  direction                 = "INGRESS"
  protocol                  = "17" # UDP
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  description               = "Nebula lighthouse UDP"

  udp_options {
    destination_port_range {
      min = 4242
      max = 4242
    }
  }
}

resource "oci_core_network_security_group_security_rule" "nebula_icmp_ingress" {
  network_security_group_id = oci_core_network_security_group.nebula.id
  direction                 = "INGRESS"
  protocol                  = "1" # ICMP
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  description               = "Path MTU Discovery"

  icmp_options {
    type = 3
    code = 4
  }
}

resource "oci_core_network_security_group_security_rule" "nebula_egress" {
  network_security_group_id = oci_core_network_security_group.nebula.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
  description               = "Allow all egress"
}

# Secondary VNIC attachments on the public subnet, one per worker node
resource "oci_core_vnic_attachment" "nebula" {
  count        = var.lighthouse_count
  instance_id  = var.node_instance_ids[count.index]
  display_name = "nebula-lighthouse-${count.index}"

  create_vnic_details {
    subnet_id              = var.public_subnet_id
    display_name           = "nebula-lighthouse-${count.index}"
    assign_public_ip       = false # We use reserved IPs instead
    skip_source_dest_check = true  # Required for overlay networking
    nsg_ids                = [oci_core_network_security_group.nebula.id]
    freeform_tags          = var.tags
  }
}

# Look up the secondary VNIC details to get the private IP OCID
data "oci_core_private_ips" "nebula" {
  count   = var.lighthouse_count
  vnic_id = oci_core_vnic_attachment.nebula[count.index].vnic_id
}

# Reserved public IPs assigned to the secondary VNICs
resource "oci_core_public_ip" "lighthouse" {
  count          = var.lighthouse_count
  compartment_id = var.compartment_id
  display_name   = "nebula-lighthouse-${count.index}"
  lifetime       = "RESERVED"
  private_ip_id  = data.oci_core_private_ips.nebula[count.index].private_ips[0].id

  freeform_tags = var.tags
}
