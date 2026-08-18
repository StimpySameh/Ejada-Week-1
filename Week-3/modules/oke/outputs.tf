# ──────────────────────────────────────────────
# OKE Module – Outputs
# ──────────────────────────────────────────────

output "cluster_id" {
  description = "OCID of the OKE cluster"
  value       = oci_containerengine_cluster.this.id
}

output "cluster_name" {
  description = "Name of the OKE cluster"
  value       = oci_containerengine_cluster.this.name
}

output "cluster_kubernetes_version" {
  description = "Kubernetes version of the cluster"
  value       = oci_containerengine_cluster.this.kubernetes_version
}

output "cluster_endpoints" {
  description = "OKE cluster endpoint details"
  value       = oci_containerengine_cluster.this.endpoints
}

output "node_pool_id" {
  description = "OCID of the managed node pool (empty if not created)"
  value       = var.create_node_pool ? oci_containerengine_node_pool.this[0].id : ""
}

output "node_pool_name" {
  description = "Name of the node pool"
  value       = var.create_node_pool ? oci_containerengine_node_pool.this[0].name : ""
}
