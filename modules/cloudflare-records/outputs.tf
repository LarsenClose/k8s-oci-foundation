output "a_record_hostnames" {
  description = "Created A record hostnames"
  value       = { for k, v in cloudflare_record.a_records : k => v.hostname }
}

output "cname_record_hostnames" {
  description = "Created CNAME record hostnames"
  value       = { for k, v in cloudflare_record.cname_records : k => v.hostname }
}

output "cluster_wildcard_hostname" {
  description = "Cluster wildcard hostname"
  value       = length(cloudflare_record.cluster_wildcard) > 0 ? cloudflare_record.cluster_wildcard[0].hostname : null
}

output "custom_record_hostnames" {
  description = "Created custom record hostnames"
  value       = { for k, v in cloudflare_record.custom_records : k => v.hostname }
}
