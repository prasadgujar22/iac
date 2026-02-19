variable "proxmox_api_url" { type = string }
variable "proxmox_api_token_id" { type = string }
variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
}

variable "target_node" {
  type    = string
  default = "praslab"
}

variable "oracle_db_template" {
  type    = string
  default = "oraclelinux-9-gold-template" # Oracle DB RAC node template
}

variable "wls_template" {
  type    = string
  default = "oraclelinux-9-gold-template" # WebLogic node template
}

variable "asm_storage" {
  type        = string
  default     = "local-lvm"
  description = "Proxmox storage pool for ASM shared disks (use shared storage for real RAC)"
}
