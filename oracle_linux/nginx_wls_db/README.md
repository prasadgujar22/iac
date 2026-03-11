# Nginx + Oracle WebLogic 2-Node Cluster + Oracle DB 19c

Automated provisioning of a full Oracle stack on Oracle Linux 9 using **Terraform** (Proxmox VMs) and **Ansible** (configuration management).

## Architecture

```
                  ┌─────────────────────────────────────────────────────┐
                  │                   Client traffic                    │
                  └─────────────────────┬───────────────────────────────┘
                                        │ :80
                          ┌─────────────▼──────────────┐
                          │      nginx-server           │
                          │    192.168.29.130           │
                          │   (Nginx load balancer)     │
                          └──────────┬─────────┬────────┘
                      :7003          │         │          :7003
               ┌───────────────┐    │         │    ┌───────────────┐
               │  wls-node1    │◄───┘         └───►│  wls-node2    │
               │ 192.168.29.132│                   │ 192.168.29.133│
               │  (ms1)        │                   │  (ms2)        │
               └───────┬───────┘                   └───────┬───────┘
                       │ t3://                             │ t3://
                       └──────────────┬────────────────────┘
                                      │ :7001
                          ┌───────────▼──────────────┐
                          │      wls-admin            │
                          │    192.168.29.131         │
                          │  (AdminServer)            │
                          └───────────┬───────────────┘
                                      │ JDBC :1521
                          ┌───────────▼──────────────┐
                          │      oracle-db            │
                          │    192.168.29.134         │
                          │  Oracle DB 19c            │
                          │  CDB: WLSDB / PDB: WLSPDB│
                          └──────────────────────────┘
```

| VM | IP | Role |
|---|---|---|
| nginx-server | 192.168.29.130 | Nginx reverse-proxy / load balancer |
| wls-admin | 192.168.29.131 | WebLogic 14.1.2 Administration Server |
| wls-node1 | 192.168.29.132 | WebLogic Managed Server 1 (cluster: WLSCluster) |
| wls-node2 | 192.168.29.133 | WebLogic Managed Server 2 (cluster: WLSCluster) |
| oracle-db | 192.168.29.134 | Oracle Database 19c (WLSDB / WLSPDB) |

## Directory layout

```
nginx_wls_db/
├── terraform/
│   ├── provider.tf             # Proxmox telmate provider
│   ├── variables.tf            # All input variables (IPs, sizing, …)
│   ├── main.tf                 # VM resources (nginx, wls-admin, wls-node×2, oracle-db)
│   ├── outputs.tf              # Exposes IPs and inventory hint
│   └── terraform.tfvars.example
│
└── ansible/
    ├── ansible.cfg
    ├── site.yml                # Master playbook (imports all below)
    ├── common.yml              # OS prerequisites for all VMs
    ├── nginx.yml               # Nginx role
    ├── weblogic.yml            # WLS role (prereqs → install → domain → MS → NM)
    ├── oracle_db.yml           # Oracle DB role
    ├── inventory/
    │   └── hosts.ini
    ├── group_vars/
    │   ├── all.yml
    │   ├── nginx.yml
    │   ├── wls_nodes.yml
    │   └── db_server.yml
    └── roles/
        ├── common/             # chrony, sysctl, /etc/hosts, SELinux
        ├── nginx/              # Install + configure Nginx upstream proxy
        ├── weblogic/           # JDK17, WLS14.1.2, domain, MS, NM
        └── oracle_db/          # DB prereqs, storage, install, DBCA, listener, schema
```

## Prerequisites

### Software media (download from Oracle eDelivery / MOS)
Place these files in `ansible/files/` before running playbooks:

| File | Description |
|---|---|
| `LINUX.X64_193000_db_home.zip` | Oracle Database 19c for Linux x86-64 |
| `jdk-17_linux-x64_bin.rpm` | JDK 17 RPM from Oracle |
| `fmw_14.1.2.0.0_wls.jar` | WebLogic Server 14.1.2 silent installer |

### Terraform
- Proxmox VE 8.x with `telmate/proxmox` provider access
- Oracle Linux 9 cloud-init template already created (see `../packer/`)
- API token with `PVEVMAdmin` role

### Ansible
- Ansible ≥ 2.14
- Collections: `ansible.posix`, `community.general`

```bash
ansible-galaxy collection install ansible.posix community.general
```

## Deployment

### 1. Provision VMs with Terraform

```bash
cd terraform/
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your Proxmox credentials
terraform init
terraform plan
terraform apply
```

### 2. Configure with Ansible

```bash
cd ../ansible/

# Full stack deployment
ansible-playbook -i inventory/hosts.ini site.yml

# Or component by component
ansible-playbook -i inventory/hosts.ini common.yml
ansible-playbook -i inventory/hosts.ini nginx.yml
ansible-playbook -i inventory/hosts.ini weblogic.yml
ansible-playbook -i inventory/hosts.ini oracle_db.yml
```

### 3. Verify

```bash
# Check Nginx is proxying to WLS
curl http://192.168.29.130/

# Check Nginx health endpoint
curl http://192.168.29.130/health

# Access WLS Admin Console
# URL: http://192.168.29.131:7001/console
# User: weblogic / Weblogic_Passw0rd1

# Check Oracle listener
sqlplus sys/Oracle_SYS_Passw0rd@192.168.29.134:1521/WLSDB AS SYSDBA
```

## Customisation

| What | Where |
|---|---|
| VM IPs | `terraform/variables.tf` + `ansible/inventory/hosts.ini` + `ansible/group_vars/*.yml` |
| VM sizing | `terraform/variables.tf` (`*_cpu_cores`, `*_memory_mb`, `*_disk_size`) |
| WLS domain name / cluster name | `ansible/group_vars/wls_nodes.yml` |
| DB name / PDB name | `ansible/group_vars/db_server.yml` |
| Nginx upstream servers | `ansible/group_vars/nginx.yml` |
| Passwords | `ansible/group_vars/wls_nodes.yml` + `db_server.yml` (encrypt with `ansible-vault`) |

## Security notes

- Rotate all default passwords before production use.
- Encrypt sensitive `group_vars` with `ansible-vault encrypt group_vars/wls_nodes.yml`.
- SELinux is set to **permissive** for Oracle compatibility; harden further as required.
- Add TLS to Nginx (`nginx_listen_port_ssl: 443`) in production environments.
