# ──────────────────────────────────────────────
# OKE Module – Input Variables
# ──────────────────────────────────────────────

# ──────────────────────────────────────────────
# General
# ──────────────────────────────────────────────

variable "compartment_id" {
  description = "OCID of the compartment for the OKE cluster"
  type        = string
}

variable "cluster_name" {
  description = "Display name for the OKE cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the cluster (e.g. v1.30.1)"
  type        = string
}

# ──────────────────────────────────────────────
# Networking
# ──────────────────────────────────────────────

variable "vcn_id" {
  description = "OCID of the VCN for the cluster"
  type        = string
}

variable "api_endpoint_subnet_id" {
  description = "OCID of the subnet for the Kubernetes API endpoint"
  type        = string
}

variable "service_lb_subnet_ids" {
  description = "List of subnet OCIDs for Kubernetes LoadBalancer services"
  type        = list(string)
}

variable "is_api_endpoint_public" {
  description = "Whether the Kubernetes API endpoint should be publicly accessible"
  type        = bool
  default     = true
}

# ──────────────────────────────────────────────
# VCN-Native Pod Networking (CNI)
# ──────────────────────────────────────────────

variable "cni_type" {
  description = "Container network interface plugin: OCI_VCN_IP_NATIVE or FLANNEL_OVERLAY"
  type        = string
  default     = "OCI_VCN_IP_NATIVE"

  validation {
    condition     = contains(["OCI_VCN_IP_NATIVE", "FLANNEL_OVERLAY"], var.cni_type)
    error_message = "CNI type must be OCI_VCN_IP_NATIVE or FLANNEL_OVERLAY."
  }
}

variable "pod_subnet_id" {
  description = "OCID of the subnet for pods (required when cni_type = OCI_VCN_IP_NATIVE)"
  type        = string
  default     = ""
}

# ──────────────────────────────────────────────
# Service Gateway (mandatory)
# ──────────────────────────────────────────────

variable "service_cidr_block" {
  description = "The CIDR block for OCI services (used for service CIDR in cluster options)"
  type        = string
  default     = "all-jed-services-in-oracle-services-network"
}

# ──────────────────────────────────────────────
# Node Pool
# ──────────────────────────────────────────────

variable "create_node_pool" {
  description = "Whether to create a managed node pool"
  type        = bool
  default     = true
}

variable "node_pool_name" {
  description = "Display name for the node pool"
  type        = string
  default     = "default-pool"
}

variable "node_pool_size" {
  description = "Number of worker nodes in the node pool"
  type        = number
  default     = 2

  validation {
    condition     = var.node_pool_size >= 1
    error_message = "Node pool must have at least 1 node."
  }
}

variable "node_shape" {
  description = "Compute shape for worker nodes (e.g. VM.Standard.A1.Flex, VM.Standard.E4.Flex)"
  type        = string
  default     = "VM.Standard.A1.Flex"
}

variable "node_ocpus" {
  description = "Number of OCPUs per worker node (for Flex shapes)"
  type        = number
  default     = 1
}

variable "node_memory_in_gbs" {
  description = "Memory in GB per worker node (for Flex shapes)"
  type        = number
  default     = 6
}

variable "node_image_id" {
  description = "OCID of the image for worker nodes. Leave empty to use node_source_type = IMAGE with latest OKE image."
  type        = string
  default     = ""
}

variable "node_subnet_id" {
  description = "OCID of the subnet where worker nodes will be placed"
  type        = string
  default     = ""
}

variable "node_boot_volume_size_gbs" {
  description = "Boot volume size in GB for worker nodes"
  type        = number
  default     = 50
}

variable "ssh_public_key" {
  description = "SSH public key for worker node access"
  type        = string
  default     = ""
}

variable "availability_domain" {
  description = "Availability domain for the node pool placement"
  type        = string
}

# ──────────────────────────────────────────────
# Cluster Add-ons
# ──────────────────────────────────────────────

variable "enable_dashboard" {
  description = "Whether to enable the Kubernetes dashboard add-on"
  type        = bool
  default     = false
}

variable "enable_tiller" {
  description = "Whether to enable Tiller (Helm v2) add-on"
  type        = bool
  default     = false
}

# ──────────────────────────────────────────────
# Tags
# ──────────────────────────────────────────────

variable "freeform_tags" {
  description = "Freeform tags to apply to all OKE resources"
  type        = map(string)
  default     = {}
}
