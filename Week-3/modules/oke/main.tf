

# ──────────────────────────────────────────────
# 1. OKE Cluster
# ──────────────────────────────────────────────

resource "oci_containerengine_cluster" "this" {
  compartment_id     = var.compartment_id
  kubernetes_version = var.kubernetes_version
  name               = var.cluster_name
  vcn_id             = var.vcn_id

 
  options {
    
    service_lb_subnet_ids = var.service_lb_subnet_ids

   
    add_ons {
      is_kubernetes_dashboard_enabled = var.enable_dashboard
      is_tiller_enabled              = var.enable_tiller
    }

      
    kubernetes_network_config {
      pods_cidr     = var.cni_type == "FLANNEL_OVERLAY" ? "10.244.0.0/16" : null
      services_cidr = "10.96.0.0/16"
    }
  }

   cluster_pod_network_options {
    cni_type = var.cni_type
  }

   
  endpoint_config {
    is_public_ip_enabled = var.is_api_endpoint_public
    subnet_id            = var.api_endpoint_subnet_id
  }

  freeform_tags = var.freeform_tags
}

# ──────────────────────────────────────────────
# 2. Managed Node Pool (conditional)
# ──────────────────────────────────────────────

resource "oci_containerengine_node_pool" "this" {
  count = var.create_node_pool ? 1 : 0

  compartment_id     = var.compartment_id
  cluster_id         = oci_containerengine_cluster.this.id
  kubernetes_version = var.kubernetes_version
  name               = var.node_pool_name
  node_shape         = var.node_shape

    dynamic "node_shape_config" {
    for_each = can(regex("Flex$", var.node_shape)) ? [1] : []
    content {
      ocpus         = var.node_ocpus
      memory_in_gbs = var.node_memory_in_gbs
    }
  }

   
  node_source_details {
    source_type             = "IMAGE"
    image_id                = var.node_image_id
    boot_volume_size_in_gbs = var.node_boot_volume_size_gbs
  }

   node_config_details {
    size = var.node_pool_size

    placement_configs {
      availability_domain = var.availability_domain
      subnet_id           = var.node_subnet_id
    }

    dynamic "node_pool_pod_network_option_details" {
      for_each = var.cni_type == "OCI_VCN_IP_NATIVE" ? [1] : []
      content {
        cni_type       = "OCI_VCN_IP_NATIVE"
        pod_subnet_ids = [var.pod_subnet_id]
      }
    }
  }

  ssh_public_key = var.ssh_public_key

  freeform_tags = var.freeform_tags
}
