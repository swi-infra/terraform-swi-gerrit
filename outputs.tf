## Output

output "master.ips" {
  value = "${azurerm_network_interface.master_nic.*.private_ip_address}"
}

output "mirror.ips" {
  value = "${azurerm_network_interface.mirror_nic.*.private_ip_address}"
}

output "external.master.ips" {
  value = "${element(concat(azurerm_public_ip.public_ip.*.ip_address,
                            azurerm_lb.lb_private.*.private_ip_address), 0)}"
}

output "external.mirror.ips" {
  value = "${azurerm_public_ip.mirror_public_ip.*.ip_address}"
}

output "dev.ip" {
  value = "${azurerm_network_interface.dev_nic.*.private_ip_address}"
}
