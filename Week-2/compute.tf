# ──────────────────────────────────────────────
# Private Compute Instance
# ──────────────────────────────────────────────

resource "oci_core_instance" "app" {
  compartment_id      = var.compartment_ocid
  availability_domain = local.ad_name
  shape               = var.instance_shape
  display_name        = "${local.name_prefix}-${var.instance_display_name}"

  shape_config {
    ocpus         = var.instance_ocpus
    memory_in_gbs = var.instance_memory_in_gbs
  }

  source_details {
    source_type = "image"
    source_id   = local.selected_image_id
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.private.id
    assign_public_ip = false
    display_name     = "${local.name_prefix}-app-vnic"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = base64encode(local.cloud_init_script)
  }

  freeform_tags = local.common_tags

  # The instance depends on the FSS mount target because
  # cloud-init needs the mount target IP to mount the file system
  depends_on = [
    oci_file_storage_export.this,
  ]
}
