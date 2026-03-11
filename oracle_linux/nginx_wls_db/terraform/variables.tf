# =============================================================================
# variables.tf – Nginx + WebLogic Cluster + Oracle DB setup
# =============================================================================

# --- Proxmox API ---
variable "proxmox_api_url" {
  type        = string
  description = "Proxmox API URL (e.g. https://192.168.29.10:8006/api2/json)"
}

variable "proxmox_api_token_id" {
  type        = string
  description = "Proxmox API token ID (user@realm!tokenid)"
}

variable "proxmox_api_token_secret" {
  type        = string
  sensitive   = true
  description = "Proxmox API token secret"
}

# --- Proxmox node / template ---
variable "target_node" {
  type        = string
  default     = "praslab"
  description = "Proxmox node name"
}

variable "template_name" {
  type        = string
  default     = "oraclelinux-9-gold-template"
  description = "Cloud-init VM template to clone"
}

variable "storage" {
  type        = string
  default     = "local-lvm"
  description = "Proxmox storage pool for VM disks"
}

variable "network_bridge" {
  type        = string
  default     = "vmbr0"
  description = "Proxmox network bridge"
}

variable "gateway" {
  type        = string
  default     = "192.168.29.1"
  description = "Default gateway for all VMs"
}

variable "nameserver" {
  type        = string
  default     = "8.8.8.8"
  description = "DNS server"
}

# --- Cloud-init credentials ---
variable "vm_user" {
  type        = string
  default     = "prasad"
  description = "Cloud-init OS username"
}

variable "vm_password_hash" {
  type        = string
  sensitive   = true
  default     = "$6$RCgEI/BqaRcYexG6$23e3jxp8rWlCLohpW76PU087lv5QdHaQeOfkRz4gM59IZV7LjkPnBByjSNkp2LOdkYJpZFISllArj0nkNY3z41"
  description = "SHA-512 hashed password for cloud-init user"
}

variable "ssh_public_key" {
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGBOo6Nuljv73LmCreszZUi2Da8ishoisgQcoEdk8yVg prasad.gujar@me.com"
  description = "SSH public key injected into all VMs"
}

# --- IP addressing ---
# Nginx: 192.168.29.130
# WLS Admin: 192.168.29.131
# WLS Node1:  192.168.29.132
# WLS Node2:  192.168.29.133
# Oracle DB:  192.168.29.134

variable "nginx_ip" {
  type        = string
  default     = "192.168.29.130"
  description = "Static IP for the Nginx load balancer"
}

variable "wls_admin_ip" {
  type        = string
  default     = "192.168.29.131"
  description = "Static IP for the WebLogic Admin Server"
}

variable "wls_node_ips" {
  type        = list(string)
  default     = ["192.168.29.132", "192.168.29.133"]
  description = "Static IPs for WebLogic Managed Server nodes"
}

variable "oracle_db_ip" {
  type        = string
  default     = "192.168.29.134"
  description = "Static IP for the Oracle DB server"
}

# --- VM sizing ---
variable "nginx_cpu_cores" {
  type    = number
  default = 2
}

variable "nginx_memory_mb" {
  type    = number
  default = 2048
}

variable "nginx_disk_size" {
  type    = string
  default = "20G"
}

variable "wls_admin_cpu_cores" {
  type    = number
  default = 4
}

variable "wls_admin_memory_mb" {
  type    = number
  default = 8192
}

variable "wls_admin_disk_size" {
  type    = string
  default = "40G"
}

variable "wls_node_cpu_cores" {
  type    = number
  default = 4
}

variable "wls_node_memory_mb" {
  type    = number
  default = 8192
}

variable "wls_node_disk_size" {
  type    = string
  default = "40G"
}

variable "oracle_db_cpu_cores" {
  type    = number
  default = 4
}

variable "oracle_db_memory_mb" {
  type    = number
  default = 16384
  description = "16 GB – minimum for Oracle 19c database"
}

variable "oracle_db_disk_size" {
  type    = string
  default = "100G"
  description = "OS disk; data/fra disks are added separately"
}

variable "oracle_db_data_disk_size" {
  type    = string
  default = "100G"
  description = "Dedicated data disk for Oracle datafiles"
}

variable "oracle_db_fra_disk_size" {
  type    = string
  default = "50G"
  description = "Dedicated disk for Oracle Fast Recovery Area"
}
