# =============================================================================
# main.tf – Nginx + Oracle WebLogic 2-node cluster + Oracle DB server
#
# VM layout
#   nginx-server   192.168.29.130  – Nginx reverse-proxy / load balancer
#   wls-admin      192.168.29.131  – WebLogic 14.1.2 Administration Server
#   wls-node1      192.168.29.132  – WebLogic Managed Server 1
#   wls-node2      192.168.29.133  – WebLogic Managed Server 2
#   oracle-db      192.168.29.134  – Oracle Database 19c (standalone)
# =============================================================================

# ---------------------------------------------------------------------------
# Local helpers
# ---------------------------------------------------------------------------
locals {
  cidr_prefix = "24"

  # Common cloud-init SSH key block
  ssh_key = var.ssh_public_key
}

# ---------------------------------------------------------------------------
# 1. Nginx – reverse proxy / load balancer
# ---------------------------------------------------------------------------
resource "proxmox_vm_qemu" "nginx_server" {
  name        = "nginx-server"
  target_node = var.target_node
  clone       = var.template_name
  full_clone  = true
  tags        = "terraform;nginx;load-balancer"
  vm_state    = "running"
  desc        = "Nginx reverse-proxy / load balancer for WebLogic cluster"

  cpu {
    cores   = var.nginx_cpu_cores
    sockets = 1
    type    = "host"
  }

  agent  = 1
  memory = var.nginx_memory_mb
  scsihw = "virtio-scsi-single"

  os_type    = "cloud-init"
  ciuser     = var.vm_user
  cipassword = var.vm_password_hash

  network {
    id     = 0
    model  = "virtio"
    bridge = var.network_bridge
  }

  ipconfig0  = "ip=${var.nginx_ip}/${local.cidr_prefix},gw=${var.gateway}"
  nameserver = var.nameserver
  sshkeys    = local.ssh_key
  boot       = "order=scsi0"

  disks {
    scsi {
      scsi0 {
        disk {
          size    = var.nginx_disk_size
          storage = var.storage
        }
      }
    }
    ide {
      ide2 {
        cloudinit {
          storage = var.storage
        }
      }
    }
  }
}

# ---------------------------------------------------------------------------
# 2. WebLogic Administration Server
# ---------------------------------------------------------------------------
resource "proxmox_vm_qemu" "wls_admin" {
  name        = "wls-admin"
  target_node = var.target_node
  clone       = var.template_name
  full_clone  = true
  tags        = "terraform;weblogic;wls-admin"
  vm_state    = "running"
  desc        = "Oracle WebLogic 14.1.2 Administration Server"

  cpu {
    cores   = var.wls_admin_cpu_cores
    sockets = 1
    type    = "host"
  }

  agent  = 1
  memory = var.wls_admin_memory_mb
  scsihw = "virtio-scsi-single"

  os_type    = "cloud-init"
  ciuser     = var.vm_user
  cipassword = var.vm_password_hash

  network {
    id     = 0
    model  = "virtio"
    bridge = var.network_bridge
  }

  ipconfig0  = "ip=${var.wls_admin_ip}/${local.cidr_prefix},gw=${var.gateway}"
  nameserver = var.nameserver
  sshkeys    = local.ssh_key
  boot       = "order=scsi0"

  disks {
    scsi {
      scsi0 {
        disk {
          size    = var.wls_admin_disk_size
          storage = var.storage
        }
      }
    }
    ide {
      ide2 {
        cloudinit {
          storage = var.storage
        }
      }
    }
  }
}

# ---------------------------------------------------------------------------
# 3. WebLogic Managed Servers (2-node cluster)
# ---------------------------------------------------------------------------
resource "proxmox_vm_qemu" "wls_nodes" {
  count = length(var.wls_node_ips)

  name        = "wls-node${count.index + 1}"
  target_node = var.target_node
  clone       = var.template_name
  full_clone  = true
  tags        = "terraform;weblogic;wls-managed"
  vm_state    = "running"
  desc        = "Oracle WebLogic 14.1.2 Managed Server ${count.index + 1}"

  cpu {
    cores   = var.wls_node_cpu_cores
    sockets = 1
    type    = "host"
  }

  agent  = 1
  memory = var.wls_node_memory_mb
  scsihw = "virtio-scsi-single"

  os_type    = "cloud-init"
  ciuser     = var.vm_user
  cipassword = var.vm_password_hash

  network {
    id     = 0
    model  = "virtio"
    bridge = var.network_bridge
  }

  ipconfig0  = "ip=${var.wls_node_ips[count.index]}/${local.cidr_prefix},gw=${var.gateway}"
  nameserver = var.nameserver
  sshkeys    = local.ssh_key
  boot       = "order=scsi0"

  disks {
    scsi {
      scsi0 {
        disk {
          size    = var.wls_node_disk_size
          storage = var.storage
        }
      }
    }
    ide {
      ide2 {
        cloudinit {
          storage = var.storage
        }
      }
    }
  }
}

# ---------------------------------------------------------------------------
# 4. Oracle Database Server (standalone, 19c)
#    Three disks:
#      scsi0 – OS (100 G)
#      scsi1 – Oracle datafiles (100 G)
#      scsi2 – Fast Recovery Area (50 G)
# ---------------------------------------------------------------------------
resource "proxmox_vm_qemu" "oracle_db" {
  name        = "oracle-db"
  target_node = var.target_node
  clone       = var.template_name
  full_clone  = true
  tags        = "terraform;oracle;database"
  vm_state    = "running"
  desc        = "Oracle Database 19c standalone server"

  cpu {
    cores   = var.oracle_db_cpu_cores
    sockets = 1
    type    = "host"
  }

  agent  = 1
  memory = var.oracle_db_memory_mb
  scsihw = "virtio-scsi-single"

  os_type    = "cloud-init"
  ciuser     = var.vm_user
  cipassword = var.vm_password_hash

  network {
    id     = 0
    model  = "virtio"
    bridge = var.network_bridge
  }

  ipconfig0  = "ip=${var.oracle_db_ip}/${local.cidr_prefix},gw=${var.gateway}"
  nameserver = var.nameserver
  sshkeys    = local.ssh_key
  boot       = "order=scsi0"

  disks {
    scsi {
      # OS disk
      scsi0 {
        disk {
          size    = var.oracle_db_disk_size
          storage = var.storage
        }
      }
      # Oracle datafiles
      scsi1 {
        disk {
          size    = var.oracle_db_data_disk_size
          storage = var.storage
        }
      }
      # Fast Recovery Area
      scsi2 {
        disk {
          size    = var.oracle_db_fra_disk_size
          storage = var.storage
        }
      }
    }
    ide {
      ide2 {
        cloudinit {
          storage = var.storage
        }
      }
    }
  }
}
