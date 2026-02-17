output "vcn_id" {
  description = "VCN OCID"
  value       = module.vcn.vcn_id
}

output "public_subnet_id" {
  description = "Public subnet OCID"
  value       = oci_core_subnet.public.id
}

output "private_subnet_id" {
  description = "Private subnet OCID"
  value       = oci_core_subnet.private.id
}

output "nat_gateway_id" {
  description = "NAT gateway OCID"
  value       = module.vcn.nat_gateway_id
}

output "internet_gateway_id" {
  description = "Internet gateway OCID"
  value       = module.vcn.internet_gateway_id
}

output "vcn_cidrs" {
  description = "VCN CIDR blocks"
  value       = var.vcn_cidrs
}
