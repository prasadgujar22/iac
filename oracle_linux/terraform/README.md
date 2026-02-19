# Oracle Linux VM Provisioning using Terraform (Proxmox)

This directory contains Terraform code used to provision **Oracle Linux virtual machines on Proxmox**.

The Terraform configuration assumes that a VM template has already been created
using **Packer**, and Terraform is responsible only for cloning and managing VMs
from that template.

---

## Directory Structure

```
terraform/
├── main.tf
├── provider.tf
├── variables.tf
└── .terraform.lock.hcl
```

---

## Prerequisites

Before running Terraform, ensure the following:

- Proxmox VE cluster is accessible
- Oracle Linux VM template already exists in Proxmox
- Terraform installed (v1.5+ recommended)
- Proxmox API token with required permissions

Required permissions:
- VM.Allocate
- VM.Clone
- VM.Config.*
- Datastore.AllocateSpace

---

## Proxmox Authentication

Terraform connects to Proxmox using an API token.

Example environment variables:

```bash
export PM_API_URL="https://proxmox.example.com:8006/api2/json"
export PM_API_TOKEN_ID="terraform@pve!token"
export PM_API_TOKEN_SECRET="xxxxxxxxxxxxxxxx"
```

---

## What this Terraform does

- Clones Oracle Linux VM from a Packer-built template
- Configures CPU, memory, and disk
- Sets VM name and target Proxmox node
- Provisions 1 master node and 2 worker nodes
- Configures static IPs via cloud-init
- Manages VM lifecycle using Infrastructure as Code

---

## VM Layout

| VM Name   | Role   | IP Address       |
|-----------|--------|------------------|
| master    | Master | 192.168.29.109   |
| worker-1  | Worker | 192.168.29.110   |
| worker-2  | Worker | 192.168.29.111   |

---

## Usage

Initialize Terraform:

```bash
terraform init
```

Validate configuration:

```bash
terraform validate
```

Review execution plan:

```bash
terraform plan
```

Apply changes:

```bash
terraform apply
```

Destroy resources (if required):

```bash
terraform destroy
```

---

## Notes

- Do not commit secrets or tfvars files
- Keep sensitive data outside Git
- Use Packer only for template creation
- Use Terraform only for VM lifecycle

---

## Recommended Workflow

1. Build Oracle Linux template using Packer
2. Verify template in Proxmox
3. Provision VMs using Terraform
4. Track changes using Git

---

## Author

Prasad Gujar
Infrastructure as Code (IaC)
