# Cloudflare Records Module

Manages DNS records within a Cloudflare zone. Supports A records, CNAME records, cluster wildcard records for ingress routing, and arbitrary custom records for application-specific needs.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| opentofu | >= 1.6.0 |
| cloudflare | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| cloudflare | ~> 4.0 |

## Resources

| Name | Type |
|------|------|
| [cloudflare_record.a_records](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.cname_records](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.cluster_wildcard](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.custom_records](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| zone\_id | Cloudflare zone ID | `string` | n/a | yes |
| domain | Domain name for constructing FQDNs | `string` | n/a | yes |
| cluster\_subdomain | Environment-specific subdomain (e.g., 'dev', 'staging', 'prod') | `string` | n/a | yes |
| a\_records | Map of A records to create | <pre>map(object({<br>  ip      = string<br>  proxied = optional(bool, true)<br>  ttl     = optional(number)<br>}))</pre> | `{}` | no |
| cname\_records | Map of CNAME records to create | <pre>map(object({<br>  target  = string<br>  proxied = optional(bool, true)<br>  ttl     = optional(number)<br>}))</pre> | `{}` | no |
| custom\_records | Map of custom DNS records for application-specific needs | <pre>map(object({<br>  name    = string<br>  type    = string<br>  content = string<br>  proxied = optional(bool, true)<br>  ttl     = optional(number)<br>}))</pre> | `{}` | no |
| load\_balancer\_ip | Load balancer IP for wildcard and service records | `string` | `""` | no |
| enable\_proxy | Enable Cloudflare proxy for records | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| a\_record\_hostnames | Created A record hostnames |
| cname\_record\_hostnames | Created CNAME record hostnames |
| cluster\_wildcard\_hostname | Cluster wildcard hostname |
| custom\_record\_hostnames | Created custom record hostnames |
<!-- END_TF_DOCS -->
