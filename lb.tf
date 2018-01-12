## load balancers

## Public

resource "azurerm_public_ip" "public_ip" {
  count                        = "${var.is_public}"
  name                         = "${var.env_prefix}publicip"
  location                     = "${var.location}"
  resource_group_name          = "${var.resource_group}"
  public_ip_address_allocation = "static"
}

resource "azurerm_lb" "lb_public" {
  count               = "${var.is_public}"
  name                = "${var.env_prefix}loadbalancer"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group}"

  frontend_ip_configuration {
    name                 = "${var.env_prefix}mainip"
    public_ip_address_id = "${azurerm_public_ip.public_ip.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "lb_public_backend" {
  count               = "${var.is_public}"
  name                = "${var.env_prefix}loadbalancer-backend"
  resource_group_name = "${var.resource_group}"
  loadbalancer_id     = "${azurerm_lb.lb_public.id}"
}

resource "azurerm_lb_rule" "lb_public_http" {
  count                          = "${var.is_public}"
  resource_group_name            = "${var.resource_group}"
  loadbalancer_id                = "${azurerm_lb.lb_public.id}"
  name                           = "${var.env_prefix}loadbalancer-rule-http"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "${var.env_prefix}mainip"
}

resource "azurerm_lb_rule" "lb_public_https" {
  count                          = "${var.is_public}"
  resource_group_name            = "${var.resource_group}"
  loadbalancer_id                = "${azurerm_lb.lb_public.id}"
  name                           = "${var.env_prefix}loadbalancer-rule-https"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "${var.env_prefix}mainip"
}

resource "azurerm_lb_rule" "lb_public_ssl" {
  count                          = "${var.is_public}"
  resource_group_name            = "${var.resource_group}"
  loadbalancer_id                = "${azurerm_lb.lb_public.id}"
  name                           = "${var.env_prefix}loadbalancer-rule-ssl"
  protocol                       = "Tcp"
  frontend_port                  = 29418
  backend_port                   = 29418
  frontend_ip_configuration_name = "${var.env_prefix}mainip"
}

## Private

resource "azurerm_lb" "lb_private" {
  count               = "${1 - var.is_public}"
  name                = "${var.env_prefix}loadbalancer"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group}"

  frontend_ip_configuration {
    name                 = "${var.env_prefix}mainip"
    subnet_id            = "${var.subnet_id}"
  }
}

resource "azurerm_lb_backend_address_pool" "lb_private_backend" {
  count               = "${1 - var.is_public}"
  name                = "${var.env_prefix}loadbalancer-backend"
  resource_group_name = "${var.resource_group}"
  loadbalancer_id     = "${azurerm_lb.lb_private.id}"
}

resource "azurerm_lb_rule" "lb_private_http" {
  count                          = "${1 - var.is_public}"
  resource_group_name            = "${var.resource_group}"
  loadbalancer_id                = "${azurerm_lb.lb_private.id}"
  name                           = "${var.env_prefix}loadbalancer-rule-http"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "${var.env_prefix}mainip"
}

resource "azurerm_lb_rule" "lb_private_https" {
  count                          = "${1 - var.is_public}"
  resource_group_name            = "${var.resource_group}"
  loadbalancer_id                = "${azurerm_lb.lb_private.id}"
  name                           = "${var.env_prefix}loadbalancer-rule-https"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "${var.env_prefix}mainip"
}

resource "azurerm_lb_rule" "lb_private_ssl" {
  count                          = "${1 - var.is_public}"
  resource_group_name            = "${var.resource_group}"
  loadbalancer_id                = "${azurerm_lb.lb_private.id}"
  name                           = "${var.env_prefix}loadbalancer-rule-ssl"
  protocol                       = "Tcp"
  frontend_port                  = 29418
  backend_port                   = 29418
  frontend_ip_configuration_name = "${var.env_prefix}mainip"
}

