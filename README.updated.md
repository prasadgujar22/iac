# Infrastructure as Code (IaC) - Home Lab

This README was automatically updated by Alfred to reflect the repository structure and recent changes. Review the draft and merge when ready.

## Overview

Automated infrastructure provisioning for home lab environments using Packer, Terraform, and supporting tools targeting Proxmox VE. The repository contains templates and deployment code for building VM images and provisioning VMs in a home lab.

## Repository Structure

The repository top-level contains the following folders:

- ${TREE}

(If you expect additional top-level directories, please verify.)

## Recent changes (last 5 commits)

${LAST_COMMITS}

## Technologies Used

- Packer — VM template creation
- Terraform — Infrastructure provisioning
- Ansible / Shell scripts — configuration and provisioning helpers
- Proxmox VE — virtualization target

## Quick Start

1. Clone the repository

```bash
git clone https://github.com/prasadgujar22/iac.git
cd iac
```

2. Review per-folder README files for specific build instructions (e.g., `alma_linux/README.md`, `ubuntu24-04-vms/README.md`).

3. For Packer builds, set secrets in environment variables or use `.pkrvars.hcl` files not committed to Git.

4. For Terraform deployments, use `terraform init` and `terraform validate` in the appropriate subfolder (see subfolder READMEs).

## Per-directory notes

- `alma_linux/` — Packer templates for AlmaLinux 9; check `alma_linux/README.md` for required variables and token usage.
- `ubuntu24-04-vms/` — Ubuntu 24.04 Packer & Terraform code; see subfolder docs.

## Security & Secrets

- Do NOT commit tokens, private keys, or plaintext passwords. Use environment variables or a secrets manager. Example environment variables used across the repo:

```bash
export PROXMOX_API_TOKEN_ID="your-token-id"
export PROXMOX_API_TOKEN_SECRET="your-token-secret"
```

- The repository contains example files (`*.example`) to document variables; keep real secrets out of source control.

## CI / Linting

This repository benefits from running linters and IaC scanners: `terraform fmt` / `validate`, `tflint`, `checkov`, and `detect-secrets`.

## Author

Prasad Gujar

