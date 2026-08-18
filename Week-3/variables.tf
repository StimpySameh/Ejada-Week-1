# ──────────────────────────────────────────────
# Authentication
# ──────────────────────────────────────────────

variable "tenancy_ocid" {
  description = "OCID of your OCI tenancy"
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^ocid1\\.tenancy\\.oc[0-9]+\\.", var.tenancy_ocid))
    error_message = "Must be a valid tenancy OCID (ocid1.tenancy.oc1....)."
  }
}

variable "user_ocid" {
  description = "OCID of the OCI user used for API authentication"
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^ocid1\\.user\\.oc[0-9]+\\.", var.user_ocid))
    error_message = "Must be a valid user OCID (ocid1.user.oc1....)."
  }
}

variable "fingerprint" {
  description = "Fingerprint of the uploaded API public key"
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^([0-9a-f]{2}:){15}[0-9a-f]{2}$", var.fingerprint))
    error_message = "Must be a valid key fingerprint (xx:xx:...:xx, 16 hex pairs)."
  }
}

variable "private_key_path" {
  description = "Full path to the API private key (.pem) file on your machine"
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("\\.(pem|key)$", var.private_key_path))
    error_message = "Must point to a .pem or .key file."
  }
}

# ──────────────────────────────────────────────
# Tenancy / Region
# ──────────────────────────────────────────────

variable "region" {
  description = "OCI region identifier (e.g. me-jeddah-1, us-ashburn-1)"
  type        = string
  default     = "me-jeddah-1"
}

variable "compartment_ocid" {
  description = "OCID of the compartment where resources will be created"
  type        = string

  validation {
    condition     = can(regex("^ocid1\\.(tenancy|compartment)\\.oc[0-9]+\\.", var.compartment_ocid))
    error_message = "Must be a valid compartment or tenancy OCID."
  }
}

# ──────────────────────────────────────────────
# Project Naming
# ──────────────────────────────────────────────

variable "project_name" {
  description = "Project name prefix used for naming all resources"
  type        = string
  default     = "week3"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}$", var.project_name))
    error_message = "Project name must be 2-21 lowercase alphanumeric characters or hyphens, starting with a letter."
  }
}

variable "environment" {
  description = "Environment label (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

# ──────────────────────────────────────────────
# Networking – VCN
# ──────────────────────────────────────────────

variable "vcn_cidr" {
  description = "CIDR block for the Virtual Cloud Network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vcn_display_name" {
  description = "Display name for the VCN"
  type        = string
  default     = "oke-vcn"
}

# ──────────────────────────────────────────────
# Networking – Subnets
# ──────────────────────────────────────────────

variable "api_endpoint_subnet_cidr" {
  description = "CIDR block for the Kubernetes API endpoint / LB subnet (public)"
  type        = string
  default     = "10.0.0.0/24"
}

variable "worker_subnet_cidr" {
  description = "CIDR block for the OKE worker nodes subnet (private)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "pod_subnet_cidr" {
  description = "CIDR block for VCN-native pods (private, needs large range)"
  type        = string
  default     = "10.0.64.0/18"
}

variable "service_lb_subnet_cidr" {
  description = "CIDR block for the Kubernetes Service LoadBalancer subnet (public)"
  type        = string
  default     = "10.0.2.0/24"
}

# ──────────────────────────────────────────────
# OKE Cluster
# ──────────────────────────────────────────────

variable "cluster_name" {
  description = "Display name for the OKE cluster"
  type        = string
  default     = "oke-cluster"
}

variable "kubernetes_version" {
  description = "Kubernetes version for OKE (e.g. v1.33.10)"
  type        = string
  default     = "v1.33.10"
}

variable "is_api_endpoint_public" {
  description = "Whether the Kubernetes API endpoint should be publicly accessible"
  type        = bool
  default     = true
}

variable "cni_type" {
  description = "Container network interface: OCI_VCN_IP_NATIVE or FLANNEL_OVERLAY"
  type        = string
  default     = "OCI_VCN_IP_NATIVE"
}

# ──────────────────────────────────────────────
# OKE Node Pool
# ──────────────────────────────────────────────

variable "node_pool_name" {
  description = "Display name for the managed worker node pool"
  type        = string
  default     = "pool1"
}

variable "node_pool_size" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
}

variable "node_shape" {
  description = "Compute shape for OKE worker nodes"
  type        = string
  default     = "VM.Standard.A1.Flex"
}

variable "node_ocpus" {
  description = "Number of OCPUs per worker node"
  type        = number
  default     = 1
}

variable "node_memory_in_gbs" {
  description = "Memory in GB per worker node"
  type        = number
  default     = 6
}

variable "node_image_ocid" {
  description = "OCID of the OKE node image. Leave empty to auto-select."
  type        = string
  default     = ""
}

variable "node_boot_volume_size_gbs" {
  description = "Boot volume size in GB for worker nodes"
  type        = number
  default     = 50
}

variable "ssh_public_key" {
  description = "SSH public key content for worker node access"
  type        = string
  default     = ""
}

# ──────────────────────────────────────────────
# Block Volume (for application)
# ──────────────────────────────────────────────

variable "block_volume_size_gbs" {
  description = "Size of the external block volume in GB"
  type        = number
  default     = 50
}

variable "block_volume_display_name" {
  description = "Display name for the block volume"
  type        = string
  default     = "app-block-volume"
}

# ──────────────────────────────────────────────
# Application
# ──────────────────────────────────────────────

variable "app_name" {
  description = "Name for the Kubernetes deployment/application"
  type        = string
  default     = "nginx-app"
}

variable "app_image" {
  description = "Container image for the application"
  type        = string
  default     = "nginx:latest"
}

variable "app_port" {
  description = "Port the application listens on"
  type        = number
  default     = 80
}

variable "app_replicas" {
  description = "Number of pod replicas"
  type        = number
  default     = 2
}

# ──────────────────────────────────────────────
# Flow Logs
# ──────────────────────────────────────────────

variable "enable_subnet_logs" {
  description = "Whether to enable VCN flow logs on subnets"
  type        = bool
  default     = true
}
