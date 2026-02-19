resource "proxmox_vm_qemu" "oracle_nodes" {
  count       = 2
  name        = "worker-${count.index + 1}"
  target_node = var.target_node
  clone       = var.template_name
  full_clone  = true
  tags        = "terraform;packer-gold-image"
  vm_state    = "running"

  cpu {
    cores   = 2
    sockets = 1
    type    = "host"
  }

  # VM Hardware
  agent  = 1
  memory = 4096
  scsihw = "virtio-scsi-single"

  # --- CLOUD-INIT CONFIGURATION ---
  os_type = "cloud-init" # Critical: Tells Proxmox to use Cloud-Init

  # Set VM Username and Password
  ciuser     = "prasad"
  cipassword = "$6$RCgEI/BqaRcYexG6$23e3jxp8rWlCLohpW76PU087lv5QdHaQeOfkRz4gM59IZV7LjkPnBByjSNkp2LOdkYJpZFISllArj0nkNY3z41"

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0" # Ensure this matches your Proxmox bridge name
  }

  # Set Static IP (Use count.index to give each VM a unique IP)
  # Format: "ip=<ip>/<cidr>,gw=<gateway>"
  ipconfig0 = "ip=192.168.29.${110 + count.index}/24,gw=192.168.29.1"

  # Optional: Set DNS servers
  nameserver = "8.8.8.8"

  # Inject your public SSH key for passwordless login
  sshkeys = <<EOF
  ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDR8bebUAw7YlTkeorcHNbG2feJtJ9N62AF77rX2CXax prasadgujar22
  EOF

  # Force the VM to boot from the SCSI 0 drive (your main OS disk)
  boot = "order=scsi0"

  # Ensure the disk is correctly defined in the resource
  disks {
    scsi {
      scsi0 {
        disk {
          size    = "20G"
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

resource "proxmox_vm_qemu" "master_node" {
  count       = 1
  name        = "master"
  target_node = var.target_node
  clone       = var.template_name
  full_clone  = true
  tags        = "terraform;packer-gold-image"
  vm_state    = "running"

  cpu {
    cores   = 2
    sockets = 1
    type    = "host"
  }

  # VM Hardware
  agent  = 1
  memory = 4096
  scsihw = "virtio-scsi-single"

  # --- CLOUD-INIT CONFIGURATION ---
  os_type = "cloud-init" # Critical: Tells Proxmox to use Cloud-Init

  # Set VM Username and Password
  ciuser     = "prasad"
  cipassword = "$6$RCgEI/BqaRcYexG6$23e3jxp8rWlCLohpW76PU087lv5QdHaQeOfkRz4gM59IZV7LjkPnBByjSNkp2LOdkYJpZFISllArj0nkNY3z41"

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0" # Ensure this matches your Proxmox bridge name
  }

  # Set Static IP
  # Format: "ip=<ip>/<cidr>,gw=<gateway>"
  ipconfig0 = "ip=192.168.29.109/24,gw=192.168.29.1"

  # Optional: Set DNS servers
  nameserver = "8.8.8.8"

  # Inject your public SSH key for passwordless login
  sshkeys = <<EOF
  ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDR8bebUAw7YlTkeorcHNbG2feJtJ9N62AF77rX2CXax prasadgujar22
  EOF

  # Force the VM to boot from the SCSI 0 drive (your main OS disk)
  boot = "order=scsi0"

  # Ensure the disk is correctly defined in the resource
  disks {
    scsi {
      scsi0 {
        disk {
          size    = "20G"
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
