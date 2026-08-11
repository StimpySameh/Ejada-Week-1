# All resources are organized in dedicated files:
#   - network.tf       → VCN, gateways, route tables, security lists, subnets
#   - filestorage.tf   → File System, mount target, export
#   - compute.tf       → Private compute instance (cloud-init bootstrapped)
#   - loadbalancer.tf  → Public Application Load Balancer
#   - bastion.tf       → OCI Bastion service for SSH access
#   - datasources.tf   → Data sources (ADs, images, services)
#   - locals.tf        → Derived values and naming conventions
#   - variables.tf     → All input variables with validations
#   - outputs.tf       → Output values
#   - provider.tf      → OCI provider configuration
#   - versions.tf      → Terraform and provider version constraints
