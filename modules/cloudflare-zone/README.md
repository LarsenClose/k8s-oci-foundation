# Cloudflare Zone Module

Manages a Cloudflare DNS zone with automatic detection of existing zones. Creates a new zone only when explicitly requested and one does not already exist. Configures SSL/TLS and security settings.

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
| [cloudflare_zone.main](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/zone) | resource |
| [cloudflare_zone_settings_override.main](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/zone_settings_override) | resource |
| [cloudflare_zones.existing](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/data-sources/zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| domain | Domain name to manage | `string` | n/a | yes |
| account\_id | Cloudflare account ID | `string` | n/a | yes |
| create\_zone | Whether to create a new zone (true) or use an existing one (false) | `bool` | `false` | no |
| plan | Cloudflare plan (free, pro, business, enterprise) | `string` | `"free"` | no |

## Outputs

| Name | Description |
|------|-------------|
| zone\_id | Cloudflare zone ID |
| zone\_name | Zone domain name |
| nameservers | Cloudflare nameservers (if zone was created) |
<!-- END_TF_DOCS -->
