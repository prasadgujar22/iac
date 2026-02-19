# Infrastructure as Code (IaC) - Home Lab

Automated infrastructure provisioning for home lab environments using Packer and Terraform across multiple hypervisors (Proxmox VE and vSphere).

## Overview

This repository contains Infrastructure as Code configurations for automating VM template creation and infrastructure deployment in a home lab environment. The project supports multiple hypervisors and operating systems, focusing on reproducible, version-controlled infrastructure using modern DevOps practices.

## Repository Structure

```
iac/
├── alma_linux/
│   ├── packer/
│   │   ├── almalinux.pkr.hcl                    # Packer build configuration
│   │   ├── vars.pkrvars.hcl                     # Packer variables
│   │   ├── README.md
│   │   ├── http/
│   │   │   ├── ks.cfg                           # Kickstart config (production)
│   │   │   ├── ks.cfg_working
│   │   │   ├── ks.cfg.bkp
│   │   │   └── ks.cfg.backp2
│   │   └── archives/                            # Previous iterations
│   │       ├── almalinux.pkr.hcl_working
│   │       └── almalinux.pkr.hcl_working_updated
│   │
│   └── terraform/
│       ├── main.tf                              # Main infrastructure code
│       ├── provider.tf                          # Provider configuration
│       ├── variables.tf                         # Variable definitions
│       ├── terraform.tfvars                     # Variable values (gitignored)
│       ├── secret.tfvars                        # Secrets file (gitignored)
│       ├── terraform.tfstate                    # State file (gitignored)
│       ├── terraform.tfstate.backup             # State backup (gitignored)
│       └── README.md
│
├── oracle_linux/
│   ├── .gitkeep
│   └── packer/
│       ├── oraclelinux.pkr.hcl                  # Packer build configuration
│       ├── README.md
│       ├── .gitignore
│       └── http/
│           └── ks.cfg                           # Kickstart configuration
│
├── ubuntu24-04-vms/
│   ├── LICENSE
│   ├── README.md
│   │
│   ├── Proxmox/
│   │   ├── Packer/
│   │   │   ├── ubuntu-2404.pkr.hcl              # Packer build config
│   │   │   ├── variables.pkrvars.hcl            # Variable definitions
│   │   │   ├── secrets.pkrvars.hcl              # Secrets (gitignored)
│   │   │   ├── secrets.pkrvars.hcl.example      # Secrets template
│   │   │   ├── build.sh                         # Build helper script
│   │   │   ├── LICENSE.txt
│   │   │   ├── README.md
│   │   │   ├── packer_proxmox_ubuntu2404_guide.md
│   │   │   └── http/                            # Cloud-init configs
│   │   │       ├── meta-data
│   │   │       ├── user-data
│   │   │       ├── user-data.backup
│   │   │       └── user-data.nw
│   │   │
│   │   ├── Terraform/                           # PVE01 deployments
│   │   │   ├── main.tf                          # Main infrastructure
│   │   │   ├── variables.tf                     # Variable definitions
│   │   │   ├── terraform.tfvars                 # Variables (gitignored)
│   │   │   ├── secrets.tfvars                   # Secrets (gitignored)
│   │   │   ├── secrets.auto.tfvars              # Auto-loaded secrets (gitignored)
│   │   │   ├── secrets.auto.tfvars.example      # Secrets template
│   │   │   ├── build.sh                         # Helper script
│   │   │   ├── README.md
│   │   │   ├── blog-post.md
│   │   │   ├── terraform.tfstate                # State (gitignored)
│   │   │   ├── terraform.tfstate.backup         # State backup (gitignored)
│   │   │   └── tfplan                           # Plan file (gitignored)
│   │   │
│   │   └── Terraform_PVE02/                     # PVE02 (secondary node) deployments
│   │       ├── main.tf                          # Main infrastructure
│   │       ├── variables.tf                     # Variable definitions
│   │       ├── secrets.auto.tfvars              # Auto-loaded secrets (gitignored)
│   │       ├── secrets.auto.tfvars.example      # Secrets template
│   │       ├── build.sh                         # Helper script
│   │       └── README.md
│   │
│   └── vSphere/
│       ├── Packer/
│       │   ├── ubuntu-24-04.pkr.hcl             # Packer build config
│       │   ├── variables.pkrvars.hcl            # Variable definitions
│       │   ├── secrets.pkrvars.hcl.example      # Secrets template
│       │   ├── build.sh                         # Build helper script
│       │   ├── README.md
│       │   ├── blog.md
│       │   └── http/                            # Cloud-init configs
│       │       ├── meta-data
│       │       └── user-data
│       │
│       └── Terraform/
│           ├── main.tf                          # Main infrastructure
│           ├── variables.tf                     # Variable definitions
│           ├── output.tf                        # Output definitions
│           ├── vars.auto.tfvars                 # Auto-loaded variables
│           ├── terraform.tfvars.example         # Variable template
│           ├── README.md
│           ├── blog_terraform_vsphere.md
│           └── templates/                       # Cloud-init templates
│               ├── metadata.yaml
│               └── userdata.yaml
│
├── .gitignore
└── README.md                                    # This file
```

## Technologies Used

| Tool | Purpose |
|------|---------|
| **Packer** | Automated VM template creation |
| **Terraform** | Infrastructure provisioning and management |
| **Proxmox VE** | Open-source virtualization platform |
| **vSphere/VMware** | Enterprise virtualization platform |
| **Cloud-init** | VM initialization and configuration |

## Supported Configurations

### Operating Systems
- **AlmaLinux 9** - Enterprise-grade RHEL-compatible Linux
- **Oracle Linux** - Enterprise Linux compatible with RHEL
- **Ubuntu 24.04 LTS** - Long-term support Ubuntu release

### Hypervisors
- **Proxmox VE** - Open-source virtualization with full support for AlmaLinux, Oracle Linux, and Ubuntu
- **vSphere/VMware** - Enterprise virtualization support for Ubuntu 24.04 LTS

## Prerequisites

Before using this repository, ensure you have the following installed:

- [Packer](https://www.packer.io/downloads) (v1.9+)
- [Terraform](https://www.terraform.io/downloads) (v1.5+)
- Access to a Proxmox VE environment
- SSH key pair for VM authentication

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/prasadgujar22/iac.git
cd iac
```

### 2. Configure Environment Variables

#### For Proxmox VE:

```bash
export PROXMOX_URL="https://your-proxmox-host:8006/api2/json"
export PROXMOX_USERNAME="root@pam"
export PROXMOX_PASSWORD="your-password"
# Or use API token
export PROXMOX_API_TOKEN_ID="your-token-id"
export PROXMOX_API_TOKEN_SECRET="your-token-secret"
```

#### For vSphere/VMware:

```bash
export VSPHERE_SERVER="your-vcenter-host"
export VSPHERE_USER="your-username"
export VSPHERE_PASSWORD="your-password"
export VSPHERE_DATACENTER="your-datacenter"
```

### 3. Build VM Templates

#### AlmaLinux 9 Template (Proxmox)

```bash
cd alma_linux/packer
packer init .
packer validate -var-file="vars.pkrvars.hcl"
packer build -var-file="vars.pkrvars.hcl" almalinux.pkr.hcl
```

#### Ubuntu 24.04 Template on Proxmox

```bash
cd ubuntu24-04-vms/Proxmox/Packer
packer init .
packer validate -var-file="secrets.pkrvars.hcl" -var-file="variables.pkrvars.hcl"
packer build -var-file="secrets.pkrvars.hcl" -var-file="variables.pkrvars.hcl" ubuntu-2404.pkr.hcl
```

#### Ubuntu 24.04 Template on vSphere

```bash
cd ubuntu24-04-vms/vSphere/Packer
packer init .
packer validate -var-file="secrets.pkrvars.hcl" -var-file="variables.pkrvars.hcl"
packer build -var-file="secrets.pkrvars.hcl" -var-file="variables.pkrvars.hcl" ubuntu-24-04.pkr.hcl
```

## Configuration

### Choosing Your Hypervisor

- **Proxmox VE**: Choose this for open-source, cost-effective solutions. Both AlmaLinux and Ubuntu are fully supported.
- **vSphere**: Choose this for enterprise environments with existing VMware infrastructure. Ubuntu 24.04 is fully supported.

### Packer Variables

Common variables that can be customized (see specific `variables.pkrvars.hcl` files):

| Variable | Description |
|----------|-------------|
| `proxmox_node` or `vcenter_server` | Hypervisor host/server |
| `vm_id` or `vm_name` | VM template identifier |
| `iso_file` | ISO image path in hypervisor |
| `ssh_username` | SSH user for provisioning (usually `root` or `ubuntu`) |
| `cores` | CPU cores allocated |
| `memory` | Memory in MB |
| `disk_size` | Disk size in GB |

### Terraform Variables

Infrastructure deployment variables configured in `terraform.tfvars` or `.auto.tfvars`:

```hcl
# Proxmox example
proxmox_host     = "your-proxmox-host"
template_name    = "ubuntu-24-04"
target_node      = "pve01"  # or "pve02" for PVE02
vm_count         = 3

# vSphere example
vsphere_vcenter  = "vcenter.example.com"
template_name    = "ubuntu-24-04"
datacenter       = "dc1"
dns_servers      = ["8.8.8.8", "8.8.4.4"]
```

## Directory Details

### alma_linux/

Contains Packer and Terraform configurations for building and deploying AlmaLinux 9 VMs on Proxmox VE:

- **packer/** - Packer HCL configuration files, variables, and kickstart configurations
- **terraform/** - Terraform code for deploying AlmaLinux VMs from templates

### oracle_linux/

Contains Packer configurations for building Oracle Linux VM templates on Proxmox VE:

- **packer/** - Packer HCL configuration files and kickstart configurations for Oracle Linux
  - `oraclelinux.pkr.hcl` - Packer build configuration
  - `http/` - Kickstart configuration files

### ubuntu24-04-vms/

Contains configurations for Ubuntu 24.04 LTS VMs across multiple hypervisors:

#### Proxmox/

Configurations for Proxmox VE hypervisor:

- **Packer/** - Ubuntu 24.04 template creation with cloud-init
- **Terraform/** - Terraform configurations for single Proxmox node deployments
- **Terraform_PVE02/** - Terraform configurations for secondary Proxmox node (PVE02) deployments
- **build.sh** - Helper scripts for building templates

#### vSphere/

Configurations for VMware vSphere/ESXi hypervisor:

- **Packer/** - Ubuntu 24.04 template creation for vSphere with cloud-init
- **Terraform/** - Terraform configurations for vSphere VM deployments
- **build.sh** - Helper scripts for building templates

## Workflow Overview

This repository follows a two-stage process:

1. **Template Creation (Packer)**: Build base VM templates with your OS of choice
   - Automates VM provisioning with minimal dependencies
   - Configures storage, network, and SSH settings
   - Outputs a reusable template for rapid VM deployment

2. **Infrastructure Deployment (Terraform)**: Deploy VMs from templates at scale
   - Uses templates created by Packer
   - Manages VM lifecycle, networking, and configuration
   - Supports both single-node and multi-node deployments
   - Can be version-controlled and managed through CI/CD

### Typical Usage

```
1. Customize Packer variables for your environment
   └─> Run: packer init && packer validate && packer build

2. Verify template was created successfully in hypervisor

3. Customize Terraform variables for your deployment
   └─> Run: terraform init && terraform plan && terraform apply

4. Access deployed VMs via SSH or console
```

## Best Practices Implemented

- **Version Control**: All infrastructure code is tracked in Git
- **Modular Design**: Separate configurations for different OS and hypervisor combinations
- **Multi-Cloud Support**: Works with both open-source (Proxmox) and enterprise (vSphere) platforms
- **Idempotent Operations**: Scripts and configurations are designed to be re-runnable safely
- **Security**: Sensitive data excluded via `.gitignore`
  - `secrets.pkrvars.hcl` files for Packer credentials
  - `secrets.auto.tfvars` / `secret.tfvars` files for Terraform credentials
  - Template files (`*.example`) provided for reference

### Secrets Management

1. Create your secrets files from the provided examples:
   ```bash
   cp secrets.pkrvars.hcl.example secrets.pkrvars.hcl
   cp secrets.auto.tfvars.example secrets.auto.tfvars
   ```

2. Edit the files with your actual credentials (these are gitignored)

3. For production environments, consider:
   - Using Terraform Cloud/Enterprise with variable sets
   - AWS Secrets Manager or HashiCorp Vault for credential management
   - CI/CD pipeline integration with secure credential handling

## Troubleshooting

### Packer Issues

1. **Packer build fails with network timeout**
   - Verify hypervisor network configuration
   - Check firewall rules for HTTP/HTTPS access
   - Ensure ISO files are accessible

2. **SSH connection refused during provisioning**
   - Verify SSH service is enabled in the template
   - Check that cloud-init or kickstart scripts properly configure SSH
   - Verify SSH port is accessible from the Packer host

3. **Template creation succeeds but VM won't boot**
   - Check boot order settings in hypervisor
   - Verify BIOS/UEFI settings match the template configuration
   - Validate disk and memory allocations

### Terraform Issues

1. **Authentication fails**
   - Verify API credentials and tokens are correct
   - For Proxmox: Check token expiration
   - For vSphere: Verify user permissions in vCenter

2. **VM deployment is slow or times out**
   - Check network connectivity to hypervisor
   - Verify template exists and is accessible
   - Review resource availability on target node

3. **Terraform state conflicts**
   - Back up your state files regularly
   - Use `terraform state` commands with caution
   - Consider using remote state backends for production

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-template`)
3. Commit your changes (`git commit -am 'Add new template'`)
4. Push to the branch (`git push origin feature/new-template`)
5. Create a Pull Request

## License

This project is for personal/home lab use. Feel free to adapt for your own infrastructure needs.

## Author

**Prasad Gujar** - [GitHub Profile](https://github.com/prasadgujar22)

## Acknowledgments

- [Proxmox VE Documentation](https://pve.proxmox.com/pve-docs/)
- [Packer Documentation](https://developer.hashicorp.com/packer/docs)
- [Terraform Documentation](https://developer.hashicorp.com/terraform/docs)

