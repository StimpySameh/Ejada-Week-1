# ──────────────────────────────────────────────
# VCN + Gateways + Subnet Module Calls
# ──────────────────────────────────────────────

# ══════════════════════════════════════════════
# 1. Virtual Cloud Network (VCN)
# ══════════════════════════════════════════════

resource "oci_core_vcn" "this" {
  compartment_id = var.compartment_ocid
  cidr_blocks    = [var.vcn_cidr]
  display_name   = "${local.name_prefix}-${var.vcn_display_name}"
  dns_label      = replace(var.project_name, "-", "")

  freeform_tags = local.common_tags
}

# ══════════════════════════════════════════════
# 2. Gateways
# ══════════════════════════════════════════════

resource "oci_core_internet_gateway" "this" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${local.name_prefix}-igw"
  enabled        = true

  freeform_tags = local.common_tags
}

resource "oci_core_nat_gateway" "this" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${local.name_prefix}-natgw"

  freeform_tags = local.common_tags
}

resource "oci_core_service_gateway" "this" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${local.name_prefix}-sgw"

  services {
    service_id = local.service_id
  }

  freeform_tags = local.common_tags
}

# ══════════════════════════════════════════════
# 3. Subnets via Module
# ══════════════════════════════════════════════
module "api_endpoint_subnet" {
  source = "./modules/subnet"

  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.this.id
  display_name               = "${local.name_prefix}-api-endpoint"
  cidr_block                 = var.api_endpoint_subnet_cidr
  dns_label                  = "apiendpoint"
  prohibit_public_ip_on_vnic = false

  route_rules = [
    {
      destination       = "0.0.0.0/0"
      destination_type  = "CIDR_BLOCK"
      network_entity_id = oci_core_internet_gateway.this.id
      description       = "Internet access via IGW"
    }
  ]

  ingress_rules = [
    {
      protocol    = "6"
      source      = var.worker_subnet_cidr
      description = "Allow Worker nodes to Kubernetes API endpoint (6443)"
      tcp_options = { min = 6443, max = 6443 }
    },
    {
      protocol    = "6"
      source      = var.worker_subnet_cidr
      description = "Allow Worker nodes to Kubernetes API endpoint (12250)"
      tcp_options = { min = 12250, max = 12250 }
    },
    {
      protocol    = "6"
      source      = var.pod_subnet_cidr
      description = "Allow Pods to Kubernetes API endpoint (6443)"
      tcp_options = { min = 6443, max = 6443 }
    },
    {
      protocol    = "6"
      source      = "0.0.0.0/0"
      description = "Allow external access to Kubernetes API (port 6443)"
      tcp_options = { min = 6443, max = 6443 }
    },
    {
      protocol    = "6"
      source      = "0.0.0.0/0"
      description = "Allow HTTPS"
      tcp_options = { min = 443, max = 443 }
    },
    {
      protocol    = "1"
      source      = var.vcn_cidr
      description = "ICMP from VCN"
      icmp_options = { type = 3, code = 4 }
    }
  ]

  egress_rules = [
    {
      protocol         = "all"
      destination      = "0.0.0.0/0"
      destination_type = "CIDR_BLOCK"
      description      = "Allow all egress"
    }
  ]

  enable_logs   = var.enable_subnet_logs
  freeform_tags = local.common_tags
}

module "service_lb_subnet" {
  source = "./modules/subnet"

  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.this.id
  display_name               = "${local.name_prefix}-svc-lb"
  cidr_block                 = var.service_lb_subnet_cidr
  dns_label                  = "svclb"
  prohibit_public_ip_on_vnic = false

  route_rules = [
    {
      destination       = "0.0.0.0/0"
      destination_type  = "CIDR_BLOCK"
      network_entity_id = oci_core_internet_gateway.this.id
      description       = "Internet access via IGW"
    }
  ]

  ingress_rules = [
    {
      protocol    = "6"
      source      = "0.0.0.0/0"
      description = "Allow HTTP from internet"
      tcp_options = { min = 80, max = 80 }
    },
    {
      protocol    = "6"
      source      = "0.0.0.0/0"
      description = "Allow HTTPS from internet"
      tcp_options = { min = 443, max = 443 }
    },
    {
      protocol    = "6"
      source      = "0.0.0.0/0"
      description = "Allow NodePort range from internet"
      tcp_options = { min = 30000, max = 32767 }
    }
  ]

  egress_rules = [
    {
      protocol         = "all"
      destination      = "0.0.0.0/0"
      destination_type = "CIDR_BLOCK"
      description      = "Allow all egress"
    }
  ]

  enable_logs   = var.enable_subnet_logs
  freeform_tags = local.common_tags
}

module "worker_subnet" {
  source = "./modules/subnet"

  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.this.id
  display_name               = "${local.name_prefix}-workers"
  cidr_block                 = var.worker_subnet_cidr
  dns_label                  = "workers"
  prohibit_public_ip_on_vnic = true

  route_rules = [
    {
      destination       = "0.0.0.0/0"
      destination_type  = "CIDR_BLOCK"
      network_entity_id = oci_core_nat_gateway.this.id
      description       = "Internet access via NAT Gateway"
    },
    {
      destination       = local.service_cidr_block
      destination_type  = "SERVICE_CIDR_BLOCK"
      network_entity_id = oci_core_service_gateway.this.id
      description       = "OCI services via Service Gateway"
    }
  ]

  ingress_rules = [
    {
      protocol    = "all"
      source      = var.worker_subnet_cidr
      description = "Allow all traffic between worker nodes"
    },
    {
      protocol    = "all"
      source      = var.pod_subnet_cidr
      description = "Allow all traffic from pods"
    },
    {
      protocol    = "6"
      source      = var.api_endpoint_subnet_cidr
      description = "Allow Kubernetes API to worker communication"
      tcp_options = { min = 10250, max = 10250 }
    },
    {
      protocol    = "6"
      source      = "0.0.0.0/0"
      description = "Allow NodePort services"
      tcp_options = { min = 30000, max = 32767 }
    },
    {
      protocol    = "1"
      source      = var.vcn_cidr
      description = "ICMP Path MTU Discovery"
      icmp_options = { type = 3, code = 4 }
    },
    {
      protocol    = "6"
      source      = var.api_endpoint_subnet_cidr
      description = "Allow K8s API server to kubelet"
      tcp_options = { min = 12250, max = 12250 }
    }
  ]

  egress_rules = [
    {
      protocol         = "all"
      destination      = "0.0.0.0/0"
      destination_type = "CIDR_BLOCK"
      description      = "Allow all egress to internet"
    },
    {
      protocol         = "all"
      destination      = var.pod_subnet_cidr
      destination_type = "CIDR_BLOCK"
      description      = "Allow all traffic to pods"
    },
    {
      protocol         = "6"
      destination      = local.service_cidr_block
      destination_type = "SERVICE_CIDR_BLOCK"
      description      = "Access OCI services via SGW"
    }
  ]

  enable_logs   = var.enable_subnet_logs
  freeform_tags = local.common_tags
}

module "pod_subnet" {
  source = "./modules/subnet"

  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.this.id
  display_name               = "${local.name_prefix}-pods"
  cidr_block                 = var.pod_subnet_cidr
  dns_label                  = "pods"
  prohibit_public_ip_on_vnic = true

  route_rules = [
    {
      destination       = "0.0.0.0/0"
      destination_type  = "CIDR_BLOCK"
      network_entity_id = oci_core_nat_gateway.this.id
      description       = "Internet access via NAT Gateway for pods"
    },
    {
      destination       = local.service_cidr_block
      destination_type  = "SERVICE_CIDR_BLOCK"
      network_entity_id = oci_core_service_gateway.this.id
      description       = "OCI services via Service Gateway"
    }
  ]

  ingress_rules = [
    {
      protocol    = "all"
      source      = var.pod_subnet_cidr
      description = "Allow all pod-to-pod communication"
    },
    {
      protocol    = "all"
      source      = var.worker_subnet_cidr
      description = "Allow all traffic from worker nodes"
    },
    {
      protocol    = "all"
      source      = var.api_endpoint_subnet_cidr
      description = "Allow traffic from API endpoint"
    },
    {
      protocol    = "1"
      source      = var.vcn_cidr
      description = "ICMP Path MTU Discovery"
      icmp_options = { type = 3, code = 4 }
    }
  ]

  egress_rules = [
    {
      protocol         = "all"
      destination      = "0.0.0.0/0"
      destination_type = "CIDR_BLOCK"
      description      = "Allow all pod egress"
    },
    {
      protocol         = "all"
      destination      = var.worker_subnet_cidr
      destination_type = "CIDR_BLOCK"
      description      = "Allow pods to reach worker nodes"
    },
    {
      protocol         = "6"
      destination      = local.service_cidr_block
      destination_type = "SERVICE_CIDR_BLOCK"
      description      = "Access OCI services via SGW"
    }
  ]

  enable_logs   = var.enable_subnet_logs
  freeform_tags = local.common_tags
}
