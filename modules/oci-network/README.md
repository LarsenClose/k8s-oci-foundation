# OCI Network Module

Provisions a Virtual Cloud Network (VCN) on Oracle Cloud Infrastructure with public and private subnets, security lists, and gateways for Kubernetes workloads.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| opentofu | >= 1.6.0 |
| oci | >= 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| oci | >= 5.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| vcn | oracle-terraform-modules/vcn/oci | 3.6.0 |

## Resources

| Name | Type |
|------|------|
| [oci_core_subnet.public](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_subnet) | resource |
| [oci_core_subnet.private](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_subnet) | resource |
| [oci_core_security_list.public](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_security_list) | resource |
| [oci_core_security_list.private](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_security_list) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| compartment\_id | OCI compartment OCID | `string` | n/a | yes |
| region | OCI region | `string` | n/a | yes |
| vcn\_name | VCN display name | `string` | `"k8s-vcn"` | no |
| vcn\_dns\_label | VCN DNS label | `string` | `"k8svcn"` | no |
| vcn\_cidrs | VCN CIDR blocks | `list(string)` | `["10.0.0.0/16"]` | no |
| public\_subnet\_cidr | Public subnet CIDR | `string` | `"10.0.0.0/24"` | no |
| private\_subnet\_cidr | Private subnet CIDR | `string` | `"10.0.1.0/24"` | no |
| tags | Freeform tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| vcn\_id | VCN OCID |
| public\_subnet\_id | Public subnet OCID |
| private\_subnet\_id | Private subnet OCID |
| nat\_gateway\_id | NAT gateway OCID |
| internet\_gateway\_id | Internet gateway OCID |
| vcn\_cidrs | VCN CIDR blocks |
<!-- END_TF_DOCS -->
