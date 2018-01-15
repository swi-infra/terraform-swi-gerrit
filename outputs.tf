## Output

output "master.ips" {
  value = "${azurerm_network_interface.master_nic.*.private_ip_address}"
}

output "external.ip" {
  value = "${element(concat(azurerm_public_ip.public_ip.*.ip_address,
                            azurerm_lb.lb_private.*.private_ip_address), 0)}"
}
