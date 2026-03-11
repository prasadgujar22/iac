# =============================================================================
# outputs.tf – surface VM IPs for Ansible inventory / documentation
# =============================================================================

output "nginx_server_ip" {
  description = "IP address of the Nginx load balancer"
  value       = var.nginx_ip
}

output "nginx_server_name" {
  description = "VM name of the Nginx load balancer"
  value       = proxmox_vm_qemu.nginx_server.name
}

output "wls_admin_ip" {
  description = "IP address of the WebLogic Administration Server"
  value       = var.wls_admin_ip
}

output "wls_admin_name" {
  description = "VM name of the WebLogic Administration Server"
  value       = proxmox_vm_qemu.wls_admin.name
}

output "wls_node_ips" {
  description = "IP addresses of the WebLogic Managed Server nodes"
  value       = var.wls_node_ips
}

output "wls_node_names" {
  description = "VM names of the WebLogic Managed Server nodes"
  value       = proxmox_vm_qemu.wls_nodes[*].name
}

output "oracle_db_ip" {
  description = "IP address of the Oracle Database server"
  value       = var.oracle_db_ip
}

output "oracle_db_name" {
  description = "VM name of the Oracle Database server"
  value       = proxmox_vm_qemu.oracle_db.name
}

output "ansible_inventory_hint" {
  description = "Quick copy-paste hint for Ansible hosts.ini"
  value = <<-EOT
    [nginx]
    nginx-server ansible_host=${var.nginx_ip}

    [wls_admin]
    wls-admin    ansible_host=${var.wls_admin_ip}

    [wls_managed]
    wls-node1    ansible_host=${var.wls_node_ips[0]}
    wls-node2    ansible_host=${var.wls_node_ips[1]}

    [db_server]
    oracle-db    ansible_host=${var.oracle_db_ip}
  EOT
}
