output "instance_id" {
  description = "OCID of the created compute instance"
  value       = oci_core_instance.this.id
}

output "instance_state" {
  description = "Lifecycle state of the instance (should be RUNNING)"
  value       = oci_core_instance.this.state
}

output "instance_public_ip" {
  description = "Public IP address assigned to the instance"
  value       = oci_core_instance.this.public_ip
}

