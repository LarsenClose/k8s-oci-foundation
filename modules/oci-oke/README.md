# OCI OKE Module

Provisions an Oracle Kubernetes Engine (OKE) cluster with ARM-based (VM.Standard.A1.Flex) node pools, optimized for OCI Always Free tier resources.

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
| [oci_containerengine_cluster.main](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/containerengine_cluster) | resource |
| [oci_containerengine_node_pool.arm](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/containerengine_node_pool) | resource |
| [oci_containerengine_cluster_kube_config.main](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/containerengine_cluster_kube_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| compartment\_id | OCI compartment OCID | `string` | n/a | yes |
| vcn\_id | VCN OCID | `string` | n/a | yes |
| public\_subnet\_id | Public subnet OCID for API endpoint | `string` | n/a | yes |
| private\_subnet\_id | Private subnet OCID for worker nodes | `string` | n/a | yes |
| availability\_domains | List of availability domains | `list(string)` | n/a | yes |
| arm\_image\_id | ARM node image OCID | `string` | n/a | yes |
| cluster\_name | OKE cluster name | `string` | `"k8s-cluster"` | no |
| kubernetes\_version | Kubernetes version | `string` | `"v1.31.1"` | no |
| public\_endpoint | Enable public API endpoint | `bool` | `true` | no |
| pods\_cidr | CIDR for pod network | `string` | `"10.244.0.0/16"` | no |
| services\_cidr | CIDR for service network | `string` | `"10.96.0.0/16"` | no |
| arm\_node\_pool\_count | Number of ARM node pools | `number` | `2` | no |
| arm\_node\_pool\_size | Nodes per ARM pool | `number` | `1` | no |
| arm\_ocpus | OCPUs per ARM node | `number` | `2` | no |
| arm\_memory\_gbs | Memory (GB) per ARM node | `number` | `12` | no |
| ssh\_public\_key | SSH public key for nodes | `string` | `""` | no |
| tags | Freeform tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster\_id | OKE cluster OCID |
| cluster\_name | OKE cluster name |
| kubeconfig | Kubeconfig content |
| kubernetes\_version | Kubernetes version |
| node\_pool\_ids | Node pool OCIDs |
| api\_endpoint | Kubernetes API endpoint |
<!-- END_TF_DOCS -->
