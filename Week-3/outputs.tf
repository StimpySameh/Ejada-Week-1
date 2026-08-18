# ──────────────────────────────────────────────
# Networking Outputs
# ──────────────────────────────────────────────

output "vcn_id" {
  description = "OCID of the VCN"
  value       = oci_core_vcn.this.id
}

output "api_endpoint_subnet_id" {
  description = "OCID of the API endpoint subnet"
  value       = module.api_endpoint_subnet.subnet_id
}

output "service_lb_subnet_id" {
  description = "OCID of the service LB subnet"
  value       = module.service_lb_subnet.subnet_id
}

output "worker_subnet_id" {
  description = "OCID of the worker nodes subnet"
  value       = module.worker_subnet.subnet_id
}

output "pod_subnet_id" {
  description = "OCID of the pod subnet"
  value       = module.pod_subnet.subnet_id
}

# ──────────────────────────────────────────────
# OKE Cluster Outputs
# ──────────────────────────────────────────────

output "oke_cluster_id" {
  description = "OCID of the OKE cluster"
  value       = module.oke.cluster_id
}

output "oke_cluster_name" {
  description = "Name of the OKE cluster"
  value       = module.oke.cluster_name
}

output "oke_cluster_kubernetes_version" {
  description = "Kubernetes version running on the cluster"
  value       = module.oke.cluster_kubernetes_version
}

output "oke_cluster_endpoints" {
  description = "OKE cluster endpoint details"
  value       = module.oke.cluster_endpoints
}

output "oke_node_pool_id" {
  description = "OCID of the managed node pool"
  value       = module.oke.node_pool_id
}

# ──────────────────────────────────────────────
# Storage Outputs
# ──────────────────────────────────────────────

output "block_volume_id" {
  description = "OCID of the block volume for the application"
  value       = oci_core_volume.app_volume.id
}

# ──────────────────────────────────────────────
# Convenience
# ──────────────────────────────────────────────

output "region" {
  description = "OCI region used for deployment"
  value       = var.region
}

output "kubeconfig_command" {
  description = "Command to configure kubectl for this cluster"
  value       = "oci ce cluster create-kubeconfig --cluster-id ${module.oke.cluster_id} --file $HOME/.kube/config --region ${var.region} --token-version 2.0.0"
}

output "apply_manifests_command" {
  description = "Command to deploy the application to OKE"
  value       = "kubectl apply -f manifests/"
}
