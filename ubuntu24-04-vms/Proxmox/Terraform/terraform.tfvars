# Proxmox API connection details
proxmox_api_url = "https://192.168.29.158:8006"

# Proxmox node settings
target_node = "praslab" # Replace with your Proxmox node name

# Storage settings
disk_storage = "local-lvm"

# Network settings
network_bridge = "vmbr0"
gateway        = "192.168.29.1"
dns_servers    = ["8.8.8.8", "8.8.4.4"]
dns_domain     = "home"

# SSH public keys for cloud-init
ssh_public_keys = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCb7fcDZfIG+SxuP5UsZaoHPdh9MNxtEL5xRI71hzMS5h4SsZiPGEP4shLcF9YxSncdOJpyOJ6OgumNSFWj2pCd/kqg9wQzk/E1o+FRMbWX5gX8xMzPig8mmKkW5szhnP+yYYYuGUqvTAKX4ua1mQwL6PipWKYJ1huJhgpGHrvSQ6kuywJ23hw4klcaiZKXVYtvTi8pqZHhE5Kx1237a/6GRwnbGLEp0UR2Q/KPf6yRgZIrCdD+AtOznSBsBhf5vqcfnnwEIC/DOnqcOTahBVtFhOKuPSv3bUikAD4Vw7SIRteMltUVkd/O341fx+diKOBY7a8M6pn81HEZEmGsr7rT sam@SamMac.local"

# VM configurations - each VM with its own settings
vms = {
  "master" = {
    ip_address = "192.168.29.111/24"
    cores      = 2
    memory     = 4096
    disk_size  = "30"
  }
  "worker1" = {
    ip_address = "192.168.29.112/24"
    cores      = 2
    memory     = 4096
    disk_size  = "30"
  }
 "worker2" = {
    ip_address = "192.168.29.113/24"
    cores      = 2
    memory     = 4096
    disk_size  = "30"
  }
}
