# ──────────────────────────────────────────────
# Jump Host (Public Subnet)
# ──────────────────────────────────────────────
# A lightweight compute instance in the public subnet that acts as
# an SSH gateway to the private compute instance.
# SSH flow:  Your PC → Jump Host (public IP) → App Server (private IP)

resource "oci_core_instance" "jumphost" {
  compartment_id      = var.compartment_ocid
  availability_domain = local.ad_name
  shape               = var.jumphost_shape
  display_name        = "${local.name_prefix}-${var.jumphost_display_name}"

  shape_config {
    ocpus         = var.jumphost_ocpus
    memory_in_gbs = var.jumphost_memory_in_gbs
  }

  source_details {
    source_type = "image"
    source_id   = local.selected_image_id
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.public.id
    assign_public_ip = true
    display_name     = "${local.name_prefix}-jumphost-vnic"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }

  freeform_tags = local.common_tags
}
