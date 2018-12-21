## IPs

## Public

resource "azurerm_public_ip" "public_ip" {
  count                        = "${var.is_public}"
  name                         = "${var.env_prefix}publicip"
  location                     = "${var.location}"
  resource_group_name          = "${var.resource_group}"
  public_ip_address_allocation = "static"
  domain_name_label            = "${var.master_ip_domain}"
}

