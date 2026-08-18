
locals {
  
  name_prefix = "${var.project_name}-${var.environment}"

   ad_name = data.oci_identity_availability_domains.ads.availability_domains[0].name

   
  all_services = [
    for s in data.oci_core_services.all_services.services :
    s if can(regex("All .* Services In Oracle Services Network", s.name))
  ]
  service_id         = local.all_services[0].id
  service_cidr_block = local.all_services[0].cidr_block

  
  oke_k8s_version = trimprefix(var.kubernetes_version, "v")
  is_arm_shape    = can(regex("A1", var.node_shape))

  node_image_id = var.node_image_ocid != "" ? var.node_image_ocid : [
    for src in data.oci_containerengine_node_pool_option.oke_images.sources :
    src.image_id
    if(
      can(regex("Oracle-Linux", src.source_name)) &&
      (local.is_arm_shape ? can(regex("aarch64", src.source_name)) : !can(regex("aarch64", src.source_name))) &&
      can(regex("OKE-${local.oke_k8s_version}", src.source_name)) &&
      !can(regex("GPU", src.source_name))
    )
  ][0]

  # Common freeform tags
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
