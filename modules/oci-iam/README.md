# OCI IAM Module

Configures OCI Identity and Access Management resources for Kubernetes cluster operations, including dynamic groups for worker nodes and cluster resources, and least-privilege policies for volume management, metrics, and load balancers.

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

## Resources

| Name | Type |
|------|------|
| [oci_identity_dynamic_group.k8s_nodes](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_dynamic_group) | resource |
| [oci_identity_dynamic_group.k8s_cluster](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_dynamic_group) | resource |
| [oci_identity_policy.k8s_volume_policy](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_policy) | resource |
| [oci_identity_policy.k8s_metrics_policy](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_policy) | resource |
| [oci_identity_policy.k8s_lb_policy](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| tenancy\_ocid | Tenancy OCID (required for dynamic groups) | `string` | n/a | yes |
| compartment\_id | Compartment OCID for policies | `string` | n/a | yes |
| cluster\_name | Cluster name prefix for resources | `string` | n/a | yes |
| cluster\_ocid | OKE cluster OCID for IAM policies | `string` | `""` | no |
| enable\_lb\_policy | Enable load balancer management policy | `bool` | `true` | no |
| tags | Freeform tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| nodes\_dynamic\_group\_id | Dynamic group OCID for worker nodes |
| nodes\_dynamic\_group\_name | Dynamic group name for worker nodes |
| cluster\_dynamic\_group\_id | Dynamic group OCID for cluster |
| volume\_policy\_id | Volume policy OCID |
| metrics\_policy\_id | Metrics policy OCID |
<!-- END_TF_DOCS -->
