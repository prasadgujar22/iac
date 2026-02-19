resource "proxmox_vm_qemu" "alma_nodes" {
  count       = 2
  name        = "worker-${count.index + 1}"
  target_node = "praslab"
  clone       = "almalinux-9-gold-template"
  full_clone  = true
  tags = "terraform;packer-gold-image"
  vm_state = "running"

  cpu {
    cores   = 2
    sockets = 1
    type    = "host"
  }


  # VM Hardware
  agent   = 1
  memory  = 4096
  scsihw  = "virtio-scsi-single"

  
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
  ipconfig0 = "ip=192.168.29.${100 + count.index}/24,gw=192.168.29.1" 

  # Optional: Set DNS servers
  nameserver = "8.8.8.8"

  # Inject your public SSH key for passwordless login
  sshkeys = <<EOF
  ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDcAroQ4TQF8fBvg0eQCupIwfpByNFqpykPFgl1j+t6dKrP2NKjAvsZZnvlk0Nr0eyMqAwCc5ljz94ueBCSHktLFKtrP0jIC41Liv7D9XYwpCPZ7SvubDvXKcytA1rD1AFT1bDNOJPowvZK9mLy1AEo8Ey7Kl9y11o+no0yrhW6IM+/nnQkdUOFgskCX22xD81S++v8me9PGs+mREQgL7mrWCFpqvTP3kd9zRxI37Ifd9j1/T569Vxebvay92e5WCyCeuypO8jT1HVt768Euu5R7ZncjYfq0rr3Rk5jxdgeGfD1ehjcAiDLmTvR4egiLjHX5KzTBe3IMbsT5E0zuiqklyf+z+Su0mTgxIyEjTrZiMUeWWeelP26ihABCyZIMsSPeB9G29myvaUdxSslxeRIT0gjVD0uLpg6TF1buRyN5H2U8iJ/yVJ2KFOBW6GibTrDNcqMozIN7CjTsc7RmJUb2e1ciUAGAc7UfDyVRkkc+tp4YAx4riwA30rFcvcT968= prasad@pg-mac.local
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
  target_node = "praslab"
  clone       = "almalinux-9-gold-template"
  full_clone  = true
  tags = "terraform;packer-gold-image"
  vm_state = "running"

  cpu {
    cores   = 2
    sockets = 1
    type    = "host"
  }


  # VM Hardware
  agent   = 1
  memory  = 4096
  scsihw  = "virtio-scsi-single"


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
  #ipconfig0 = "ip=192.168.29.${100 + count.index}/24,gw=192.168.29.1"
  ipconfig0 = "ip=192.168.29.99/24,gw=192.168.29.1"

  # Optional: Set DNS servers
  nameserver = "8.8.8.8"

  # Inject your public SSH key for passwordless login
  sshkeys = <<EOF
  ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDcAroQ4TQF8fBvg0eQCupIwfpByNFqpykPFgl1j+t6dKrP2NKjAvsZZnvlk0Nr0eyMqAwCc5ljz94ueBCSHktLFKtrP0jIC41Liv7D9XYwpCPZ7SvubDvXKcytA1rD1AFT1bDNOJPowvZK9mLy1AEo8Ey7Kl9y11o+no0yrhW6IM+/nnQkdUOFgskCX22xD81S++v8me9PGs+mREQgL7mrWCFpqvTP3kd9zRxI37Ifd9j1/T569Vxebvay92e5WCyCeuypO8jT1HVt768Euu5R7ZncjYfq0rr3Rk5jxdgeGfD1ehjcAiDLmTvR4egiLjHX5KzTBe3IMbsT5E0zuiqklyf+z+Su0mTgxIyEjTrZiMUeWWeelP26ihABCyZIMsSPeB9G29myvaUdxSslxeRIT0gjVD0uLpg6TF1buRyN5H2U8iJ/yVJ2KFOBW6GibTrDNcqMozIN7CjTsc7RmJUb2e1ciUAGAc7UfDyVRkkc+tp4YAx4riwA30rFcvcT968= prasad@pg-mac.local
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
