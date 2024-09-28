provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "r-grp"
  location = "East Japan"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "yasheela-vnet"
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    Name = "yasheela-vnet"
  }
}

resource "azurerm_subnet" "subnet" {
  count               = 2
  name                = "yasheela-subnet-${count.index}"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes    = ["10.0.${count.index}.0/24"]

  tags = {
    Name = "yasheela-subnet-${count.index}"
  }
}

resource "azurerm_public_ip" "public_ip" {
  name                = "yasheela-public-ip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"

  tags = {
    Name = "yasheela-public-ip"
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = "yasheela-nsg"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  tags = {
    Name = "yasheela-nsg"
  }
}

resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "Allow-SSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name         = azurerm_resource_group.rg.name
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "yasheela-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "yasheela"

  agent_pool_profile {
    name       = "agentpool"
    count      = 3
    vm_size    = "Standard_DS2_v2"
    os_type    = "Linux"
    max_pods   = 110
    mode       = "System"
    availability_zone = ["1", "2", "3"]
  }

  linux_profile {
    admin_username = "azureuser"
    ssh_key {
      key_data = var.ssh_key
    }
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  role_based_access_control {
    enabled = true
  }

  network_profile {
    network_plugin = "azure"
    load_balancer_sku = "standard"
  }

  tags = {
    Name = "yasheela-aks"
  }
}

variable "ssh_key" {
  description = "SSH public key for the AKS cluster"
}

variable "client_id" {
  description = "Client ID of the Service Principal"
}

variable "client_secret" {
  description = "Client Secret of the Service Principal"
}
