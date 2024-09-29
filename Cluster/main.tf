# Resource Group
resource "azurerm_resource_group" "r_grp" {
  name     = var.resource_group_name
  location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "y_vnet" {
  name                = "y-vnet"
  address_space       = [var.vnet_cidr]
  location            = var.location
  resource_group_name = azurerm_resource_group.r_grp.name
}

# Subnets
resource "azurerm_subnet" "y_subnet" {
  count                 = 2
  name                  = "y-subnet-${count.index}"
  resource_group_name   = azurerm_resource_group.r_grp.name
  virtual_network_name  = azurerm_virtual_network.y_vnet.name
  address_prefixes      = [element(var.subnet_prefix, count.index)]
}

# Network Security Group for AKS Cluster
resource "azurerm_network_security_group" "y_nsg" {
  name                = "y-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.r_grp.name

  security_rule {
    name                       = "AllowAllOutbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "y_aks" {
  name                = "y-aks"
  location            = var.location
  resource_group_name = azurerm_resource_group.r_grp.name
  dns_prefix          = "yaks"

  default_node_pool {
    name            = "default"
    node_count      = var.node_count
    vm_size         = "Standard_DS2_v2"
    vnet_subnet_id  = azurerm_subnet.y_subnet[0].id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "calico"
  }

  depends_on = [azurerm_subnet.y_subnet]
}

# SSH Key for Node Access
resource "azurerm_ssh_public_key" "y_ssh_key" {
  name                = "y-ssh-key"
  location            = var.location
  resource_group_name = azurerm_resource_group.r_grp.name
  public_key          = file("~/.ssh/id_rsa.pub")  # Updated to reference the correct path
}

# Node Security Group for SSH Access
resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "SSHAllowRule"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.r_grp.name
  network_security_group_name = azurerm_network_security_group.y_nsg.name
}
