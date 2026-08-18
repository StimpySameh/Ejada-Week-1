# ──────────────────────────────────────────────
# Subnet Module – Input Variables
# ──────────────────────────────────────────────

variable "compartment_id" {
  description = "OCID of the compartment where resources will be created"
  type        = string
}

variable "vcn_id" {
  description = "OCID of the VCN where the subnet will be created"
  type        = string
}

variable "display_name" {
  description = "Display name for the subnet"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the subnet"
  type        = string
}

variable "dns_label" {
  description = "DNS label for the subnet (alphanumeric, max 15 chars)"
  type        = string
  default     = null
}

variable "prohibit_public_ip_on_vnic" {
  description = "Whether to block public IP assignment on VNICs in this subnet (true = private subnet)"
  type        = bool
  default     = true
}

# ──────────────────────────────────────────────
# Route Table
# ──────────────────────────────────────────────

variable "route_table_display_name" {
  description = "Display name for the route table. If empty, derived from subnet display_name."
  type        = string
  default     = ""
}

variable "route_rules" {
  description = "List of route rules for the route table"
  type = list(object({
    destination       = string
    destination_type  = string           # CIDR_BLOCK or SERVICE_CIDR_BLOCK
    network_entity_id = string
    description       = optional(string, "")
  }))
  default = []
}

# ──────────────────────────────────────────────
# Security List
# ──────────────────────────────────────────────

variable "security_list_display_name" {
  description = "Display name for the security list. If empty, derived from subnet display_name."
  type        = string
  default     = ""
}

variable "ingress_rules" {
  description = "List of ingress security rules (dynamic block)"
  type = list(object({
    protocol    = string                   # 6=TCP, 17=UDP, 1=ICMP, all=all
    source      = string
    source_type = optional(string, "CIDR_BLOCK")
    stateless   = optional(bool, false)
    description = optional(string, "")

    tcp_options = optional(object({
      min = number
      max = number
    }), null)

    udp_options = optional(object({
      min = number
      max = number
    }), null)

    icmp_options = optional(object({
      type = number
      code = optional(number, -1)
    }), null)
  }))
  default = []
}

variable "egress_rules" {
  description = "List of egress security rules (dynamic block)"
  type = list(object({
    protocol         = string
    destination      = string
    destination_type = optional(string, "CIDR_BLOCK")
    stateless        = optional(bool, false)
    description      = optional(string, "")

    tcp_options = optional(object({
      min = number
      max = number
    }), null)

    udp_options = optional(object({
      min = number
      max = number
    }), null)
  }))
  default = [{
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    stateless        = false
    description      = "Allow all egress"
  }]
}

# ──────────────────────────────────────────────
# Flow Logs (VCN Logging)
# ──────────────────────────────────────────────

variable "enable_logs" {
  description = "Whether to enable VCN flow logs on this subnet"
  type        = bool
  default     = true
}

variable "log_group_id" {
  description = "OCID of an existing log group. If empty and enable_logs=true, a new log group is created."
  type        = string
  default     = ""
}

variable "log_display_name" {
  description = "Display name for the flow log. If empty, derived from subnet display_name."
  type        = string
  default     = ""
}

variable "log_retention_duration" {
  description = "Log retention in days (30 or 60)"
  type        = number
  default     = 30
}

# ──────────────────────────────────────────────
# Tags
# ──────────────────────────────────────────────

variable "freeform_tags" {
  description = "Freeform tags applied to all resources in this module"
  type        = map(string)
  default     = {}
}
