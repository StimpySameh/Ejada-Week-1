# Week 2 – OCI Infrastructure with Load Balancer, Private Compute & File Storage

## Architecture

```
                    ┌─────────────────────────────────────────┐
                    │            VCN (10.0.0.0/16)            │
                    │                                         │
  Internet ────►  IGW   ┌──────────────────────┐              │
                    │   │  Public Subnet        │              │
                    │   │  10.0.1.0/24          │              │
                    │   │                       │              │
                    │   │  ┌─────────────────┐  │              │
                    │   │  │ Load Balancer    │  │              │
                    │   │  │ (port 80)       │  │              │
                    │   │  └────────┬────────┘  │              │
                    │   │           │            │              │
                    │   │  ┌────────┴────────┐  │              │
                    │   │  │  Jump Host      │  │              │
                    │   │  │  (SSH gateway)  │  │              │
                    │   │  └────────┬────────┘  │              │
                    │   └───────────┼──────────┘              │
                    │               │                          │
                    │   ┌───────────▼──────────┐              │
                    │   │  Private Subnet       │              │
                    │   │  10.0.2.0/24          │              │
                    │   │                       │   NAT GW ──► Internet
                    │   │  ┌─────────────────┐  │              │
                    │   │  │ Compute Instance │  │   SGW ────► OCI Services
                    │   │  │ (app:8080)      │  │              │
                    │   │  └────────┬────────┘  │              │
                    │   │           │ NFS mount  │              │
                    │   │  ┌────────▼────────┐  │              │
                    │   │  │ FSS Mount Target│  │              │
                    │   │  │ (File Storage)  │  │              │
                    │   │  └─────────────────┘  │              │
                    │   └───────────────────────┘              │
                    └─────────────────────────────────────────┘
```

## Resources Created

| Resource                  | File              | Description                                    |
|--------------------------|-------------------|------------------------------------------------|
| VCN                      | `network.tf`      | Virtual Cloud Network with DNS                 |
| Internet Gateway         | `network.tf`      | Public internet access for LB subnet           |
| NAT Gateway              | `network.tf`      | Outbound internet for private subnet           |
| Service Gateway           | `network.tf`      | Access to OCI services (yum, object storage)   |
| Public Subnet            | `network.tf`      | Hosts the Load Balancer and Jump Host          |
| Private Subnet           | `network.tf`      | Hosts compute instance and FSS mount target    |
| Route Tables (×2)        | `network.tf`      | Public (IGW) and Private (NAT+SGW) routing     |
| Security Lists (×2)      | `network.tf`      | Public (HTTP/HTTPS/SSH) and Private (app+NFS)  |
| Compute Instance         | `compute.tf`      | ARM A1 Flex instance running a Python web app  |
| Jump Host                | `jumphost.tf`     | Public SSH gateway to reach private instance   |
| Load Balancer            | `loadbalancer.tf` | Flexible LB with HTTP listener on port 80      |
| File System              | `filestorage.tf`  | OCI File Storage for application files         |
| Mount Target             | `filestorage.tf`  | NFS endpoint in the private subnet             |
| Export                   | `filestorage.tf`  | Makes file system accessible via mount target  |

## File Structure

```
Week-2/
├── main.tf              # Project overview
├── versions.tf          # Terraform & provider versions
├── provider.tf          # OCI provider configuration
├── variables.tf         # All input variables with validations
├── locals.tf            # Derived values & naming conventions
├── datasources.tf       # Data sources (ADs, images, services)
├── network.tf           # VCN, gateways, routes, security, subnets
├── compute.tf           # Private compute instance
├── jumphost.tf          # Jump Host (SSH gateway in public subnet)
├── loadbalancer.tf      # Application Load Balancer
├── filestorage.tf       # OCI File Storage Service
├── outputs.tf           # Output values
├── terraform.tfvars     # Variable values (git-ignored)
├── .gitignore           # Git ignore rules
├── README.md            # This file
└── templates/
    └── cloud-init.yaml  # Cloud-init script template
```

## Code Quality

- **No hardcoded values** – all arguments use `var.*` or `local.*`
- **Variables** have descriptions, types, defaults, and validations
- **Locals** derive naming prefixes, image selection, and tags
- **Separated files** – each concern has its own `.tf` file
- **`.tfvars`** holds all actual values separate from definitions
- **Freeform tags** applied to every resource for tracking

## Usage

```bash
# 1. Navigate to the Week-2 directory
cd Week-2

# 2. Initialize Terraform
terraform init

# 3. Edit terraform.tfvars with your values
#    (especially ssh_public_key for instance access)

# 4. Review the plan
terraform plan

# 5. Apply
terraform apply

# 6. Access the app via Load Balancer
#    The app URL will be shown in the outputs
```

## Accessing the Private Instance

Since the app server has no public IP, use the **Jump Host** as an SSH gateway:

```bash
# One-command SSH through the jump host (shown in terraform output)
ssh -J opc@<jumphost_public_ip> opc@<app_server_private_ip>
```

Or in two steps:
```bash
# Step 1: SSH into the jump host
ssh opc@<jumphost_public_ip>

# Step 2: From the jump host, SSH into the private instance
ssh opc@<app_server_private_ip>
```

## Notes

- The compute instance uses **cloud-init** to automatically mount FSS and deploy the app
- The Python web app is stored on the **OCI File Storage** mount at `/mnt/app-data/www/`
- The Load Balancer health checks hit `/health` on port 8080
- Local Terraform state files are ignored by `.gitignore`
