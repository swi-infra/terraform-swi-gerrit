## load balancer

resource "azurerm_lb" "loadbalancer" {
  name                = "${var.env_prefix}loadbalancer"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group}"

  frontend_ip_configuration {
    name                 = "${var.env_prefix}mainip"
    subnet_id            = "${var.subnet_id}"
  }
}
