# Wiki: Infrastructure as Code (IaC) Home Lab

**Author:** Prasad Gujar
**Repository:** [prasadgujar22/iac](https://github.com/prasadgujar22/iac)

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Architecture](#2-architecture)
3. [Prerequisites](#3-prerequisites)
4. [Repository Structure](#4-repository-structure)
5. [Supported Platforms](#5-supported-platforms)
6. [Getting Started](#6-getting-started)
7. [Packer: Building VM Templates](#7-packer-building-vm-templates)
   - [AlmaLinux 9 on Proxmox](#71-almalinux-9-on-proxmox)
   - [Oracle Linux 9 on Proxmox](#72-oracle-linux-9-on-proxmox)
   - [Ubuntu 24.04 on Proxmox](#73-ubuntu-2404-on-proxmox)
   - [Ubuntu 24.04 on vSphere](#74-ubuntu-2404-on-vsphere)
8. [Terraform: Deploying VMs](#8-terraform-deploying-vms)
   - [AlmaLinux 9 VMs on Proxmox](#81-almalinux-9-vms-on-proxmox)
   - [Ubuntu 24.04 VMs on Proxmox (PVE01)](#82-ubuntu-2404-vms-on-proxmox-pve01)
   - [Ubuntu 24.04 VMs on Proxmox (PVE02)](#83-ubuntu-2404-vms-on-proxmox-pve02)
   - [Ubuntu 24.04 VMs on vSphere](#84-ubuntu-2404-vms-on-vsphere)
9. [Ansible: Post-Deployment Configuration](#9-ansible-post-deployment-configuration)
10. [Secrets Management](#10-secrets-management)
11. [Cloud-init & Kickstart Reference](#11-cloud-init--kickstart-reference)
12. [Configuration Reference](#12-configuration-reference)
13. [Troubleshooting](#13-troubleshooting)
14. [Best Practices](#14-best-practices)
15. [Contributing](#15-contributing)

---

## 1. Project Overview

This repository provides a fully automated Infrastructure as Code (IaC) workflow for home lab environments. It covers the complete VM lifecycle — from base image creation to running, configured virtual machines — across two popular hypervisors and three enterprise Linux distributions.

### Core Toolchain

| Tool | Role |
|------|------|
| **Packer** | Builds immutable, reusable VM templates from ISO images |
| **Terraform** | Clones and configures VMs from templates at scale |
| **Ansible** | Handles application-level post-deployment configuration |
| **Cloud-init** | First-boot customization (Ubuntu) |
| **Kickstart** | Automated OS installation (RHEL-based distros) |

### Design Philosophy

- **Two-stage pipeline:** Build once (Packer template), deploy many times (Terraform clone).
- **Secrets never committed:** All credential files are gitignored; `.example` templates are provided.
- **Idempotent operations:** Templates and Terraform plans are safe to re-run.
- **Multi-platform parity:** Consistent workflow regardless of hypervisor or OS choice.

---

## 2. Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Developer Machine                     │
│                                                          │
│  ┌──────────┐   packer build    ┌─────────────────────┐ │
│  │  ISO     │ ───────────────►  │   VM Template        │ │
│  │ (AlmaLinux│                  │ (Proxmox/vSphere)    │ │
│  │  Oracle  │                  └──────────┬──────────┘ │
│  │  Ubuntu) │                             │             │
│  └──────────┘                  terraform apply          │
│                                           │             │
│                                ┌──────────▼──────────┐  │
│                                │   Deployed VMs       │  │
│                                │  (cloud-init runs)   │  │
│                                └──────────┬──────────┘  │
│                                           │             │
│                               ansible-playbook          │
│                                           │             │
│                                ┌──────────▼──────────┐  │
│                                │  Configured VMs      │  │
│                                │  (WebLogic, Docker,  │  │
│                                │   app stack, etc.)   │  │
│                                └─────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### Stage 1 — Packer (Template Creation)

Packer boots a VM from an ISO, runs an automated installer (kickstart or cloud-init), installs guest agents and tooling (Docker, QEMU agent, etc.), resets machine-specific identifiers, and converts the VM into a reusable template.

### Stage 2 — Terraform (VM Deployment)

Terraform clones the template, customizes hardware (vCPU, RAM, disk), injects SSH keys, applies cloud-init for first-boot network/hostname configuration, and registers the VM in the hypervisor inventory.

### Stage 3 — Ansible (Application Configuration)

Ansible connects to running VMs via SSH and installs enterprise applications such as Oracle WebLogic Server, configuring domains, users, and services.

---

## 3. Prerequisites

### Required Tools

| Tool | Minimum Version | Notes |
|------|----------------|-------|
| Packer | v1.9 (tested: v1.12.0) | `packer` in `$PATH` |
| Terraform | v1.5 (tested: v1.5.7) | `terraform` in `$PATH` |
| Ansible | Latest stable | Required for WebLogic playbooks only |
| Git | Any | For cloning the repo |

### Hypervisor Access

**Proxmox VE:**
- Proxmox VE 8.x host (8.4.0+ recommended)
- API token with appropriate privileges (see [Secrets Management](#10-secrets-management))
- ISO images uploaded to Proxmox storage

**VMware vSphere:**
- vCenter Server 7.0.3+ or ESXi 6.7+
- Service account with VM creation/clone permissions
- ISO images accessible from a datastore

### Networking

- The Packer build host must be able to reach the hypervisor API.
- A temporary HTTP server port (default 8802) must be reachable from the hypervisor to serve kickstart/cloud-init files during Packer builds.
- Deployed VMs must be reachable via SSH for Terraform/Ansible post-deployment steps.

---

## 4. Repository Structure

```
iac/
├── .gitignore                   # Excludes secrets, state, and cache files
├── README.md                    # Quick-start documentation
├── wiki.md                      # This file
│
├── alma_linux/                  # AlmaLinux 9 (Proxmox)
│   ├── packer/
│   │   ├── almalinux.pkr.hcl   # Packer build definition
│   │   ├── vars.pkrvars.hcl    # Non-secret variables
│   │   └── http/
│   │       └── ks.cfg           # Kickstart autoinstall config
│   ├── terraform/
│   │   ├── main.tf              # VM resource definitions
│   │   ├── provider.tf          # Proxmox provider config
│   │   └── variables.tf         # Input variable declarations
│   └── ansible/
│       ├── playbook.yml         # Main playbook
│       ├── group_vars/
│       │   ├── all.yml          # Global vars
│       │   └── rhel.yml         # RHEL-family overrides
│       └── roles/weblogic/      # WebLogic Server role
│
├── oracle_linux/                # Oracle Linux 9 (Proxmox)
│   └── packer/
│       ├── oraclelinux.pkr.hcl
│       └── http/ks.cfg
│
└── ubuntu24-04-vms/             # Ubuntu 24.04 LTS (multi-hypervisor)
    ├── Proxmox/
    │   ├── Packer/
    │   │   ├── ubuntu-2404.pkr.hcl
    │   │   ├── variables.pkrvars.hcl
    │   │   ├── secrets.pkrvars.hcl.example
    │   │   ├── build.sh
    │   │   └── http/
    │   │       ├── user-data    # Cloud-init autoinstall
    │   │       └── meta-data
    │   ├── Terraform/           # PVE01 node
    │   │   ├── main.tf
    │   │   ├── variables.tf
    │   │   ├── secrets.auto.tfvars.example
    │   │   └── build.sh
    │   └── Terraform_PVE02/     # PVE02 node (secondary cluster member)
    │       ├── main.tf
    │       ├── variables.tf
    │       └── secrets.auto.tfvars.example
    └── vSphere/
        ├── Packer/
        │   ├── ubuntu-24-04.pkr.hcl
        │   ├── variables.pkrvars.hcl
        │   ├── secrets.pkrvars.hcl.example
        │   ├── build.sh
        │   └── http/
        │       ├── user-data
        │       └── meta-data
        └── Terraform/
            ├── main.tf
            ├── variables.tf
            ├── output.tf
            └── templates/
                ├── metadata.yaml
                └── userdata.yaml
```

---

## 5. Supported Platforms

### Operating Systems

| OS | Version | Installer | Hypervisors |
|----|---------|-----------|-------------|
| AlmaLinux | 9.x | Kickstart | Proxmox VE |
| Oracle Linux | 9.x | Kickstart | Proxmox VE |
| Ubuntu | 24.04 LTS | Cloud-init autoinstall | Proxmox VE, vSphere |

### Hypervisors

| Hypervisor | Type | Supported OS |
|------------|------|-------------|
| Proxmox VE 8.x | Open-source KVM/LXC | AlmaLinux 9, Oracle Linux 9, Ubuntu 24.04 |
| VMware vSphere / ESXi | Enterprise | Ubuntu 24.04 |

### Pre-installed Software in Templates

| Software | Version | Included In |
|----------|---------|------------|
| QEMU Guest Agent | Latest | All Proxmox templates |
| VMware Tools / open-vm-tools | Latest | vSphere templates |
| Docker CE | v27.5.1 (pinned) | Ubuntu templates |
| Cloud-init | Latest | All Ubuntu templates |
| Python 3 | Latest | All templates |

---

## 6. Getting Started

### Step 1: Clone the Repository

```bash
git clone https://github.com/prasadgujar22/iac.git
cd iac
```

### Step 2: Decide on Your Target

Choose the combination that matches your environment:

| Goal | Directory |
|------|-----------|
| AlmaLinux 9 template on Proxmox | `alma_linux/packer/` |
| AlmaLinux 9 VMs on Proxmox | `alma_linux/terraform/` |
| Oracle Linux 9 template on Proxmox | `oracle_linux/packer/` |
| Ubuntu 24.04 template on Proxmox | `ubuntu24-04-vms/Proxmox/Packer/` |
| Ubuntu 24.04 VMs on Proxmox (PVE01) | `ubuntu24-04-vms/Proxmox/Terraform/` |
| Ubuntu 24.04 VMs on Proxmox (PVE02) | `ubuntu24-04-vms/Proxmox/Terraform_PVE02/` |
| Ubuntu 24.04 template on vSphere | `ubuntu24-04-vms/vSphere/Packer/` |
| Ubuntu 24.04 VMs on vSphere | `ubuntu24-04-vms/vSphere/Terraform/` |
| WebLogic Server on AlmaLinux | `alma_linux/ansible/` or `wls_ansible/` |

### Step 3: Create Your Secrets File

Every component has an `.example` file. Copy and populate it:

```bash
# Packer (Proxmox Ubuntu example)
cp ubuntu24-04-vms/Proxmox/Packer/secrets.pkrvars.hcl.example \
   ubuntu24-04-vms/Proxmox/Packer/secrets.pkrvars.hcl

# Terraform (Proxmox Ubuntu example)
cp ubuntu24-04-vms/Proxmox/Terraform/secrets.auto.tfvars.example \
   ubuntu24-04-vms/Proxmox/Terraform/secrets.auto.tfvars
```

Edit the files to add your API tokens, passwords, and SSH keys.

### Step 4: Build and Deploy

```bash
# Build the template
cd ubuntu24-04-vms/Proxmox/Packer
packer init .
packer build -var-file="secrets.pkrvars.hcl" -var-file="variables.pkrvars.hcl" ubuntu-2404.pkr.hcl

# Deploy VMs
cd ../Terraform
terraform init
terraform plan
terraform apply
```

Alternatively, use the included helper script:

```bash
bash build.sh
```

---

## 7. Packer: Building VM Templates

Packer automates the entire base image creation process. The workflow is:

1. Boot VM from ISO in the hypervisor.
2. Serve a kickstart/cloud-init configuration over HTTP.
3. OS installer completes unattended installation.
4. Packer connects via SSH and runs provisioner scripts.
5. Cleanup and template conversion.

### 7.1 AlmaLinux 9 on Proxmox

**File:** `alma_linux/packer/almalinux.pkr.hcl`

**Key steps performed:**
- Boots from AlmaLinux 9 ISO via the Proxmox Packer plugin
- Kickstart file served from `http/ks.cfg`
- Installs QEMU guest agent
- Resets machine-id and SSH host keys for unique clones

**Build command:**

```bash
cd alma_linux/packer
packer init .
packer validate -var-file="vars.pkrvars.hcl"
packer build -var-file="vars.pkrvars.hcl" almalinux.pkr.hcl
```

**Key variables** (`vars.pkrvars.hcl`):

| Variable | Description |
|----------|-------------|
| `proxmox_node` | Proxmox node name |
| `vm_id` | Template VM ID |
| `iso_file` | Path to AlmaLinux ISO in Proxmox storage |
| `cores` | Number of vCPUs |
| `memory` | RAM in MB |
| `disk_size` | Disk size (e.g., `"20G"`) |

---

### 7.2 Oracle Linux 9 on Proxmox

**File:** `oracle_linux/packer/oraclelinux.pkr.hcl`

Similar to AlmaLinux but uses the Oracle Linux 9 ISO and its own kickstart configuration.

**Build command:**

```bash
cd oracle_linux/packer
packer init .
packer build oraclelinux.pkr.hcl
```

---

### 7.3 Ubuntu 24.04 on Proxmox

**File:** `ubuntu24-04-vms/Proxmox/Packer/ubuntu-2404.pkr.hcl`

**Key steps performed:**
- Cloud-init `user-data` served via ISO (more reliable than HTTP in Proxmox)
- Ubuntu autoinstall completes unattended setup
- Installs: QEMU guest agent, Docker CE v27.5.1, Python 3
- Resets machine-id and regenerates SSH host keys

**Build command:**

```bash
cd ubuntu24-04-vms/Proxmox/Packer
packer init .
packer build \
  -var-file="secrets.pkrvars.hcl" \
  -var-file="variables.pkrvars.hcl" \
  ubuntu-2404.pkr.hcl

# Or use the helper script:
bash build.sh
```

**Key variables** (`variables.pkrvars.hcl`):

| Variable | Description |
|----------|-------------|
| `proxmox_node` | Target Proxmox node |
| `vm_id` | Template VM ID (must be unique) |
| `template_name` | Template name in Proxmox |
| `iso_storage_pool` | Proxmox storage for ISO |
| `cores` / `memory` | Template hardware specs |
| `ssh_username` | SSH user created during autoinstall |

**Secrets** (`secrets.pkrvars.hcl`):

| Variable | Description |
|----------|-------------|
| `proxmox_api_url` | Full Proxmox API URL |
| `proxmox_api_token_id` | API token ID (e.g., `user@pam!token`) |
| `proxmox_api_token_secret` | API token secret value |
| `ssh_password` | Password for the template SSH user |

---

### 7.4 Ubuntu 24.04 on vSphere

**File:** `ubuntu24-04-vms/vSphere/Packer/ubuntu-24-04.pkr.hcl`

Significantly more complex than the Proxmox variant (493 lines) due to VMware's additional configuration surface.

**Key differences from Proxmox:**
- Uses `vsphere-iso` Packer plugin instead of `proxmox-iso`
- Requires VMware Tools / open-vm-tools installation
- Supports vApp properties for cloud-init delivery
- Handles vSphere-specific hardware (VMXNET3 NIC, PVSCSI controller, NVME disk)
- Optional SSL verification skip for self-signed vCenter certificates

**Build command:**

```bash
cd ubuntu24-04-vms/vSphere/Packer
packer init .
packer build \
  -var-file="secrets.pkrvars.hcl" \
  -var-file="variables.pkrvars.hcl" \
  ubuntu-24-04.pkr.hcl

# Or use the helper script:
bash build.sh
```

**Key secrets** (`secrets.pkrvars.hcl`):

| Variable | Description |
|----------|-------------|
| `vsphere_server` | vCenter hostname or IP |
| `vsphere_username` | vCenter service account |
| `vsphere_password` | vCenter password |
| `ssh_password` | Template SSH user password |

---

## 8. Terraform: Deploying VMs

After a template exists in your hypervisor, Terraform clones it into one or more running VMs, applying per-VM customization through cloud-init.

### 8.1 AlmaLinux 9 VMs on Proxmox

**File:** `alma_linux/terraform/main.tf`

Deploys a cluster topology: 1 master node + 2 worker nodes, configurable via `variables.tf`.

```bash
cd alma_linux/terraform
terraform init
terraform plan -var-file="terraform.tfvars" -var-file="secret.tfvars"
terraform apply -var-file="terraform.tfvars" -var-file="secret.tfvars"
```

---

### 8.2 Ubuntu 24.04 VMs on Proxmox (PVE01)

**File:** `ubuntu24-04-vms/Proxmox/Terraform/main.tf`

```bash
cd ubuntu24-04-vms/Proxmox/Terraform
terraform init
terraform plan
terraform apply

# Or use the helper script:
bash build.sh
```

**Key variables** (`variables.tf`):

| Variable | Description |
|----------|-------------|
| `proxmox_host` | Proxmox API URL |
| `target_node` | Proxmox node name (e.g., `pve01`) |
| `template_name` | Source template name |
| `vm_count` | Number of VMs to deploy |
| `vm_name_prefix` | Prefix for VM names |
| `cores` / `memory` | VM hardware specs |
| `disk_size` | VM disk size in GB |
| `ip_address` | Static IP (or use DHCP) |
| `gateway` | Network gateway |
| `dns_servers` | DNS server list |
| `ssh_public_key` | SSH key injected into VMs |

---

### 8.3 Ubuntu 24.04 VMs on Proxmox (PVE02)

**File:** `ubuntu24-04-vms/Proxmox/Terraform_PVE02/main.tf`

Identical structure to the PVE01 configuration, but targets a secondary Proxmox cluster node (`pve02`). Useful for distributing VM workloads across cluster members.

```bash
cd ubuntu24-04-vms/Proxmox/Terraform_PVE02
terraform init
terraform plan
terraform apply
```

---

### 8.4 Ubuntu 24.04 VMs on vSphere

**File:** `ubuntu24-04-vms/vSphere/Terraform/main.tf`

The most feature-rich Terraform configuration in the repository (236 variable definitions). Supports full vSphere customization including datacenter, cluster, datastore, resource pool, folder, and network.

```bash
cd ubuntu24-04-vms/vSphere/Terraform
terraform init
terraform plan
terraform apply
```

**Key vSphere-specific variables** (`variables.tf`):

| Variable | Description |
|----------|-------------|
| `vsphere_server` | vCenter server address |
| `vsphere_datacenter` | Datacenter name |
| `vsphere_cluster` | Compute cluster name |
| `vsphere_datastore` | Target datastore |
| `vsphere_network` | VM network portgroup |
| `vsphere_folder` | VM folder in inventory |
| `template_name` | Source template name |
| `vm_count` | Number of VMs |
| `dns_servers` | DNS server list |
| `domain` | DNS domain suffix |

**Outputs** (`output.tf`): VM names, IP addresses, and UUIDs are exposed as Terraform outputs after apply.

**Cloud-init templates** are rendered at deploy time from `templates/metadata.yaml` and `templates/userdata.yaml`, allowing per-VM hostname and IP injection without modifying the base template.

---

## 9. Ansible: Post-Deployment Configuration

Two Ansible setups are included for WebLogic Server deployment:

### Integrated Role (`alma_linux/ansible/`)

Used alongside the AlmaLinux Terraform deployment.

```bash
cd alma_linux/ansible
ansible-playbook -i inventory playbook.yml
```

### Standalone Playbook (`wls_ansible/`)

A portable WebLogic deployment playbook that can target any RHEL-compatible host.

```bash
cd wls_ansible
ansible-playbook -i inventory site.yml
```

### WebLogic Role (`roles/weblogic/tasks/main.yml`)

The role performs the following tasks:

1. Install OS packages: `java-11-openjdk`, `unzip`, `wget`
2. Create `oracle` OS user and group
3. Copy WebLogic installer to target host
4. Run silent installation via response file
5. Create a WebLogic domain using WLST (WebLogic Scripting Tool)
6. Configure and start the Admin Server

**Role variables** (set in `group_vars/all.yml` or `group_vars/weblogic.yml`):

| Variable | Description |
|----------|-------------|
| `wls_version` | WebLogic version string |
| `wls_installer` | Installer filename |
| `oracle_home` | Installation directory |
| `domain_name` | WebLogic domain name |
| `admin_port` | Admin Server port (default 7001) |
| `admin_username` | Admin console username |
| `admin_password` | Admin console password |

---

## 10. Secrets Management

### What Is Never Committed

The `.gitignore` excludes all files that could contain credentials:

```
*.tfvars                 # Terraform variable files with values
!*.example               # Allow example templates (exception)
secret.auto.tfvars       # Auto-loaded Terraform secrets
*.pkrvars.hcl            # Packer variable files
secrets.pkrvars.hcl      # Packer secret files
*.tfstate*               # Terraform state (contains resource details)
*.pem / *.key            # SSH private keys
*.env                    # Environment variable files
packer_cache/            # Packer build cache (large binaries)
.terraform/              # Terraform provider binaries
```

### Setting Up Secrets

Each component has an `.example` file that documents required variables:

| Example File | Copy To |
|-------------|---------|
| `secrets.pkrvars.hcl.example` | `secrets.pkrvars.hcl` |
| `secrets.auto.tfvars.example` | `secrets.auto.tfvars` |
| `terraform.tfvars.example` | `terraform.tfvars` |

### Proxmox API Token Setup

Proxmox recommends API tokens over passwords. Minimum required privileges:

```
VM.Allocate, VM.Clone, VM.Config.CDROM, VM.Config.CPU,
VM.Config.Disk, VM.Config.HWType, VM.Config.Memory,
VM.Config.Network, VM.Config.Options, VM.Monitor,
VM.PowerMgmt, Datastore.AllocateSpace, Datastore.Audit
```

Token format in secrets file:

```hcl
proxmox_api_token_id     = "terraform@pam!mytoken"
proxmox_api_token_secret = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

### vSphere Credentials

```hcl
vsphere_username = "svc-terraform@vsphere.local"
vsphere_password = "YourSecurePassword"
```

For self-signed certificates, set `vsphere_insecure_connection = true` in variables (not recommended for production).

### Production Recommendations

- **Terraform Cloud/Enterprise:** Use variable sets to manage secrets centrally.
- **HashiCorp Vault:** Dynamic secrets for API tokens with short TTLs.
- **CI/CD secrets stores:** GitHub Actions secrets, GitLab CI variables, etc.
- **AWS Secrets Manager / Azure Key Vault:** For cloud-hosted CI/CD pipelines.

---

## 11. Cloud-init & Kickstart Reference

### Ubuntu Cloud-init (`user-data`)

Ubuntu 24.04 uses the `autoinstall` specification. Key sections:

```yaml
autoinstall:
  version: 1
  identity:
    hostname: ubuntu-template
    username: ubuntu
    password: "<hashed-password>"
  ssh:
    install-server: true
    authorized-keys: []
    allow-pw: true
  packages:
    - qemu-guest-agent
    - docker-ce
    - python3
  late-commands:
    - "systemctl enable qemu-guest-agent"
    - "truncate -s 0 /etc/machine-id"
```

The `meta-data` file is required but can be empty for Proxmox/vSphere cloud-init ISO delivery.

### AlmaLinux / Oracle Linux Kickstart (`ks.cfg`)

```ini
# Language and timezone
lang en_US.UTF-8
timezone America/New_York --isUtc

# Disk partitioning
ignoredisk --only-use=sda
clearpart --all --initlabel
autopart

# Network
network --bootproto=dhcp --device=eth0 --onboot=on

# Root password (hashed)
rootpw --iscrypted <hash>

# Packages
%packages
@core
qemu-guest-agent
%end

# Post-install
%post
systemctl enable qemu-guest-agent
%end
```

---

## 12. Configuration Reference

### Packer Common Variables

| Variable | Type | Description |
|----------|------|-------------|
| `proxmox_node` | string | Target Proxmox node name |
| `vm_id` | number | VM ID (must be unique in Proxmox) |
| `template_name` | string | Name for the resulting template |
| `iso_file` | string | ISO path (e.g., `local:iso/almalinux-9.iso`) |
| `iso_storage_pool` | string | Proxmox storage for ISO downloads |
| `cores` | number | CPU cores for the build VM |
| `memory` | number | RAM in MB for the build VM |
| `disk_size` | string | Disk size (e.g., `"20G"`) |
| `disk_storage_pool` | string | Storage pool for the VM disk |
| `network_bridge` | string | Proxmox network bridge (e.g., `vmbr0`) |
| `ssh_username` | string | SSH user for Packer provisioning |
| `ssh_timeout` | string | SSH connection timeout (e.g., `"20m"`) |
| `http_port_min` | number | Min port for HTTP server (kickstart) |
| `http_port_max` | number | Max port for HTTP server (kickstart) |

### Terraform Common Variables (Proxmox)

| Variable | Type | Description |
|----------|------|-------------|
| `proxmox_host` | string | Proxmox API URL |
| `proxmox_node` | string | Target node name |
| `template_name` | string | Source template to clone |
| `vm_count` | number | Number of VMs to create |
| `vm_name` | string | Base name for VMs |
| `cores` | number | vCPU count per VM |
| `memory` | number | RAM in MB per VM |
| `disk_size` | number | Disk size in GB |
| `ip_address` | string | Static IP (CIDR notation) |
| `gateway` | string | Default gateway |
| `nameserver` | string | Primary DNS server |
| `ssh_public_key` | string | SSH public key content |
| `ciuser` | string | Cloud-init username |
| `cipassword` | string | Cloud-init user password |

### Terraform Common Variables (vSphere)

| Variable | Type | Description |
|----------|------|-------------|
| `vsphere_server` | string | vCenter hostname |
| `vsphere_datacenter` | string | Datacenter object name |
| `vsphere_cluster` | string | Compute cluster name |
| `vsphere_datastore` | string | Target datastore |
| `vsphere_network` | string | Network portgroup |
| `vsphere_resource_pool` | string | Resource pool path |
| `vsphere_folder` | string | VM folder in inventory |
| `template_name` | string | Source template name |
| `vm_count` | number | Number of VMs |
| `num_cpus` | number | vCPU count |
| `memory` | number | Memory in MB |
| `disk_size` | number | Disk size in GB |
| `dns_server_list` | list(string) | DNS servers |
| `domain` | string | DNS domain |
| `ipv4_address` | string | Static IP |
| `ipv4_netmask` | number | Subnet mask length |
| `ipv4_gateway` | string | Default gateway |

---

## 13. Troubleshooting

### Packer Build Failures

**Problem: `Timeout waiting for SSH`**

The most common Packer error. Possible causes:

1. Kickstart/cloud-init HTTP server not reachable from the hypervisor.
   - Check firewall rules on the Packer host.
   - Ensure `http_port_min`/`http_port_max` are not blocked.
   - Verify the Packer host IP is routable from the hypervisor.

2. VM did not boot from the correct device.
   - Check ISO path and storage pool in variables.
   - Verify boot order in Packer config.

3. Cloud-init/kickstart has a syntax error.
   - Validate with `packer validate` before building.
   - Check hypervisor console for the VM during the build.

**Problem: `API token authentication failed` (Proxmox)**

- Confirm token ID format: `user@realm!tokenname`.
- Verify the token has not expired in the Proxmox UI.
- Confirm API URL ends with `/api2/json`.

**Problem: `Certificate verification failed` (vSphere)**

- Set `insecure_connection = true` in Packer variables for self-signed certs (dev/home lab).
- Or add the vCenter certificate to your local trust store.

---

### Terraform Apply Failures

**Problem: `Error creating VM: 500 Internal Server Error`**

- Check Proxmox/vCenter logs.
- Verify the API user has sufficient privileges.
- Ensure the target storage pool has enough free space.

**Problem: `Template not found`**

- Confirm the Packer build completed successfully.
- Verify `template_name` matches exactly (case-sensitive in Proxmox).
- For Proxmox: The template must be on the same node you're deploying to, or shared storage.

**Problem: `Cloud-init did not apply network config`**

- Verify cloud-init is enabled in the template (it resets on first boot).
- Check that `ipconfig0` or the cloud-init drive is attached in the Terraform resource.
- Review `/var/log/cloud-init.log` on the VM.

**Problem: `Terraform state lock conflict`**

```bash
# Force-unlock (use with caution)
terraform force-unlock <LOCK_ID>
```

---

### Ansible Failures

**Problem: `SSH connection refused`**

- Confirm VMs are fully booted (cloud-init completed).
- Verify SSH port 22 is open and the correct SSH key is being used.
- Check inventory file has correct IP addresses.

**Problem: `WebLogic installation failed`**

- Verify the installer binary is present in `roles/weblogic/files/`.
- Check Java is installed and `JAVA_HOME` is set correctly.
- Review Ansible task output with `-vvv` for detailed error messages.

---

## 14. Best Practices

### Version Pinning

Always pin tool versions for reproducible builds:

```hcl
# In packer config
packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}
```

```hcl
# In terraform config
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "~> 2.9"
    }
  }
}
```

### State File Management

- **Never commit** `.tfstate` or `.tfstate.backup` files.
- For shared environments, use a **remote backend** (Terraform Cloud, S3, etc.):

```hcl
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "homelab/ubuntu/terraform.tfstate"
    region = "us-east-1"
  }
}
```

### Validation Before Building

Run these checks before every Packer/Terraform execution:

```bash
# Packer
packer fmt .
packer validate -var-file="secrets.pkrvars.hcl" -var-file="variables.pkrvars.hcl" *.pkr.hcl

# Terraform
terraform fmt -recursive
terraform validate
terraform plan
```

### Template Versioning

Use a naming convention that includes a version or date in template names:

```
ubuntu-2404-20250201
almalinux-9-v1.2
```

This preserves old templates while rolling out new ones, enabling rollback.

### Machine-id and SSH Key Reset

Templates should always reset these identifiers so cloned VMs are unique:

```bash
# Included in all templates via Packer provisioner
truncate -s 0 /etc/machine-id
rm -f /etc/ssh/ssh_host_*
```

These regenerate on first boot of each cloned VM.

---

## 15. Contributing

1. Fork the repository on GitHub.
2. Create a feature branch:
   ```bash
   git checkout -b feature/add-debian-template
   ```
3. Make your changes, following the existing patterns.
4. Validate your configs:
   ```bash
   packer validate ...
   terraform validate
   ```
5. Commit with a descriptive message:
   ```bash
   git commit -m "Add Debian 12 Packer template for Proxmox"
   ```
6. Push and open a Pull Request:
   ```bash
   git push origin feature/add-debian-template
   ```

### Adding a New OS

1. Create a directory: `<os_name>/packer/` and `<os_name>/terraform/`.
2. Copy an existing Packer HCL file as a starting point.
3. Provide an `http/ks.cfg` (RHEL-based) or `http/user-data` (Debian-based).
4. Add a `variables.pkrvars.hcl` and `secrets.pkrvars.hcl.example`.
5. Update this wiki and `README.md`.

### Adding a New Hypervisor

1. Create a subdirectory under the OS: e.g., `ubuntu24-04-vms/HyperV/`.
2. Use the appropriate Packer plugin (`hyperv-iso`, `qemu`, etc.).
3. Mirror the structure of an existing hypervisor directory.

---

*Last updated: 2026-02-19*
