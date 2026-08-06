# Terraform OCI – Free Tier Compute Instance

This project uses **Terraform** to provision a compute instance on **Oracle Cloud Infrastructure (OCI)** using the Always Free tier resources.

## What It Creates

| Resource | Details |
|----------|---------|
| **VCN** | Virtual Cloud Network (`10.0.0.0/16`) |
| **Subnet** | Public subnet (`10.0.1.0/24`) with public IPs enabled |
| **Compute Instance** | ARM-based `VM.Standard.A1.Flex` (1 OCPU, 6 GB RAM) with Oracle Linux |

## File Structure

| File | Purpose |
|------|---------|
| `provider.tf` | Configures the OCI provider with API key authentication |
| `versions.tf` | Sets Terraform (`>= 1.5.0`) and OCI provider (`>= 5.0.0`) version constraints |
| `variables.tf` | Declares all input variables (tenancy, user, region, compartment, etc.) |
| `terraform.tfvars` | Supplies actual values for the declared variables |
| `main.tf` | Defines all infrastructure resources (VCN, subnet, instance) |
| `outputs.tf` | Outputs the instance ID, state, and public IP after apply |

---

## Code Breakdown

### `versions.tf`

- **`terraform` block** – Requires Terraform `>= 1.5.0` and the `oracle/oci` provider `>= 5.0.0`.

### `provider.tf`

- **`provider "oci"` block** – Authenticates to OCI using API key credentials (tenancy OCID, user OCID, fingerprint, private key path, and region).

### `variables.tf`

- **`tenancy_ocid`** – Your OCI tenancy identifier.
- **`user_ocid`** – The API user's identifier.
- **`fingerprint`** – Fingerprint of the uploaded API public key.
- **`private_key_path`** – Local path to the `.pem` private key file.
- **`region`** – OCI region (defaults to `me-jeddah-1`).
- **`compartment_ocid`** – The compartment where resources are created.
- **`instance_display_name`** – Name shown in the console (defaults to `my first instance`).
- **`instance_image_ocid`** – Optional explicit image OCID; if empty, an image is auto-selected.

### `main.tf`

- **`data "oci_identity_availability_domains" "ads"`** – Fetches the list of availability domains in the compartment (used to place the instance).
- **`resource "oci_core_vcn" "this"`** – Creates a Virtual Cloud Network with CIDR `10.0.0.0/16` and DNS label `freetiervcn`.
- **`resource "oci_core_subnet" "this"`** – Creates a public subnet (`10.0.1.0/24`) inside the VCN, allowing public IPs on VNICs.
- **`data "oci_core_images" "alma_linux"`** – Queries for the latest Oracle Linux image compatible with the `VM.Standard.A1.Flex` shape, sorted by newest first.
- **`locals` block** – Picks the image: uses `instance_image_ocid` if provided, otherwise falls back to the first image returned by the data source.
- **`resource "oci_core_instance" "this"`** – Launches the compute instance with:
  - `shape_config` – 1 OCPU and 6 GB RAM.
  - `source_details` – Boots from the selected image.
  - `create_vnic_details` – Attaches to the subnet and assigns a public IP.

### `outputs.tf`

- **`instance_id`** – The OCID of the created instance.
- **`instance_state`** – Lifecycle state (expected: `RUNNING`).
- **`instance_public_ip`** – The assigned public IP address for SSH access.

---

## Prerequisites

- Terraform `>= 1.5.0` installed
- An OCI account with API key configured
- A `.pem` private key file for authentication

## Usage

```bash
terraform init      # Download the OCI provider
terraform plan      # Preview the infrastructure changes
terraform apply     # Create the resources
terraform destroy   # Tear down everything
```

## Configuration

All variable values are set in `terraform.tfvars`. Key settings:

- **Region:** `me-jeddah-1`
- **Shape:** `VM.Standard.A1.Flex` (ARM, Always Free eligible)
- **OS:** Oracle Linux (auto-selected or set via `instance_image_ocid`)
