output "zone_id" {
  description = "Cloudflare zone ID"
  value       = local.zone_id
}

output "zone_name" {
  description = "Zone domain name"
  value       = var.domain
}

output "nameservers" {
  description = "Cloudflare nameservers (if zone was created)"
  value       = length(cloudflare_zone.main) > 0 ? cloudflare_zone.main[0].name_servers : null
}
