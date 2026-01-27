# AlmaLinux VM Template Build using Packer (Proxmox)

This directory contains **Packer configuration** used to build a reusable
**AlmaLinux VM template on Proxmox VE**.

The generated template is later consumed by **Terraform** to provision
virtual machines in a consistent and automated way.

---

## 📁 Directory Structure

```
packer/
├── almalinux.pkr.hcl
├── http/
│   └── ks.cfg
├── archives/
└── .gitignore
```

---

## ⚙️ Prerequisites

Before running Packer, ensure the following:

- Proxmox VE cluster is reachable
- ISO image for AlmaLinux is available in Proxmox
- Packer v1.8+ installed
- Proxmox API token with required permissions

Required Proxmox permissions:

- VM.Allocate
- VM.Config.*
- VM.Monitor
- Datastore.AllocateSpace

---

## 🔐 Proxmox Authentication

Packer authenticates to Proxmox using API tokens.

Recommended environment variables:

```bash
export PM_API_URL="https://proxmox.example.com:8006/api2/json"
export PM_API_TOKEN_ID="packer@pve!token"
export PM_API_TOKEN_SECRET="xxxxxxxxxxxxxxxx"
export PM_TLS_INSECURE=true
```

---

## 📦 What this Packer build does

- Creates a temporary AlmaLinux VM
- Performs unattended installation (Kickstart)
- Applies base OS configuration
- Installs required packages
- Cleans up machine-specific data
- Converts VM into a Proxmox template

---

## 🚀 Usage

### 1️⃣ Initialize Packer

```bash
packer init .
```

---

### 2️⃣ Validate template

```bash
packer validate almalinux.pkr.hcl
```

---

### 3️⃣ Build template

```bash
packer build almalinux.pkr.hcl
```

After completion, the VM will appear in Proxmox as a **template**.

---

## 🧠 Recommended Workflow

1. Build AlmaLinux template using Packer
2. Verify template boots correctly
3. Do not modify template manually
4. Use Terraform for VM provisioning

---

## ⚠️ Notes

- Never commit secrets into Git
- Keep Kickstart files minimal and reproducible
- Avoid manual changes after template creation
- Rebuild template for OS updates

---

## 🔄 Template Rebuild Strategy

Recommended rebuild frequency:

- Monthly OS updates
- Kernel upgrades
- Security patches

Tag templates using versioning:

```
alma-9-template-v1
alma-9-template-v2
```

---

## 📌 Future Improvements

- Cloud-init integration
- Template version automation
- GitHub Actions for image build
- CIS hardening baseline

---

## 👤 Author

Prasad Gujar  
Infrastructure as Code (IaC)

