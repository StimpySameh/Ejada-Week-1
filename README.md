# Terraform OCI – Free Tier Compute Instance

This project uses **Terraform** to provision a compute instance on **Oracle Cloud Infrastructure (OCI)** using the Always Free tier resources.

## What It Creates

| Resource | Details |
|----------|---------|
| **VCN** | Virtual Cloud Network (configurable CIDR) |
| **Subnet** | Public subnet with public IPs enabled |
| **Compute Instance** | ARM-based flex shape (configurable OCPUs & memory) with Oracle Linux |

## File Structure

| File | Purpose |
|------|---------|
| `versions.tf` | Terraform & OCI provider version constraints |
| `provider.tf` | OCI provider authentication configuration |
| `variables.tf` | All input variables with descriptions, types, defaults & validation |
| `main.tf` | Infrastructure resources (VCN, subnet, compute instance) |
| `outputs.tf` | Outputs (instance ID, state, public IP) |
| `terraform.tfvars` | **Your actual values** – ⚠️ contains secrets, git-ignored |
| `terraform.tfvars.example` | Safe-to-share template with placeholder values |
| `.gitignore` | Prevents committing secrets, state, and editor files |

---

## Quick Start

```bash
# 1. Copy the example and fill in your credentials
cp terraform.tfvars.example terraform.tfvars

# 2. Initialize the provider
terraform init

# 3. Preview changes
terraform plan

# 4. Apply
terraform apply

# 5. Tear down (when done)
terraform destroy
```

---

## Code Breakdown

### `versions.tf`
- **`terraform` block** – Requires Terraform `>= 1.5.0` and the `oracle/oci` provider `>= 5.0.0`.

### `provider.tf`
- **`provider "oci"` block** – Authenticates to OCI using API key credentials (tenancy OCID, user OCID, fingerprint, private key path, and region).

### `variables.tf`
All configurable values are declared here with section comments:

| Variable | What to Edit |
|----------|-------------|
| `tenancy_ocid` | Your tenancy OCID (sensitive, validated) |
| `user_ocid` | API user OCID (sensitive, validated) |
| `fingerprint` | API key fingerprint (sensitive, validated) |
| `private_key_path` | Path to `.pem` file (sensitive, validated) |
| `region` | OCI region (default: `me-jeddah-1`) |
| `compartment_ocid` | Target compartment OCID (validated) |
| `vcn_cidr` | VCN CIDR block (default: `10.0.0.0/16`) |
| `subnet_cidr` | Subnet CIDR block (default: `10.0.1.0/24`) |
| `vcn_display_name` | VCN name in the console |
| `subnet_display_name` | Subnet name in the console |
| `instance_display_name` | Instance name in the console |
| `instance_shape` | Compute shape (default: `VM.Standard.A1.Flex`) |
| `instance_ocpus` | Number of OCPUs (default: `1`, validated 1–4) |
| `instance_memory_in_gbs` | Memory in GB (default: `6`, validated 1–24) |
| `instance_image_ocid` | Explicit image OCID (leave empty for auto-select) |

### `main.tf`
- **`data "oci_identity_availability_domains"`** – Fetches availability domains for instance placement.
- **`data "oci_core_images"`** – Queries the latest Oracle Linux image for the chosen shape.
- **`locals`** – Picks the explicit image OCID if provided, otherwise uses the latest from the data source.
- **`oci_core_vcn`** – Creates the Virtual Cloud Network.
- **`oci_core_subnet`** – Creates the public subnet inside the VCN.
- **`oci_core_instance`** – Launches the compute instance with the configured shape, image, and networking.

### `outputs.tf`
- **`instance_id`** – OCID of the created instance.
- **`instance_state`** – Lifecycle state (expected: `RUNNING`).
- **`instance_public_ip`** – Public IP for SSH access.




