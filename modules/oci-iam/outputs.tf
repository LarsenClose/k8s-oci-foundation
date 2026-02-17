output "nodes_dynamic_group_id" {
  description = "Dynamic group OCID for worker nodes"
  value       = oci_identity_dynamic_group.k8s_nodes.id
}

output "nodes_dynamic_group_name" {
  description = "Dynamic group name for worker nodes"
  value       = oci_identity_dynamic_group.k8s_nodes.name
}

output "cluster_dynamic_group_id" {
  description = "Dynamic group OCID for cluster"
  value       = oci_identity_dynamic_group.k8s_cluster.id
}

output "volume_policy_id" {
  description = "Volume policy OCID"
  value       = oci_identity_policy.k8s_volume_policy.id
}

output "metrics_policy_id" {
  description = "Metrics policy OCID"
  value       = oci_identity_policy.k8s_metrics_policy.id
}
