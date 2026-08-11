# ──────────────────────────────────────────────
# Application Load Balancer (Public Subnet)
# ──────────────────────────────────────────────

resource "oci_load_balancer_load_balancer" "this" {
  compartment_id = var.compartment_ocid
  display_name   = "${local.name_prefix}-${var.lb_display_name}"
  shape          = var.lb_shape

  dynamic "shape_details" {
    for_each = var.lb_shape == "flexible" ? [1] : []
    content {
      minimum_bandwidth_in_mbps = var.lb_min_bandwidth_mbps
      maximum_bandwidth_in_mbps = var.lb_max_bandwidth_mbps
    }
  }

  subnet_ids = [oci_core_subnet.public.id]

  is_private = false

  freeform_tags = local.common_tags
}

# ──────────────────────────────────────────────
# Backend Set
# ──────────────────────────────────────────────

resource "oci_load_balancer_backend_set" "app" {
  load_balancer_id = oci_load_balancer_load_balancer.this.id
  name             = "${local.name_prefix}-app-backend-set"
  policy           = "ROUND_ROBIN"

  health_checker {
    protocol            = "HTTP"
    port                = var.app_port
    url_path            = "/health"
    return_code         = 200
    interval_ms         = 10000
    timeout_in_millis   = 3000
    retries             = 3
  }
}

# ──────────────────────────────────────────────
# Backend (the private compute instance)
# ──────────────────────────────────────────────

resource "oci_load_balancer_backend" "app" {
  load_balancer_id = oci_load_balancer_load_balancer.this.id
  backendset_name  = oci_load_balancer_backend_set.app.name
  ip_address       = oci_core_instance.app.private_ip
  port             = var.app_port
}

# ──────────────────────────────────────────────
# Listener
# ──────────────────────────────────────────────

resource "oci_load_balancer_listener" "http" {
  load_balancer_id         = oci_load_balancer_load_balancer.this.id
  name                     = "${local.name_prefix}-http-listener"
  default_backend_set_name = oci_load_balancer_backend_set.app.name
  port                     = var.lb_listener_port
  protocol                 = "HTTP"
}
