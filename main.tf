data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid 
}



resource "oci_core_vcn" "this" {
  compartment_id = var.compartment_ocid
  cidr_blocks    = ["10.0.0.0/16"]
  display_name   = "free-tier-vcn"
  dns_label      = "freetiervcn"
}

resource "oci_core_subnet" "this" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.this.id
  cidr_block                 = "10.0.1.0/24"
  display_name               = "free-tier-subnet"
  dns_label                  = "freetiersub"
  prohibit_public_ip_on_vnic = false
}



data "oci_core_images" "alma_linux" {
  compartment_id   = var.compartment_ocid 
  operating_system = "Oracle Linux"
  shape            = "VM.Standard.A1.Flex"

  sort_by    = "TIMECREATED"
  sort_order = "DESC"
}

locals {
  selected_image_id = var.instance_image_ocid != "" ? var.instance_image_ocid : try(data.oci_core_images.alma_linux.images[0].id, "")
}

resource "oci_core_instance" "this" {
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name


  shape        = "VM.Standard.A1.Flex"
  display_name = var.instance_display_name

  shape_config {
    ocpus         = 1
    memory_in_gbs = 6
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
