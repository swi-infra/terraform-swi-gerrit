## IPs

## Public

resource "azurerm_public_ip" "public_ip" {
  count                        = var.is_public ? 1 : 0
  name                         = "${var.env_prefix}publicip"
  location                     = var.location
  resource_group_name          = var.resource_group
  allocation_method            = "Static"
  domain_name_label            = var.master_ip_domain

  tags = {
  CostCenter   = "901"
  }
}

