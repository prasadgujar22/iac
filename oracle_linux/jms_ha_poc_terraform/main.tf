# =============================================================================
# JMS HA POC - Oracle RAC + WebLogic Cluster
# =============================================================================
# Layout:
#   rac-node1  192.168.29.120  Oracle DB RAC Node 1  8GB / 2vCPU / 40GB OS + ASM disks
#   rac-node2  192.168.29.121  Oracle DB RAC Node 2  8GB / 2vCPU / 40GB OS + ASM disks
#   wls-admin  192.168.29.122  WLS Admin Server       2GB / 1vCPU / 40GB OS
#   wls-node1  192.168.29.123  WLS Managed Server 1   3GB / 2vCPU / 50GB OS
#   wls-node2  192.168.29.124  WLS Managed Server 2   3GB / 2vCPU / 50GB OS
#
# NOTE: ASM DATA (40GB) and ASM FRA (20GB) are attached to both RAC nodes.
#       For a real Oracle RAC setup, use a shared storage pool (NFS/iSCSI)
#       as the storage target so both nodes access the same physical disks.
# =============================================================================

# -----------------------------------------------------------------------------
# Oracle RAC Node 1
# -----------------------------------------------------------------------------
resource "proxmox_vm_qemu" "rac_node1" {
  name        = "rac-node1"
  target_node = var.target_node
  clone       = var.oracle_db_template
  full_clone  = true
  tags        = "terraform;jms-ha-poc;rac"
  vm_state    = "running"

  cpu {
    cores   = 2
    sockets = 1
    type    = "host"
  }

  agent  = 1
  memory = 8192
  scsihw = "virtio-scsi-single"

  # --- CLOUD-INIT ---
  os_type    = "cloud-init"
  ciuser     = "prasad"
  cipassword = "$6$RCgEI/BqaRcYexG6$23e3jxp8rWlCLohpW76PU087lv5QdHaQeOfkRz4gM59IZV7LjkPnBByjSNkp2LOdkYJpZFISllArj0nkNY3z41"
  nameserver = "8.8.8.8"
  ipconfig0  = "ip=192.168.29.120/24,gw=192.168.29.1"

  sshkeys = <<EOF
  ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDR8bebUAw7YlTkeorcHNbG2feJtJ9N62AF77rX2CXax prasadgujar22
  EOF

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
  }

  boot = "order=scsi0"

  disks {
    scsi {
      # OS disk
      scsi0 {
        disk {
          size    = "40G"
          storage = "local-lvm"
        }
      }
      # ASM DATA shared disk (use shared storage pool for real RAC)
      scsi1 {
        disk {
          size    = "40G"
          storage = var.asm_storage
        }
      }
      # ASM FRA shared disk (use shared storage pool for real RAC)
      scsi2 {
        disk {
          size    = "60G"
          storage = var.asm_storage
        }
      }
    }
    ide {
      ide2 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
  }
}

# -----------------------------------------------------------------------------
# Oracle RAC Node 2
# -----------------------------------------------------------------------------
resource "proxmox_vm_qemu" "rac_node2" {
  name        = "rac-node2"
  target_node = var.target_node
  clone       = var.oracle_db_template
  full_clone  = true
  tags        = "terraform;jms-ha-poc;rac"
  vm_state    = "running"

  cpu {
    cores   = 2
    sockets = 1
    type    = "host"
  }

  agent  = 1
  memory = 8192
  scsihw = "virtio-scsi-single"

  # --- CLOUD-INIT ---
  os_type    = "cloud-init"
  ciuser     = "prasad"
  cipassword = "$6$RCgEI/BqaRcYexG6$23e3jxp8rWlCLohpW76PU087lv5QdHaQeOfkRz4gM59IZV7LjkPnBByjSNkp2LOdkYJpZFISllArj0nkNY3z41"
  nameserver = "8.8.8.8"
  ipconfig0  = "ip=192.168.29.121/24,gw=192.168.29.1"

  sshkeys = <<EOF
  ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDR8bebUAw7YlTkeorcHNbG2feJtJ9N62AF77rX2CXax prasadgujar22
  EOF

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
  }

  boot = "order=scsi0"

  # NOTE: scsi1 and scsi2 must point to the same shared storage disks as rac-node1.
  #       Configure asm_storage variable to a shared storage pool (NFS/iSCSI).
  disks {
    scsi {
      # OS disk
      scsi0 {
        disk {
          size    = "40G"
          storage = "local-lvm"
        }
      }
      # ASM DATA shared disk (must be same physical disk as rac-node1 scsi1)
      scsi1 {
        disk {
          size    = "40G"
          storage = var.asm_storage
        }
      }
      # ASM FRA shared disk (must be same physical disk as rac-node1 scsi2)
      scsi2 {
        disk {
          size    = "60G"
          storage = var.asm_storage
        }
      }
    }
    ide {
      ide2 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
  }

  depends_on = [proxmox_vm_qemu.rac_node1]
}

# -----------------------------------------------------------------------------
# WebLogic Admin Server
# -----------------------------------------------------------------------------
resource "proxmox_vm_qemu" "wls_admin" {
  name        = "wls-admin"
  target_node = var.target_node
  clone       = var.wls_template
  full_clone  = true
  tags        = "terraform;jms-ha-poc;wls"
  vm_state    = "running"

  cpu {
    cores   = 1
    sockets = 1
    type    = "host"
  }

  agent  = 1
  memory = 2048
  scsihw = "virtio-scsi-single"

  # --- CLOUD-INIT ---
  os_type    = "cloud-init"
  ciuser     = "prasad"
  cipassword = "$6$RCgEI/BqaRcYexG6$23e3jxp8rWlCLohpW76PU087lv5QdHaQeOfkRz4gM59IZV7LjkPnBByjSNkp2LOdkYJpZFISllArj0nkNY3z41"
  nameserver = "8.8.8.8"
  ipconfig0  = "ip=192.168.29.122/24,gw=192.168.29.1"

  sshkeys = <<EOF
  ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDR8bebUAw7YlTkeorcHNbG2feJtJ9N62AF77rX2CXax prasadgujar22
  EOF

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
  }

  boot = "order=scsi0"

  disks {
    scsi {
      scsi0 {
        disk {
          size    = "40G"
          storage = "local-lvm"
        }
      }
    }
    ide {
      ide2 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
  }
}

# -----------------------------------------------------------------------------
# WebLogic Managed Server 1
# -----------------------------------------------------------------------------
resource "proxmox_vm_qemu" "wls_node1" {
  name        = "wls-node1"
  target_node = var.target_node
  clone       = var.wls_template
  full_clone  = true
  tags        = "terraform;jms-ha-poc;wls"
  vm_state    = "running"

  cpu {
    cores   = 2
    sockets = 1
    type    = "host"
  }

  agent  = 1
  memory = 3072
  scsihw = "virtio-scsi-single"

  # --- CLOUD-INIT ---
  os_type    = "cloud-init"
  ciuser     = "prasad"
  cipassword = "$6$RCgEI/BqaRcYexG6$23e3jxp8rWlCLohpW76PU087lv5QdHaQeOfkRz4gM59IZV7LjkPnBByjSNkp2LOdkYJpZFISllArj0nkNY3z41"
  nameserver = "8.8.8.8"
  ipconfig0  = "ip=192.168.29.123/24,gw=192.168.29.1"

  sshkeys = <<EOF
  ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDR8bebUAw7YlTkeorcHNbG2feJtJ9N62AF77rX2CXax prasadgujar22
  EOF

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
  }

  boot = "order=scsi0"

  disks {
    scsi {
      scsi0 {
        disk {
          size    = "50G"
          storage = "local-lvm"
        }
      }
    }
    ide {
      ide2 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
  }
}

# -----------------------------------------------------------------------------
# WebLogic Managed Server 2
# -----------------------------------------------------------------------------
resource "proxmox_vm_qemu" "wls_node2" {
  name        = "wls-node2"
  target_node = var.target_node
  clone       = var.wls_template
  full_clone  = true
  tags        = "terraform;jms-ha-poc;wls"
  vm_state    = "running"

  cpu {
    cores   = 2
    sockets = 1
    type    = "host"
  }

  agent  = 1
  memory = 3072
  scsihw = "virtio-scsi-single"

  # --- CLOUD-INIT ---
  os_type    = "cloud-init"
  ciuser     = "prasad"
  cipassword = "$6$RCgEI/BqaRcYexG6$23e3jxp8rWlCLohpW76PU087lv5QdHaQeOfkRz4gM59IZV7LjkPnBByjSNkp2LOdkYJpZFISllArj0nkNY3z41"
  nameserver = "8.8.8.8"
  ipconfig0  = "ip=192.168.29.124/24,gw=192.168.29.1"

  sshkeys = <<EOF
  ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDR8bebUAw7YlTkeorcHNbG2feJtJ9N62AF77rX2CXax prasadgujar22
  EOF

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
  }

  boot = "order=scsi0"

  disks {
    scsi {
      scsi0 {
        disk {
          size    = "50G"
          storage = "local-lvm"
        }
      }
    }
    ide {
      ide2 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
  }
}
