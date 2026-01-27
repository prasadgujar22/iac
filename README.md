# Infrastructure as Code (IaC) - Home Lab

Automated infrastructure provisioning for home lab environments using Packer, Terraform, and shell scripts targeting Proxmox VE.

## Overview

This repository contains Infrastructure as Code configurations for automating VM template creation and deployment in a home lab environment. The project focuses on creating reproducible, version-controlled infrastructure using modern DevOps practices.

## Repository Structure

```
iac/
├── alma_linux/          # AlmaLinux 9 VM template configurations
├── ubuntu24-04-vms/     # Ubuntu 24.04 LTS VM configurations
├── .gitignore
└── README.md
```

## Technologies Used

| Tool | Purpose |
|------|---------|
| **Packer** | Automated VM template creation |
| **Terraform** | Infrastructure provisioning and management |
| **Shell Scripts** | Automation and configuration tasks |
| **Proxmox VE** | Virtualization platform |

## Supported Operating Systems

- **AlmaLinux 9** - Enterprise-grade RHEL-compatible Linux
- **Ubuntu 24.04 LTS** - Long-term support Ubuntu release

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

Create a `.env` file or export the following variables:

```bash
export PROXMOX_URL="https://your-proxmox-host:8006/api2/json"
export PROXMOX_USERNAME="root@pam"
export PROXMOX_PASSWORD="your-password"
# Or use API token
export PROXMOX_API_TOKEN_ID="your-token-id"
export PROXMOX_API_TOKEN_SECRET="your-token-secret"
```

### 3. Build VM Templates

#### AlmaLinux 9 Template

```bash
cd alma_linux
packer init .
packer validate .
packer build .
```

#### Ubuntu 24.04 Template

```bash
cd ubuntu24-04-vms
packer init .
packer validate .
packer build .
```

## Configuration

### Packer Variables

Common variables that can be customized:

| Variable | Description | Default |
|----------|-------------|---------|
| `proxmox_node` | Proxmox node name | - |
| `vm_id` | VM template ID | - |
| `vm_name` | Template name | - |
| `iso_file` | ISO image path | - |
| `ssh_username` | SSH user for provisioning | - |
| `cores` | CPU cores | 2 |
| `memory` | Memory in MB | 2048 |
| `disk_size` | Disk size | 20G |

### Terraform Variables

Infrastructure variables for VM deployment can be configured in `terraform.tfvars`:

```hcl
proxmox_host     = "your-proxmox-host"
template_name    = "your-template-name"
target_node      = "your-node"
vm_count         = 1
```

## Directory Details

### alma_linux/

Contains Packer configurations for building AlmaLinux 9 VM templates on Proxmox VE:

- HCL configuration files for Packer
- Kickstart or cloud-init configurations
- Post-installation scripts

### ubuntu24-04-vms/

Contains configurations for Ubuntu 24.04 LTS VMs:

- Packer template definitions
- Autoinstall/cloud-init configurations
- Provisioning scripts

## Best Practices Implemented

- **Version Control**: All infrastructure code is tracked in Git
- **Modular Design**: Separate configurations for different OS templates
- **Idempotent Operations**: Scripts and configurations are designed to be re-runnable
- **Security**: Sensitive data excluded via `.gitignore`

## Troubleshooting

### Common Issues

1. **Packer build fails with network timeout**
   - Verify Proxmox network configuration
   - Check firewall rules for HTTP/HTTPS access

2. **SSH connection refused during provisioning**
   - Ensure SSH service is enabled in the template
   - Verify SSH port is accessible from the Packer host

3. **Template creation succeeds but VM won't boot**
   - Check boot order settings
   - Verify BIOS/UEFI settings match the template

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

