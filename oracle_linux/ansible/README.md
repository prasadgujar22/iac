# Oracle Linux Ansible Playbooks – JMS HA POC

Ansible automation to configure the VMs provisioned by
`../jms_ha_poc_terraform/` into a working Oracle RAC + WebLogic cluster.

## Infrastructure layout

| VM | IP | Role |
|---|---|---|
| rac-node1 | 192.168.29.120 | Oracle RAC DB node 1 |
| rac-node2 | 192.168.29.121 | Oracle RAC DB node 2 |
| wls-admin | 192.168.29.122 | WebLogic Admin Server |
| wls-node1 | 192.168.29.123 | WebLogic Managed Server ms1 |
| wls-node2 | 192.168.29.124 | WebLogic Managed Server ms2 |

---

## Prerequisites

### 1. Control-node dependencies
```bash
pip install ansible
ansible --version   # 2.14+
```

### 2. Download Oracle software
Place the following files in `roles/common/files/` (or an NFS share, then
adjust `installer_stage` in `group_vars/all.yml`):

| File | Source |
|---|---|
| `LINUX.X64_193000_grid_home.zip` | Oracle eDelivery / MOS |
| `LINUX.X64_193000_db_home.zip` | Oracle eDelivery / MOS |
| `jdk-17_linux-x64_bin.rpm` | oracle.com/java |
| `fmw_14.1.2.0.0_wls_lite.jar` | Oracle eDelivery / MOS |

### 3. SSH access
The Terraform template already injects the SSH public key for `prasad`.
Ensure your private key is at `~/.ssh/id_rsa` on the control node.

### 4. Secrets / vault
The default passwords are defined in `group_vars/rac_nodes.yml` and
`group_vars/wls_nodes.yml`. **Encrypt them with Ansible Vault before use:**
```bash
ansible-vault encrypt group_vars/rac_nodes.yml group_vars/wls_nodes.yml
```
Run playbooks with `--ask-vault-pass` or `--vault-password-file`.

---

## Directory structure

```
ansible/
├── ansible.cfg
├── site.yml                  # Full stack (RAC + WLS)
├── oracle_rac.yml            # Oracle RAC 19c only
├── weblogic.yml              # WebLogic 14.1.2 only
├── inventory/
│   └── hosts.ini
├── group_vars/
│   ├── all.yml               # Shared vars (paths, media file names)
│   ├── rac_nodes.yml         # RAC-specific vars
│   └── wls_nodes.yml         # WLS-specific vars
└── roles/
    ├── common/               # OS hardening, kernel params, oracle user
    ├── oracle_rac/           # GI 19c + DB 19c + DBCA
    └── weblogic/             # JDK 17 + WLS 14.1.2 + domain + JMS
```

---

## Usage

### Full stack (RAC then WLS)
```bash
cd oracle_linux/ansible
ansible-playbook -i inventory/hosts.ini site.yml
```

### Oracle RAC only
```bash
ansible-playbook -i inventory/hosts.ini oracle_rac.yml
```

### WebLogic only (RAC already running)
```bash
ansible-playbook -i inventory/hosts.ini weblogic.yml
```

### Run a specific phase with tags
```bash
# Only OS pre-reqs
ansible-playbook -i inventory/hosts.ini oracle_rac.yml --tags pre_install

# Only Grid Infrastructure install
ansible-playbook -i inventory/hosts.ini oracle_rac.yml --tags gi_install

# Only create the database
ansible-playbook -i inventory/hosts.ini oracle_rac.yml --tags dbca

# Only JMS configuration
ansible-playbook -i inventory/hosts.ini weblogic.yml --tags jms_config
```

### Dry run
```bash
ansible-playbook -i inventory/hosts.ini oracle_rac.yml --check --diff
```

---

## Available tags

| Tag | Playbook | Description |
|---|---|---|
| `common` | both | OS kernel params, packages, oracle user |
| `pre_install` | oracle_rac | RAC OS pre-reqs + ASM disk labeling |
| `gi_install` | oracle_rac | Grid Infrastructure 19c install |
| `db_install` | oracle_rac | Oracle DB 19c software install |
| `dbca` | oracle_rac | RAC database creation |
| `wls_install` | weblogic | JDK 17 + WLS 14.1.2 software |
| `domain_create` | weblogic | WLST domain creation |
| `jms_config` | weblogic | JMS module, queue, connection factory |
| `node_manager` | weblogic | Node Manager start |
| `managed_servers` | weblogic | Managed server start |

---

## Post-install verification

### Oracle RAC
```bash
# From rac-node1
su - grid
crsctl check cluster -all
srvctl status database -d RACDB
lsnrctl status
```

### WebLogic
```bash
# Admin console (browser)
http://192.168.29.122:7001/console
# User: weblogic  Password: (as set in group_vars/wls_nodes.yml)
```

---

## Notes

- The ASM `asm_storage` pool in Terraform must be **shared storage** (NFS /
  iSCSI) for a real production RAC. For this POC, `local-lvm` is used and
  both nodes get separate disks – this satisfies single-node testing but is
  **not** a true shared-disk RAC.
- SCAN VIP (192.168.29.140) and node VIPs (130/131) must be resolvable.
  Add them to `/etc/hosts` on all nodes (handled by the `common` role) or
  configure DNS.
- WebLogic 14.1.2 requires JDK 11 or JDK 17. JDK 17 is used here.
