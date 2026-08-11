# ──────────────────────────────────────────────
# Networking Outputs
# ──────────────────────────────────────────────

output "vcn_id" {
  description = "OCID of the created VCN"
  value       = oci_core_vcn.this.id
}

output "public_subnet_id" {
  description = "OCID of the public (LB) subnet"
  value       = oci_core_subnet.public.id
}

output "private_subnet_id" {
  description = "OCID of the private (compute) subnet"
  value       = oci_core_subnet.private.id
}

# ──────────────────────────────────────────────
# Compute Outputs
# ──────────────────────────────────────────────

output "instance_id" {
  description = "OCID of the private compute instance"
  value       = oci_core_instance.app.id
}

output "instance_private_ip" {
  description = "Private IP of the compute instance"
  value       = oci_core_instance.app.private_ip
}

output "instance_state" {
  description = "Lifecycle state of the compute instance"
  value       = oci_core_instance.app.state
}

# ──────────────────────────────────────────────
# Load Balancer Outputs
# ──────────────────────────────────────────────

output "lb_id" {
  description = "OCID of the Application Load Balancer"
  value       = oci_load_balancer_load_balancer.this.id
}

output "lb_public_ip" {
  description = "Public IP address of the Load Balancer (use this to access the app)"
  value       = oci_load_balancer_load_balancer.this.ip_address_details[0].ip_address
}

output "app_url" {
  description = "URL to access the application via the Load Balancer"
  value       = "http://${oci_load_balancer_load_balancer.this.ip_address_details[0].ip_address}:${var.lb_listener_port}"
}

# ──────────────────────────────────────────────
# File Storage Outputs
# ──────────────────────────────────────────────

output "fss_id" {
  description = "OCID of the OCI File Storage file system"
  value       = oci_file_storage_file_system.this.id
}

output "fss_mount_target_id" {
  description = "OCID of the FSS mount target"
  value       = oci_file_storage_mount_target.this.id
}

output "fss_mount_target_ip" {
  description = "Private IP of the FSS mount target"
  value       = data.oci_core_private_ip.mount_target_ip.ip_address
}

output "fss_export_path" {
  description = "Export path of the file system"
  value       = var.fss_export_path
}

# ──────────────────────────────────────────────
# Jump Host Outputs
# ──────────────────────────────────────────────

output "jumphost_id" {
  description = "OCID of the jump host instance"
  value       = oci_core_instance.jumphost.id
}

output "jumphost_public_ip" {
  description = "Public IP of the jump host (SSH into this first)"
  value       = oci_core_instance.jumphost.public_ip
}

# ──────────────────────────────────────────────
# Convenience
# ──────────────────────────────────────────────

output "region" {
  description = "OCI region used for deployment"
  value       = var.region
}

output "ssh_to_private_instance_command" {
  description = "SSH command to reach the private app server via the jump host"
  value       = "ssh -J opc@${oci_core_instance.jumphost.public_ip} opc@${oci_core_instance.app.private_ip}"
}
