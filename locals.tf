locals { 
    nsgrules = {
        vmss = {
        name = "allow-all-vmss"
        priority = 100
        direction = "Inbound"
        access = "Allow"
        protocol = "TCP"
        source_port_range = "*"
        destination_port_range = "*"
        source_address_prefix = "VirtualNetwork"
        destination_address_prefix = "*"
        }

        lb = {
        name                       = "allow-lb"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "TCP"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "AzureLoadBalancer"
        destination_address_prefix = "*"
        }

        internet = {
        name                       = "deny-internet"
        priority                   = 120
        direction                  = "Inbound"
        access                     = "Deny"
        protocol                   = "TCP"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
        }
    }
}