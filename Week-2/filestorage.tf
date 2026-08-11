# ──────────────────────────────────────────────
# OCI File Storage Service
# ──────────────────────────────────────────────


resource "oci_file_storage_file_system" "this" {
  compartment_id      = var.compartment_ocid
  availability_domain = local.ad_name
  display_name        = "${local.name_prefix}-${var.fss_display_name}"

  freeform_tags = local.common_tags
}


resource "oci_file_storage_mount_target" "this" {
  compartment_id      = var.compartment_ocid
  availability_domain = local.ad_name
  subnet_id           = oci_core_subnet.private.id
  display_name        = "${local.name_prefix}-${var.fss_mount_target_display_name}"

  freeform_tags = local.common_tags
}


resource "oci_file_storage_export" "this" {
  export_set_id  = oci_file_storage_mount_target.this.export_set_id
  file_system_id = oci_file_storage_file_system.this.id
  path           = var.fss_export_path

  export_options {
    source                         = var.private_subnet_cidr
    access                         = "READ_WRITE"
    identity_squash                = "NONE"
    require_privileged_source_port = false
  }
}
