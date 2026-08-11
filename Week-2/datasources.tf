# ──────────────────────────────────────────────
# Data Sources
# ──────────────────────────────────────────────


data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}
data "oci_core_images" "oracle_linux" {
  compartment_id   = var.compartment_ocid
  operating_system = "Oracle Linux"
  shape            = var.instance_shape

  sort_by    = "TIMECREATED"
  sort_order = "DESC"
}

# OCI Services list (for Service Gateway)
data "oci_core_services" "all_services" {}

# Look up mount target private IPs (for cloud-init)
data "oci_core_private_ip" "mount_target_ip" {
  private_ip_id = oci_file_storage_mount_target.this.private_ip_ids[0]
}
