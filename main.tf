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

# ──────────────────────────────────────────────
# Locals
# ──────────────────────────────────────────────

locals {

  selected_image_id = var.instance_image_ocid != "" ? var.instance_image_ocid : try(data.oci_core_images.oracle_linux.images[0].id, "")
}

# ──────────────────────────────────────────────
# Networking
# ──────────────────────────────────────────────

resource "oci_core_vcn" "this" {
  compartment_id = var.compartment_ocid
  cidr_blocks    = [var.vcn_cidr]
  display_name   = var.vcn_display_name
  dns_label      = "freetiervcn"
}

resource "oci_core_subnet" "this" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.this.id
  cidr_block                 = var.subnet_cidr
  display_name               = var.subnet_display_name
  dns_label                  = "freetiersub"
  prohibit_public_ip_on_vnic = false
}

# ──────────────────────────────────────────────
# Compute Instance
# ──────────────────────────────────────────────

resource "oci_core_instance" "this" {
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  shape               = var.instance_shape
  display_name        = var.instance_display_name

  shape_config {
    ocpus         = var.instance_ocpus
    memory_in_gbs = var.instance_memory_in_gbs
  }

  source_details {
    source_type = "image"
    source_id   = local.selected_image_id
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.this.id
    assign_public_ip = true
  }
}
