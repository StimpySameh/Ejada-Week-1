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
  default     = "week2"

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
  default     = "week2-vcn"
}

# ──────────────────────────────────────────────
# Networking – Public Subnet (Load Balancer)
# ──────────────────────────────────────────────

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet (LB subnet)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_display_name" {
  description = "Display name for the public subnet"
  type        = string
  default     = "public-lb-subnet"
}

# ──────────────────────────────────────────────
# Networking – Private Subnet (Compute + FSS)
# ──────────────────────────────────────────────

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet (compute subnet)"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_display_name" {
  description = "Display name for the private subnet"
  type        = string
  default     = "private-app-subnet"
}

# ──────────────────────────────────────────────
# Compute Instance
# ──────────────────────────────────────────────

variable "instance_display_name" {
  description = "Display name for the private compute instance"
  type        = string
  default     = "app-server"
}

variable "instance_shape" {
  description = "Compute shape to use (e.g. VM.Standard.A1.Flex for ARM free tier)"
  type        = string
  default     = "VM.Standard.A1.Flex"
}

variable "instance_ocpus" {
  description = "Number of OCPUs to allocate to the instance"
  type        = number
  default     = 1

  validation {
    condition     = var.instance_ocpus >= 1 && var.instance_ocpus <= 4
    error_message = "Free tier allows 1–4 OCPUs across all A1 instances."
  }
}

variable "instance_memory_in_gbs" {
  description = "Amount of memory (GB) to allocate to the instance"
  type        = number
  default     = 6

  validation {
    condition     = var.instance_memory_in_gbs >= 1 && var.instance_memory_in_gbs <= 24
    error_message = "Free tier allows 1–24 GB across all A1 instances."
  }
}

variable "instance_image_ocid" {
  description = "Explicit OCI image OCID. Leave empty to auto-select the latest ARM-compatible Oracle Linux image."
  type        = string
  default     = ""
}

variable "ssh_public_key" {
  description = "SSH public key content for instance access (paste the full key)"
  type        = string
  default     = ""
}

# ──────────────────────────────────────────────
# Application
# ──────────────────────────────────────────────

variable "app_port" {
  description = "Port the application listens on inside the private instance"
  type        = number
  default     = 8080

  validation {
    condition     = var.app_port >= 1 && var.app_port <= 65535
    error_message = "Port must be between 1 and 65535."
  }
}

# ──────────────────────────────────────────────
# Load Balancer
# ──────────────────────────────────────────────

variable "lb_display_name" {
  description = "Display name for the Application Load Balancer"
  type        = string
  default     = "app-lb"
}

variable "lb_shape" {
  description = "Shape of the load balancer (flexible or fixed)"
  type        = string
  default     = "flexible"
}

variable "lb_min_bandwidth_mbps" {
  description = "Minimum bandwidth in Mbps for flexible LB shape"
  type        = number
  default     = 10
}

variable "lb_max_bandwidth_mbps" {
  description = "Maximum bandwidth in Mbps for flexible LB shape"
  type        = number
  default     = 10
}

variable "lb_listener_port" {
  description = "Port the load balancer listens on (public-facing)"
  type        = number
  default     = 80
}

# ──────────────────────────────────────────────
# File Storage Service
# ──────────────────────────────────────────────

variable "fss_display_name" {
  description = "Display name for the File Storage file system"
  type        = string
  default     = "app-file-system"
}

variable "fss_mount_target_display_name" {
  description = "Display name for the FSS mount target"
  type        = string
  default     = "app-mount-target"
}

variable "fss_export_path" {
  description = "Export path for the file system (must start with /)"
  type        = string
  default     = "/app-data"

  validation {
    condition     = can(regex("^/", var.fss_export_path))
    error_message = "Export path must start with /."
  }
}

variable "fss_mount_point" {
  description = "Local mount point on the compute instance"
  type        = string
  default     = "/mnt/app-data"

  validation {
    condition     = can(regex("^/", var.fss_mount_point))
    error_message = "Mount point must be an absolute path starting with /."
  }
}

# ──────────────────────────────────────────────
# Jump Host
# ──────────────────────────────────────────────

variable "jumphost_display_name" {
  description = "Display name for the jump host instance"
  type        = string
  default     = "jumphost"
}

variable "jumphost_shape" {
  description = "Compute shape for the jump host (lightweight is fine)"
  type        = string
  default     = "VM.Standard.A1.Flex"
}

variable "jumphost_ocpus" {
  description = "Number of OCPUs for the jump host"
  type        = number
  default     = 1
}

variable "jumphost_memory_in_gbs" {
  description = "Memory in GB for the jump host"
  type        = number
  default     = 6
}
