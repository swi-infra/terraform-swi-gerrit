## load balancers

## Public

resource "azurerm_public_ip" "public_ip" {
  count                        = "${var.public_lb}"
  name                         = "${var.env_prefix}publicip"
  location                     = "${var.location}"
  resource_group_name          = "${var.resource_group}"
  public_ip_address_allocation = "static"
}

resource "azurerm_lb" "loadbalancer_public" {
  count               = "${var.public_lb}"
  name                = "${var.env_prefix}loadbalancer"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group}"

  frontend_ip_configuration {
    name                 = "${var.env_prefix}mainip"
    public_ip_address_id = "${azurerm_public_ip.public_ip.id}"
  }
}

## Private

resource "azurerm_lb" "loadbalancer_private" {
  count               = "${var.private_lb}"
  name                = "${var.env_prefix}loadbalancer"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group}"

  frontend_ip_configuration {
    name                 = "${var.env_prefix}mainip"
    subnet_id            = "${var.subnet_id}"
  }
}
