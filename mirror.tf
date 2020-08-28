## mirror(s)

data "template_file" "mirror_config" {
  template = "${file("${path.module}/configs/gerrit-mirror-azure.yml")}"

  vars {
    config_url = "${var.config_url}"
    master_hostname = "${var.master_hostname}"
    gerrit_hostname = "${var.gerrit_hostname}"
  }
}

resource "azurerm_public_ip" "mirror_public_ip" {
  count                        = "${var.is_public * length(var.mirror_distribution)}"
  name                         = "${var.env_prefix}mirror${count.index}-publicip"
  location                     = "${var.mirror_distribution[count.index]}"
  resource_group_name          = "${var.resource_group}"
  allocation_method            = "Dynamic"
  domain_name_label            = "${var.mirror_ip_domains[count.index]}"
}

resource "azurerm_network_interface" "mirror_nic" {
  count                     = "${length(var.mirror_distribution)}"
  name                      = "${var.env_prefix}mirror${count.index}-nic"
  location                  = "${var.mirror_distribution[count.index]}"
  resource_group_name       = "${var.resource_group}"
  network_security_group_id = "${azurerm_network_security_group.mirror_nsg.*.id[count.index]}"

  ip_configuration {
    name                          = "${var.env_prefix}mirror${count.index}-ipconfig"
    subnet_id                     = "${var.subnet_id[var.mirror_distribution[count.index]]}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = "${var.load_balancer ? "" : (var.is_public ? azurerm_public_ip.mirror_public_ip.*.id[count.index] : "")}"
    load_balancer_backend_address_pools_ids = [
      "${coalescelist(azurerm_lb_backend_address_pool.lb_public_backend.*.id,
                      azurerm_lb_backend_address_pool.lb_private_backend.*.id)}",
    ]
  }
}

resource "azurerm_managed_disk" "mirror_data" {
  count                = "${length(var.mirror_distribution)}"
  name                 = "${var.env_prefix}mirror${count.index}-data"
  location             = "${var.mirror_distribution[count.index]}"
  resource_group_name  = "${var.resource_group}"
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = "${var.data_disk_size_gb}"
}

resource "azurerm_availability_set" "mirror_availability_set" {
  count                = "${length(var.mirror_locations)}"
  name                 = "${var.env_prefix}mirror-availabilityset-${var.mirror_locations[count.index]}"
  location             = "${var.mirror_locations[count.index]}"
  resource_group_name  = "${var.resource_group}"
  managed              = "true"
  platform_update_domain_count = "${var.mirror_platform_update_domain_count[count.index]}"
  platform_fault_domain_count  = "${var.mirror_platform_fault_domain_count[count.index]}"
}

resource "azurerm_virtual_machine" "mirror" {
  count                 = "${length(var.mirror_distribution)}"
  name                  = "${var.env_prefix}mirror${count.index}"
  location              = "${var.mirror_distribution[count.index]}"
  resource_group_name   = "${var.resource_group}"
  vm_size               = "${var.mirror_vm_size}"
  network_interface_ids = ["${azurerm_network_interface.mirror_nic.*.id[count.index]}"]
  availability_set_id   = "${azurerm_availability_set.mirror_availability_set.*.id[index(var.mirror_locations, var.mirror_distribution[count.index])]}"
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "${var.image_publisher}"
    offer     = "${var.image_offer}"
    sku       = "${var.image_sku}"
    version   = "${var.image_version}"
  }

  plan {
    name      = var.image_sku
    publisher = var.image_publisher
    product   = var.image_offer
  }

  storage_os_disk {
    name              = "${var.env_prefix}mirror${count.index}-osdisk"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  storage_data_disk {
    name            = "${azurerm_managed_disk.mirror_data.*.name[count.index]}"
    managed_disk_id = "${azurerm_managed_disk.mirror_data.*.id[count.index]}"
    create_option   = "Attach"
    lun             = 0
    disk_size_gb    = "${azurerm_managed_disk.mirror_data.*.disk_size_gb[count.index]}"
  }

  os_profile {
    computer_name  = "${var.env_prefix}mirror${count.index}"
    admin_username = "${var.admin_username}"
    custom_data    = "${data.template_file.mirror_config.rendered}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = "${var.admin_ssh_key}"
    }
  }
}

resource "null_resource" "mirror_config_update" {
  count                 = "${length(var.mirror_distribution)}"

  triggers {
    template_rendered = "${data.template_file.mirror_config.rendered}"
  }

  connection {
    type = "ssh"
    user = "core"
    host = "${azurerm_public_ip.mirror_public_ip.*.ip_address[count.index]}"
    private_key = "${file("~/.ssh/id_rsa")}"
  }

  provisioner "file" {
    content     = "${data.template_file.mirror_config.rendered}"
    destination = "/tmp/CustomData"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo diff /tmp/CustomData /var/lib/waagent/CustomData | tee /tmp/CustomData-diff",
      "sudo cp /tmp/CustomData /var/lib/waagent/CustomData"
    ]
  }
}

# Firewall

resource "azurerm_network_security_group" "mirror_nsg" {
  count                 = "${length(var.mirror_distribution)}"
  name                  = "${var.env_prefix}mirror${count.index}"
  location              = "${var.mirror_distribution[count.index]}"
  resource_group_name   = "${var.resource_group}"
}

resource "azurerm_network_security_rule" "mirror_nsg_ssh" {
  count                         = "${length(var.mirror_distribution) * ((length(var.ssh_vm_address_prefix) != 0) ? 1 : 0)}"
  priority                      = 150
  name                          = "SSH"
  direction                     = "Inbound"
  access                        = "Allow"
  protocol                      = "Tcp"
  source_port_range             = "*"
  destination_port_range        = "22"
  source_address_prefixes       = "${values(var.ssh_vm_address_prefix)}"
  destination_address_prefix    = "*"
  resource_group_name           = "${var.resource_group}"
  network_security_group_name   = "${azurerm_network_security_group.mirror_nsg.*.name[count.index]}"
}

resource "azurerm_network_security_rule" "mirror_nsg_http" {
  count                         = "${length(var.mirror_distribution)}"
  priority                      = 170
  name                          = "HTTP"
  direction                     = "Inbound"
  access                        = "Allow"
  protocol                      = "Tcp"
  source_port_range             = "*"
  destination_port_range        = "80"
  source_address_prefix         = "*"
  destination_address_prefix    = "*"
  resource_group_name           = "${var.resource_group}"
  network_security_group_name   = "${azurerm_network_security_group.mirror_nsg.*.name[count.index]}"
}

resource "azurerm_network_security_rule" "mirror_nsg_https" {
  count                         = "${length(var.mirror_distribution)}"
  priority                      = 171
  name                          = "HTTPS"
  direction                     = "Inbound"
  access                        = "Allow"
  protocol                      = "Tcp"
  source_port_range             = "*"
  destination_port_range        = "443"
  source_address_prefix         = "*"
  destination_address_prefix    = "*"
  resource_group_name           = "${var.resource_group}"
  network_security_group_name   = "${azurerm_network_security_group.mirror_nsg.*.name[count.index]}"
}

resource "azurerm_network_security_rule" "mirror_nsg_gerrit_ssh" {
  count                         = "${length(var.mirror_distribution)}"
  priority                      = 180
  name                          = "Gerrit_SSH"
  direction                     = "Inbound"
  access                        = "Allow"
  protocol                      = "Tcp"
  source_port_range             = "*"
  destination_port_range        = "29418"
  source_address_prefix         = "*"
  destination_address_prefix    = "*"
  resource_group_name           = "${var.resource_group}"
  network_security_group_name   = "${azurerm_network_security_group.mirror_nsg.*.name[count.index]}"
}

resource "azurerm_network_security_rule" "mirror_nsg_git_sync_ssh" {
  count                         = "${length(var.mirror_distribution)}"
  priority                      = 190
  name                          = "Git-Sync_SSH"
  direction                     = "Inbound"
  access                        = "Allow"
  protocol                      = "Tcp"
  source_port_range             = "*"
  destination_port_range        = "22022"
  source_address_prefix         = "${azurerm_public_ip.public_ip.ip_address}"
  destination_address_prefix    = "*"
  resource_group_name           = "${var.resource_group}"
  network_security_group_name   = "${azurerm_network_security_group.mirror_nsg.*.name[count.index]}"
}

