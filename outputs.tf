## Output

output "master.ips" {
  value = "${azurerm_network_interface.master_nic.*.private_ip_address}"
}

