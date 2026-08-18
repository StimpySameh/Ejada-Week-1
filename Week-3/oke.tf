# ──────────────────────────────────────────────
# OKE Cluster via Module
# ──────────────────────────────────────────────

module "oke" {
  source = "./modules/oke"

  compartment_id = var.compartment_ocid

  
  cluster_name       = "${local.name_prefix}-${var.cluster_name}"
  kubernetes_version = var.kubernetes_version
  vcn_id             = oci_core_vcn.this.id

   
  api_endpoint_subnet_id = module.api_endpoint_subnet.subnet_id
  is_api_endpoint_public = var.is_api_endpoint_public

   
  service_lb_subnet_ids = [module.service_lb_subnet.subnet_id]

 
  cni_type      = var.cni_type
  pod_subnet_id = module.pod_subnet.subnet_id

   
  create_node_pool      = true
  node_pool_name        = "${local.name_prefix}-${var.node_pool_name}"
  node_pool_size        = var.node_pool_size
  node_shape            = var.node_shape
  node_ocpus            = var.node_ocpus
  node_memory_in_gbs    = var.node_memory_in_gbs
  node_image_id         = local.node_image_id
  node_subnet_id        = module.worker_subnet.subnet_id
  node_boot_volume_size_gbs = var.node_boot_volume_size_gbs
  availability_domain   = local.ad_name
  ssh_public_key        = var.ssh_public_key

  freeform_tags = local.common_tags
}
