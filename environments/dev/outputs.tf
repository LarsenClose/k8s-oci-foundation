output "cluster_id" {
  description = "OKE cluster OCID"
  value       = module.oke.cluster_id
}

output "cluster_name" {
  description = "Cluster name"
  value       = module.oke.cluster_name
}

output "api_endpoint" {
  description = "Kubernetes API endpoint"
  value       = module.oke.api_endpoint
}

output "vcn_id" {
  description = "VCN OCID"
  value       = module.network.vcn_id
}

output "kubeconfig_path" {
  description = "Path to kubeconfig"
  value       = local_file.kubeconfig.filename
}

# IAM outputs
output "cluster_dynamic_group_id" {
  description = "OKE cluster dynamic group OCID"
  value       = module.iam.cluster_dynamic_group_id
}

output "nodes_dynamic_group_id" {
  description = "OKE nodes dynamic group OCID"
  value       = module.iam.nodes_dynamic_group_id
}

# Cloudflare outputs
output "cloudflare_zone_id" {
  description = "Cloudflare zone ID"
  value       = module.cloudflare_zone.zone_id
}

output "cluster_domain" {
  description = "Cluster subdomain FQDN"
  value       = "${var.environment}.${var.cloudflare_domain}"
}

output "wildcard_domain" {
  description = "Wildcard domain for cluster services"
  value       = "*.${var.environment}.${var.cloudflare_domain}"
}
