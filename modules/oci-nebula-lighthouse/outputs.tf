output "lighthouse_public_ips" {
  description = "Reserved public IPs for nebula lighthouses"
  value       = oci_core_public_ip.lighthouse[*].ip_address
}

output "lighthouse_private_ips" {
  description = "Private IPs of nebula lighthouse secondary VNICs"
  value = [
    for i in range(var.lighthouse_count) :
    data.oci_core_private_ips.nebula[i].private_ips[0].ip_address
  ]
}

output "lighthouse_public_ip_ids" {
  description = "OCIDs of reserved public IPs"
  value       = oci_core_public_ip.lighthouse[*].id
}

output "nebula_nsg_id" {
  description = "Network security group OCID for nebula lighthouse VNICs"
  value       = oci_core_network_security_group.nebula.id
}
