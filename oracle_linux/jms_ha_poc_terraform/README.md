# JMS HA POC - Terraform (Oracle RAC + WebLogic Cluster on Proxmox)

This directory provisions the full **JMS High Availability POC** environment
on Proxmox using Terraform. It clones from pre-built Oracle Linux Packer
templates and configures all nodes via cloud-init.

---

## Architecture

```
 ┌─────────────────────────────────────────────────────────────────┐
 │                     JMS HA POC Environment                      │
 │                                                                  │
 │   ┌─────────────────────┐   ┌─────────────────────┐            │
 │   │     rac-node1       │   │     rac-node2        │            │
 │   │  Oracle DB RAC #1   │   │  Oracle DB RAC #2    │            │
 │   │  8GB / 2vCPU / 40G  │   │  8GB / 2vCPU / 40G   │            │
 │   │  192.168.29.120     │   │  192.168.29.121      │            │
 │   └──────────┬──────────┘   └──────────┬───────────┘            │
 │              │                          │                        │
 │        ┌─────┴──────────────────────────┴──────┐                │
 │        │       Shared ASM Storage              │                │
 │        │  ASM DATA: 40GB | ASM FRA: 20GB       │                │
 │        └───────────────────────────────────────┘                │
 │                                                                  │
 │   ┌─────────────────────┐                                       │
 │   │     wls-admin       │                                       │
 │   │   WLS Admin Server  │                                       │
 │   │  2GB / 1vCPU / 40G  │                                       │
 │   │  192.168.29.122     │                                       │
 │   └─────────────────────┘                                       │
 │                                                                  │
 │   ┌─────────────────────┐   ┌─────────────────────┐            │
 │   │     wls-node1       │   │     wls-node2        │            │
 │   │  WLS Managed MS1    │   │  WLS Managed MS2     │            │
 │   │  3GB / 2vCPU / 50G  │   │  3GB / 2vCPU / 50G   │            │
 │   │  192.168.29.123     │   │  192.168.29.124      │            │
 │   └─────────────────────┘   └─────────────────────┘            │
 └─────────────────────────────────────────────────────────────────┘
```

---

## VM Inventory

| VM Name   | Role                  | IP              | vCPU | RAM   | OS Disk | Extra Disks           |
|-----------|-----------------------|-----------------|------|-------|---------|-----------------------|
| rac-node1 | Oracle DB RAC Node 1  | 192.168.29.120  | 2    | 8 GB  | 40 GB   | ASM DATA 40G, FRA 20G |
| rac-node2 | Oracle DB RAC Node 2  | 192.168.29.121  | 2    | 8 GB  | 40 GB   | ASM DATA 40G, FRA 20G |
| wls-admin | WLS Admin Server      | 192.168.29.122  | 1    | 2 GB  | 40 GB   | -                     |
| wls-node1 | WLS Managed Server 1  | 192.168.29.123  | 2    | 3 GB  | 50 GB   | -                     |
| wls-node2 | WLS Managed Server 2  | 192.168.29.124  | 2    | 3 GB  | 50 GB   | -                     |

---

## Directory Structure

```
jms_ha_poc_terraform/
├── main.tf
├── provider.tf
├── variables.tf
└── .terraform.lock.hcl
```

---

## Prerequisites

- Proxmox VE cluster accessible
- Oracle Linux VM template exists (`oraclelinux-9-gold-template`)
- Terraform v1.5+ installed
- Proxmox API token with: `VM.Allocate`, `VM.Clone`, `VM.Config.*`, `Datastore.AllocateSpace`
- **For Oracle RAC**: A shared storage pool (NFS or iSCSI) configured in Proxmox
  and set as the `asm_storage` variable so both RAC nodes access the same physical disks

---

## Proxmox Authentication

```bash
export PM_API_URL="https://proxmox.example.com:8006/api2/json"
export PM_API_TOKEN_ID="terraform@pve!token"
export PM_API_TOKEN_SECRET="xxxxxxxxxxxxxxxx"
```

---

## Usage

```bash
terraform init
terraform validate
terraform plan
terraform apply
terraform destroy   # tear down when done
```

---

## ASM Shared Disk Note

The `asm_storage` variable defaults to `local-lvm` for quick testing.
For a real Oracle RAC setup, set it to a Proxmox shared storage pool
so `scsi1` (ASM DATA) and `scsi2` (ASM FRA) on both RAC nodes map to
the same physical disks.

Example `terraform.tfvars`:
```hcl
proxmox_api_url          = "https://proxmox.example.com:8006/api2/json"
proxmox_api_token_id     = "terraform@pve!mytoken"
proxmox_api_token_secret = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
asm_storage              = "shared-nfs"  # shared storage pool
```

---

## Author

Prasad Gujar
Infrastructure as Code (IaC)
