# ──────────────────────────────────────────────
# Derived Values & Naming Conventions
# ──────────────────────────────────────────────

locals {
  
  name_prefix = "${var.project_name}-${var.environment}"

  
  selected_image_id = (
    var.instance_image_ocid != ""
    ? var.instance_image_ocid
    : try(data.oci_core_images.oracle_linux.images[0].id, "")
  )

 
  ad_name = data.oci_identity_availability_domains.ads.availability_domains[0].name

  
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }

  
  mount_target_private_ip = data.oci_core_private_ip.mount_target_ip.ip_address

  
  cloud_init_script = templatefile("${path.module}/templates/cloud-init.yaml", {
    mount_target_ip = local.mount_target_private_ip
    export_path     = var.fss_export_path
    mount_point     = var.fss_mount_point
    app_port        = var.app_port
    project_name    = var.project_name
  })
}
