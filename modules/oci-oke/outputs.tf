output "cluster_id" {
  description = "OKE cluster OCID"
  value       = oci_containerengine_cluster.main.id
}

output "cluster_name" {
  description = "OKE cluster name"
  value       = oci_containerengine_cluster.main.name
}

output "kubeconfig" {
  description = "Kubeconfig content"
  value       = data.oci_containerengine_cluster_kube_config.main.content
  sensitive   = true
}

output "kubernetes_version" {
  description = "Kubernetes version"
  value       = oci_containerengine_cluster.main.kubernetes_version
}

output "node_pool_ids" {
  description = "Node pool OCIDs"
  value       = oci_containerengine_node_pool.arm[*].id
}

output "api_endpoint" {
  description = "Kubernetes API endpoint"
  value       = length(oci_containerengine_cluster.main.endpoints) > 0 ? oci_containerengine_cluster.main.endpoints[0].kubernetes : null
}
