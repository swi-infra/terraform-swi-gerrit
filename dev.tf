## dev vm (optional)

resource "azurerm_public_ip" "dev_ip" {
  count                        = var.dev_vm
  name                         = "${var.env_prefix}devvm-ip"
  location                     = var.location
  resource_group_name          = var.resource_group
  public_ip_address_allocation = "dynamic"
}

resource "azurerm_network_interface" "dev_nic" {
  count               = var.dev_vm
  name                = "${var.env_prefix}devvm-nic"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "${var.env_prefix}devvm-ipconfig"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.dev_ip.id
  }
}

resource "azurerm_virtual_machine" "dev" {
  count                 = var.dev_vm
  name                  = "${var.env_prefix}devvm"
  location              = var.location
  resource_group_name   = var.resource_group
  vm_size               = "Basic_A0"
  network_interface_ids = ["${azurerm_network_interface.dev_nic.*.id[count.index]}"]
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  plan {
    name      = var.image_sku
    publisher = var.image_publisher
    product   = var.image_offer
  }

  storage_os_disk {
    name              = "${var.env_prefix}devvm-osdisk"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = "${var.env_prefix}dev"
    admin_username = var.admin_username
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = var.admin_ssh_key
    }
  }
}

