# Week 3 – OKE Cluster with Modular Terraform on OCI

## Architecture

```
                    ┌──────────────────────────────────────────────────┐
                    │              VCN (10.0.0.0/16)                   │
                    │                                                  │
  Internet ────► IGW    ┌──────────────────────────┐                  │
                    │   │ API Endpoint Subnet       │                  │
                    │   │ 10.0.0.0/24 (public)      │                  │
                    │   │  ┌──────────────────────┐ │                  │
                    │   │  │ K8s API (port 6443)  │ │                  │
                    │   │  └──────────────────────┘ │                  │
                    │   └───────────┬───────────────┘                  │
                    │               │                                   │
                    │   ┌───────────▼───────────────┐   NAT GW ──► Internet
                    │   │ Worker Subnet             │                  │
                    │   │ 10.0.1.0/24 (private)     │   SGW ────► OCI Services
                    │   │  ┌──────────────────────┐ │                  │
                    │   │  │ OKE Worker Nodes     │ │                  │
                    │   │  │ + Block Volume (50G) │ │                  │
                    │   │  └──────────────────────┘ │                  │
                    │   └───────────┬───────────────┘                  │
                    │               │                                   │
                    │   ┌───────────▼───────────────┐                  │
                    │   │ Pod Subnet (VCN-Native)   │                  │
                    │   │ 10.0.64.0/18 (private)    │                  │
                    │   └───────────────────────────┘                  │
                    │                                                  │
                    │   ┌───────────────────────────┐                  │
                    │   │ Service LB Subnet         │                  │
                    │   │ 10.0.2.0/24 (public)      │                  │
                    │   │  ┌──────────────────────┐ │                  │
                    │   │  │ K8s LoadBalancer Svc  │ │                  │
                    │   │  └──────────────────────┘ │                  │
                    │   └───────────────────────────┘                  │
                    └──────────────────────────────────────────────────┘
```

## Modules

### Subnet Module (`modules/subnet/`)
Generic, reusable module that creates:
- **Subnet** – configurable CIDR, DNS label, public/private
- **Route Table** – dynamic route rules via variable
- **Security List** – dynamic ingress/egress rules (TCP, UDP, ICMP)
- **VCN Flow Logs** – conditional, with optional external log group

### OKE Module (`modules/oke/`)
Generic, reusable module that creates:
- **OKE Cluster** – supports VCN-native & Flannel CNI
- **Managed Node Pool** – conditional, with Flex shape support

## Key Design Decisions

| Dynamic Blocks | Security rules, route rules, shape configs |
| Conditions | Flow logs, node pool creation, Flex shapes, CNI type |
| Kubernetes Version | **`v1.33.10`** (aligned with `me-jeddah-1` region supported versions) |
| Compute Shape | `VM.Standard.E4.Flex` (x86, 1 OCPU / 6GB RAM) |
| Image Selection | Dynamic architecture & version matching (`OKE-1.33.10` in `locals.tf`) |
| Service Gateway | **Mandatory** – always created |
| Pod Networking | VCN-native (`OCI_VCN_IP_NATIVE`) with dedicated pod subnet (`10.0.64.0/18`) |
| Security Lists | Comprehensive ingress/egress rules for API Endpoint (6443/12250), Worker nodes, and Pods |
| No Hardcoding | All values flow through variables from root config |
| Block Volume | OCI Block Volume attached via CSI driver PV/PVC (`blockvolume.csi.oraclecloud.com`) |
| LoadBalancer | Kubernetes Service `type=LoadBalancer` with OCI flexible LB annotations |

## File Structure

```
Week-3/
├── modules/
│   ├── subnet/
│   │   ├── main.tf          # Subnet, route table, security list, flow logs
│   │   ├── variables.tf     # Module input variables
│   │   └── outputs.tf       # Module outputs
│   └── oke/
│       ├── main.tf          # OKE cluster + node pool
│       ├── variables.tf     # Module input variables
│       └── outputs.tf       # Module outputs
├── main.tf                  # Project overview
├── versions.tf              # Terraform & provider versions
├── provider.tf              # OCI provider configuration
├── variables.tf             # All root input variables
├── terraform.tfvars         # Variable values (v1.33.10, E4.Flex shape)
├── network.tf               # VCN, gateways, 4x subnet module calls with complete SL rules
├── oke.tf                   # OKE module call
├── storage.tf               # External block volume
├── kubernetes.tf            # Generated K8s manifests
├── datasources.tf           # Data sources (ADs, services, OKE images)
├── locals.tf                # Derived values, architecture/version-aware image regex
├── outputs.tf               # Root outputs
└── manifests/               # Generated K8s YAML files
    ├── 01-namespace.yaml
    ├── 02-storageclass.yaml
    ├── 03-pv.yaml
    ├── 04-pvc.yaml
    ├── 05-deployment.yaml
    └── 06-service-lb.yaml
```

## Usage

```bash
# 1. Navigate to the Week-3 directory
cd Week-3

# 2. Initialize Terraform
terraform init

# 3. Edit terraform.tfvars with your compartment and SSH key details

# 4. Review the plan
terraform plan

# 5. Apply infrastructure
terraform apply

# 6. Configure kubectl
# Local PC (PowerShell):
oci ce cluster create-kubeconfig \
  --cluster-id <cluster_ocid> \
  --file "$env:USERPROFILE\.kube\config" \
  --region me-jeddah-1 \
  --token-version 2.0.0

# OCI Cloud Shell (Private VCN Network):
oci ce cluster create-kubeconfig \
  --cluster-id <cluster_ocid> \
  --file $HOME/.kube/config \
  --region me-jeddah-1 \
  --token-version 2.0.0 \
  --kube-endpoint PRIVATE_ENDPOINT

# 7. Deploy the Kubernetes application & LoadBalancer
kubectl apply -f manifests/

# 8. Verify deployment & LoadBalancer IP
kubectl get nodes
kubectl get svc -n nginx-app
curl http://<LOAD_BALANCER_EXTERNAL_IP>
```

## Troubleshooting & Key Requirements

- **Kubernetes Versioning**: Ensure `kubernetes_version` (e.g. `v1.33.10`) matches active supported OKE versions in `me-jeddah-1`.
- **Node Image Matching**: `locals.tf` dynamically matches `aarch64` images for ARM (`VM.Standard.A1.Flex`) shapes and standard x86 images for Intel/AMD (`VM.Standard.E4.Flex`) shapes.
- **Network Security Lists**: The API endpoint security list MUST allow stateful ingress on ports `6443` and `12250` from the worker subnet (`10.0.1.0/24`) and port `6443` from the pod subnet (`10.0.64.0/18`) to avoid node registration timeouts.
- **Service Gateway**: Mandatory for worker nodes to communicate with internal OCI infrastructure services.
- **LoadBalancer Provisioning**: Executed dynamically by the OCI Cloud Controller Manager (CCM) upon applying `06-service-lb.yaml`.
