# ──────────────────────────────────────────────
# Subnet Module – Outputs
# ──────────────────────────────────────────────

output "subnet_id" {
  description = "OCID of the created subnet"
  value       = oci_core_subnet.this.id
}

output "subnet_cidr" {
  description = "CIDR block of the created subnet"
  value       = oci_core_subnet.this.cidr_block
}

output "route_table_id" {
  description = "OCID of the created route table"
  value       = oci_core_route_table.this.id
}

output "security_list_id" {
  description = "OCID of the created security list"
  value       = oci_core_security_list.this.id
}

output "flow_log_id" {
  description = "OCID of the VCN flow log (empty if logging is disabled)"
  value       = var.enable_logs ? oci_logging_log.subnet_flow_log[0].id : ""
}

output "log_group_id" {
  description = "OCID of the log group used for flow logs"
  value       = var.enable_logs ? local.effective_log_group_id : ""
}
