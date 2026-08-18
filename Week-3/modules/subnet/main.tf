
# ──────────────────────────────────────────────
# 1. Route Table (with dynamic route rules)
# ──────────────────────────────────────────────

resource "oci_core_route_table" "this" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = var.route_table_display_name != "" ? var.route_table_display_name : "${var.display_name}-rt"

  dynamic "route_rules" {
    for_each = var.route_rules
    content {
      destination       = route_rules.value.destination
      destination_type  = route_rules.value.destination_type
      network_entity_id = route_rules.value.network_entity_id
      description       = route_rules.value.description
    }
  }

  freeform_tags = var.freeform_tags
}

# ──────────────────────────────────────────────
# 2. Security List (with dynamic ingress/egress rules)
# ──────────────────────────────────────────────

resource "oci_core_security_list" "this" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = var.security_list_display_name != "" ? var.security_list_display_name : "${var.display_name}-sl"

    dynamic "ingress_security_rules" {
    for_each = var.ingress_rules
    content {
      protocol    = ingress_security_rules.value.protocol
      source      = ingress_security_rules.value.source
      source_type = ingress_security_rules.value.source_type
      stateless   = ingress_security_rules.value.stateless
      description = ingress_security_rules.value.description

      dynamic "tcp_options" {
        for_each = ingress_security_rules.value.tcp_options != null ? [ingress_security_rules.value.tcp_options] : []
        content {
          min = tcp_options.value.min
          max = tcp_options.value.max
        }
      }

      dynamic "udp_options" {
        for_each = ingress_security_rules.value.udp_options != null ? [ingress_security_rules.value.udp_options] : []
        content {
          min = udp_options.value.min
          max = udp_options.value.max
        }
      }

      dynamic "icmp_options" {
        for_each = ingress_security_rules.value.icmp_options != null ? [ingress_security_rules.value.icmp_options] : []
        content {
          type = icmp_options.value.type
          code = icmp_options.value.code
        }
      }
    }
  }

   dynamic "egress_security_rules" {
    for_each = var.egress_rules
    content {
      protocol         = egress_security_rules.value.protocol
      destination      = egress_security_rules.value.destination
      destination_type = egress_security_rules.value.destination_type
      stateless        = egress_security_rules.value.stateless
      description      = egress_security_rules.value.description

      dynamic "tcp_options" {
        for_each = egress_security_rules.value.tcp_options != null ? [egress_security_rules.value.tcp_options] : []
        content {
          min = tcp_options.value.min
          max = tcp_options.value.max
        }
      }

      dynamic "udp_options" {
        for_each = egress_security_rules.value.udp_options != null ? [egress_security_rules.value.udp_options] : []
        content {
          min = udp_options.value.min
          max = udp_options.value.max
        }
      }
    }
  }

  freeform_tags = var.freeform_tags
}

# ──────────────────────────────────────────────
# 3. Subnet
# ──────────────────────────────────────────────

resource "oci_core_subnet" "this" {
  compartment_id             = var.compartment_id
  vcn_id                     = var.vcn_id
  cidr_block                 = var.cidr_block
  display_name               = var.display_name
  dns_label                  = var.dns_label
  prohibit_public_ip_on_vnic = var.prohibit_public_ip_on_vnic
  route_table_id             = oci_core_route_table.this.id
  security_list_ids          = [oci_core_security_list.this.id]

  freeform_tags = var.freeform_tags
}

# ──────────────────────────────────────────────
# 4. VCN Flow Logs (conditional)
# ──────────────────────────────────────────────


resource "oci_logging_log_group" "this" {
  count = var.enable_logs && var.log_group_id == "" ? 1 : 0

  compartment_id = var.compartment_id
  display_name   = "${var.display_name}-log-group"
  description    = "Log group for ${var.display_name} subnet flow logs"

  freeform_tags = var.freeform_tags
}

locals {
  # Use the provided log group ID or the one we just created
  effective_log_group_id = var.enable_logs ? (
    var.log_group_id != "" ? var.log_group_id : oci_logging_log_group.this[0].id
  ) : ""
}

resource "oci_logging_log" "subnet_flow_log" {
  count = var.enable_logs ? 1 : 0

  display_name = var.log_display_name != "" ? var.log_display_name : "${var.display_name}-flow-log"
  log_group_id = local.effective_log_group_id
  log_type     = "SERVICE"

  configuration {
    source {
      category    = "all"
      resource    = oci_core_subnet.this.id
      service     = "flowlogs"
      source_type = "OCISERVICE"
    }

    compartment_id = var.compartment_id
  }

  is_enabled         = true
  retention_duration = var.log_retention_duration

  freeform_tags = var.freeform_tags
}
