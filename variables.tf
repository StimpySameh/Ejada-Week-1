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
  description = "OCID of the compartment where resources will be created (root/tenancy OCID is fine)"
  type        = string

  validation {
    condition     = can(regex("^ocid1\\.(tenancy|compartment)\\.oc[0-9]+\\.", var.compartment_ocid))
    error_message = "Must be a valid compartment or tenancy OCID."
  }
}

# ──────────────────────────────────────────────
# Networking
# ──────────────────────────────────────────────

variable "vcn_cidr" {
  description = "CIDR block for the Virtual Cloud Network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the public subnet (must be within the VCN CIDR)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "vcn_display_name" {
  description = "Display name for the VCN"
  type        = string
  default     = "free-tier-vcn"
}

variable "subnet_display_name" {
  description = "Display name for the subnet"
  type        = string
  default     = "free-tier-subnet"
}

# ──────────────────────────────────────────────
# Compute Instance
# ──────────────────────────────────────────────

variable "instance_display_name" {
  description = "Display name for the compute instance"
  type        = string
  default     = "my first instance"
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
