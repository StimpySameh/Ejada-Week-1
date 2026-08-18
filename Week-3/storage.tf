# ──────────────────────────────────────────────
# External Block Volume for Application
# ──────────────────────────────────────────────

resource "oci_core_volume" "app_volume" {
  compartment_id      = var.compartment_ocid
  availability_domain = local.ad_name
  display_name        = "${local.name_prefix}-${var.block_volume_display_name}"
  size_in_gbs         = var.block_volume_size_gbs

  freeform_tags = local.common_tags
}
