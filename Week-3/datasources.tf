# ──────────────────────────────────────────────
# Data Sources
# ──────────────────────────────────────────────


data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}
data "oci_core_services" "all_services" {}

data "oci_containerengine_node_pool_option" "oke_images" {
  node_pool_option_id = "all"
  compartment_id      = var.compartment_ocid
}

data "oci_containerengine_cluster_option" "oke_options" {
  cluster_option_id = "all"
}
