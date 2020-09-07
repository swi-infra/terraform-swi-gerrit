## Output

output "master_ips" {
  value = "${azurerm_network_interface.master_nic.*.private_ip_address}"
}

output "mirror_ips" {
  value = "${azurerm_network_interface.mirror_nic.*.private_ip_address}"
}

output "external_master_ips" {
  value = "${azurerm_public_ip.public_ip.*.ip_address}"
}

output "external_mirror_ips" {
  value = "${azurerm_public_ip.mirror_public_ip.*.ip_address}"
}

output "dev_ip" {
  value = "${azurerm_network_interface.dev_nic.*.private_ip_address}"
}
