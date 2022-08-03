terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.62.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "random_string" "fqdn" {
  length = 6
  special = false
  upper = false
  number = false
}

resource "azurerm_resource_group" "main" {
  name = var.resource_group_name
  location = var.location
  tags = var.tags
}

resource "azurerm_network_security_group" "main" {
  name = "${var.prefix}-network"
  resource_group_name = azurerm_resource_group.main.name
  location = azurerm_resource_group.main.location
  tags = var.tags
}

resource "azurerm_network_security_rule" "main" {
  for_each = local.nsgrules
  name = each.key
  direction = each.value.direction
  access = each.value.access
  priority = each.value.priority
  protocol = each.value.protocol
  source_port_range = each.value.source_port_range
  destination_port_range = each.value.destination_port_range
  source_address_prefix = each.value.source_address_prefix
  destination_address_prefix = each.value.destination_address_prefix
  resource_group_name = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}

resource "azurerm_virtual_network" "main" {
  name = "${var.prefix}-network"
  address_space = ["10.0.0.0/16"]
  location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags = var.tags
}

resource "azurerm_subnet" "main" {
  name = "${var.prefix}-subnet"
  resource_group_name = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "main" {
  name = "${var.prefix}-public-ip"
  location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method = "Static"
  domain_name_label = random_string.fqdn.result
  tags = var.tags
}

resource "azurerm_lb" "main" {
  name = "${var.prefix}main-lb"
  location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  frontend_ip_configuration {
    name = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.main.id
  }
  tags = var.tags
}

resource "azurerm_lb_backend_address_pool" "bpepool" {
  loadbalancer_id = azurerm_lb.main.id
  name = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "main" {
  resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id = azurerm_lb.main.id
  name = "${var.prefix}-ssh-running-probe"
  port = var.application_port
}

resource "azurerm_lb_rule" "lbnatrule" {
  resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id = azurerm_lb.main.id
  name = "http"
  protocol = "Tcp"
  frontend_port = var.application_port
  backend_port = var.application_port
  backend_address_pool_id = azurerm_lb_backend_address_pool.bpepool.id
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id = azurerm_lb_probe.main.id
}

resource "azurerm_network_interface" "main" {
 count = var.counter
 name = "accnic${count.index}"
 location = azurerm_resource_group.main.location
 resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name = "vmNICConfig"
    subnet_id = azurerm_subnet.main.id
    private_ip_address_allocation = "dynamic"
  }
  
  tags = var.tags
}

data "azurerm_resource_group" "image" {
  name                = var.packer_resource_group_name
}

data "azurerm_image" "image" {
  name                = var.packer_image_name
  resource_group_name = data.azurerm_resource_group.image.name
}

resource "azurerm_linux_virtual_machine" "main" {
  count = var.counter
  name = "myvm${count.index}"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  size                            = "Standard_DS1_v2"
  admin_username                  = var.username
  admin_password                  = var.password

  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.main[count.index].id,
  ]

  source_image_id = data.azurerm_image.image.id

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  tags = var.tags
}

