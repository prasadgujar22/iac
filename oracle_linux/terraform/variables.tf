variable "proxmox_api_url" { type = string }
variable "proxmox_api_token_id" { type = string }
variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
}

variable "target_node" {
  type    = string
  default = "praslab" # Your node name
}

variable "template_name" {
  type    = string
  default = "oraclelinux-9-gold-template" # Matches your Packer vm_name
}
