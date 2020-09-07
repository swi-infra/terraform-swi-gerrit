## load balancers

## Public

resource "azurerm_lb" "lb_public" {
  count               = (var.is_public ? 1 : 0 ) * (var.load_balancer ? 1 : 0)
  name                = "${var.env_prefix}loadbalancer"
  location            = var.location
  resource_group_name = var.resource_group

  frontend_ip_configuration {
    name                 = "${var.env_prefix}mainip"
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_lb_probe" "lb_public_probe_http" {
  count               = (var.is_public ? 1 : 0 ) * (var.load_balancer ? 1 : 0)
  name                = "${var.env_prefix}loadbalancer-probe-http"
  resource_group_name = var.resource_group
  loadbalancer_id     = azurerm_lb.lb_public.id
  port                = 80
}

resource "azurerm_lb_backend_address_pool" "lb_public_backend" {
  count               = (var.is_public ? 1 : 0 ) * (var.load_balancer ? 1 : 0)
  name                = "${var.env_prefix}loadbalancer-backend"
  resource_group_name = var.resource_group
  loadbalancer_id     = azurerm_lb.lb_public.id
}

resource "azurerm_lb_rule" "lb_public_http" {
  count                          = (var.is_public ? 1 : 0 ) * (var.load_balancer ? 1 : 0)
  resource_group_name            = var.resource_group
  loadbalancer_id                = azurerm_lb.lb_public.id
  name                           = "${var.env_prefix}loadbalancer-rule-http"
  probe_id                       = azurerm_lb_probe.lb_public_probe_http.id
  frontend_ip_configuration_name = "${var.env_prefix}mainip"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.lb_public_backend.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
}

resource "azurerm_lb_rule" "lb_public_https" {
  count                          = (var.is_public ? 1 : 0 ) * (var.load_balancer ? 1 : 0)
  resource_group_name            = var.resource_group
  loadbalancer_id                = azurerm_lb.lb_public.id
  name                           = "${var.env_prefix}loadbalancer-rule-https"
  probe_id                       = azurerm_lb_probe.lb_public_probe_http.id
  frontend_ip_configuration_name = "${var.env_prefix}mainip"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.lb_public_backend.id
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  idle_timeout_in_minutes        = 30
}

resource "azurerm_lb_rule" "lb_public_ssh" {
  count                          = (var.is_public ? 1 : 0 ) * (var.load_balancer ? 1 : 0)
  resource_group_name            = var.resource_group
  loadbalancer_id                = azurerm_lb.lb_public.id
  name                           = "${var.env_prefix}loadbalancer-rule-ssh"
  probe_id                       = azurerm_lb_probe.lb_public_probe_http.id
  frontend_ip_configuration_name = "${var.env_prefix}mainip"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.lb_public_backend.id
  protocol                       = "Tcp"
  frontend_port                  = 29418
  backend_port                   = 29418
  idle_timeout_in_minutes        = 30
}

## Private

resource "azurerm_lb" "lb_private" {
  count               = (1 - (var.is_public ? 1 : 0)) * (var.load_balancer ? 1 : 0)
  name                = "${var.env_prefix}loadbalancer"
  location            = var.location
  resource_group_name = var.resource_group

  frontend_ip_configuration {
    name                 = "${var.env_prefix}mainip"
    subnet_id            = var.subnet_id
  }
}

resource "azurerm_lb_probe" "lb_private_probe_http" {
  count               = (1 - (var.is_public ? 1 : 0)) * (var.load_balancer ? 1 : 0)
  name                = "${var.env_prefix}loadbalancer-probe-http"
  resource_group_name = var.resource_group
  loadbalancer_id     = azurerm_lb.lb_private.id
  port                = 80
}

resource "azurerm_lb_backend_address_pool" "lb_private_backend" {
  count               = (1 - (var.is_public ? 1 : 0)) * (var.load_balancer ? 1 : 0)
  name                = "${var.env_prefix}loadbalancer-backend"
  resource_group_name = var.resource_group
  loadbalancer_id     = azurerm_lb.lb_private.id
}

resource "azurerm_lb_rule" "lb_private_http" {
  count                          = (1 - (var.is_public ? 1 : 0)) * (var.load_balancer ? 1 : 0)
  resource_group_name            = var.resource_group
  loadbalancer_id                = azurerm_lb.lb_private.id
  name                           = "${var.env_prefix}loadbalancer-rule-http"
  probe_id                       = azurerm_lb_probe.lb_private_probe_http.id
  frontend_ip_configuration_name = "${var.env_prefix}mainip"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.lb_private_backend.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
}

resource "azurerm_lb_rule" "lb_private_https" {
  count                          = (1 - (var.is_public ? 1 : 0)) * (var.load_balancer ? 1 : 0)
  resource_group_name            = var.resource_group
  loadbalancer_id                = azurerm_lb.lb_private.id
  name                           = "${var.env_prefix}loadbalancer-rule-https"
  probe_id                       = azurerm_lb_probe.lb_private_probe_http.id
  frontend_ip_configuration_name = "${var.env_prefix}mainip"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.lb_private_backend.id
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
}

resource "azurerm_lb_rule" "lb_private_ssh" {
  count                          = (1 - (var.is_public ? 1 : 0)) * (var.load_balancer ? 1 : 0)
  resource_group_name            = var.resource_group
  loadbalancer_id                = azurerm_lb.lb_private.id
  name                           = "${var.env_prefix}loadbalancer-rule-ssh"
  probe_id                       = azurerm_lb_probe.lb_private_probe_http.id
  frontend_ip_configuration_name = "${var.env_prefix}mainip"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.lb_private_backend.id
  protocol                       = "Tcp"
  frontend_port                  = 29418
  backend_port                   = 29418
}

