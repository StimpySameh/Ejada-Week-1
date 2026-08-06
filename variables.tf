variable "tenancy_ocid" {
  description = "OCID of your OCI tenancy"
  type        = string
}

variable "user_ocid" {
  description = "OCID of the OCI user used for API authentication"
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint of the uploaded API public key"
  type        = string
}

variable "private_key_path" {
  description = "Full path to the API private key (.pem) file on your machine"
  type        = string
}

variable "region" {
  description = "OCI region identifier"
  type        = string
  default     = "me-jeddah-1"
}

variable "compartment_ocid" {
  description = "OCID of the compartment where the instance will be created (root/tenancy OCID is fine)"
  type        = string
}

variable "instance_display_name" {
  description = "Display name for the compute instance"
  type        = string
  default     = "my first instance"
}

variable "instance_image_ocid" {
  description = "Explicit OCI image OCID to use for the instance. Leave empty to auto-select an ARM-compatible image when available."
  type        = string
  default     = ""
}
