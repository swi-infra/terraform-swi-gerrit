## load balancers

## Public

resource "azurerm_public_ip" "public_ip" {
  count                        = "${var.is_public}"
  name                         = "${var.env_prefix}publicip"
  location                     = "${var.location}"
  resource_group_name          = "${var.resource_group}"
  public_ip_address_allocation = "static"
}

resource "azurerm_lb" "loadbalancer_public" {
  count               = "${var.is_public}"
  name                = "${var.env_prefix}loadbalancer"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group}"

  frontend_ip_configuration {
    name                 = "${var.env_prefix}mainip"
    public_ip_address_id = "${azurerm_public_ip.public_ip.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "loadbalancer_public_backend" {
  count               = "${var.is_public}"
  name                = "${var.env_prefix}loadbalancer-backend"
  resource_group_name = "${var.resource_group}"
  loadbalancer_id     = "${azurerm_lb.loadbalancer_public.id}"
}

## Private

resource "azurerm_lb" "loadbalancer_private" {
  count               = "${1 - var.is_public}"
  name                = "${var.env_prefix}loadbalancer"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group}"

  frontend_ip_configuration {
    name                 = "${var.env_prefix}mainip"
    subnet_id            = "${var.subnet_id}"
  }
}

resource "azurerm_lb_backend_address_pool" "loadbalancer_private_backend" {
  count               = "${1 - var.is_public}"
  name                = "${var.env_prefix}loadbalancer-backend"
  resource_group_name = "${var.resource_group}"
  loadbalancer_id     = "${azurerm_lb.loadbalancer_private.id}"
}

