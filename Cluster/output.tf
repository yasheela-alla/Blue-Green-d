output "vm_id" {
  value = azurerm_linux_virtual_machine.Server.id
}

output "public_ip" {
  value = azurerm_public_ip.Server_ip.id
}

output "resource_group" {
  value = azurerm_resource_group.r_grp.name
}

output "network_interface_ids" {
  value = azurerm_network_interface.Server_nic.id
}
