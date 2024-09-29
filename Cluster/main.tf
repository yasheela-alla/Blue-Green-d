# Resource Group
resource "azurerm_resource_group" "yasheela_rg" {
  name     = var.resource_group_name
  location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "yasheela_vnet" {
  name                = "yasheela-vnet"
  address_space       = [var.vnet_cidr]
  location            = var.location
  resource_group_name = azurerm_resource_group.r-grp.name
}

# Subnets
resource "azurerm_subnet" "yasheela_subnet" {
  count                 = 2
  name                  = "yasheela-subnet-${count.index}"
  resource_group_name   = azurerm_resource_group.yasheela_rg.name
  virtual_network_name  = azurerm_virtual_network.yasheela_vnet.name
  address_prefixes      = [element(var.subnet_prefix, count.index)]
}

# Network Security Group for AKS Cluster
resource "azurerm_network_security_group" "yasheela_nsg" {
  name                = "yasheela-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.r-grp.name

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
resource "azurerm_kubernetes_cluster" "yasheela_aks" {
  name                = "yasheela-aks"
  location            = var.location
  resource_group_name = azurerm_resource_group.r-grp.name
  dns_prefix          = "yasheelaaks"

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = "Standard_DS2_v2"
    vnet_subnet_id = azurerm_subnet.yasheela_subnet[0].id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "calico"
  }

  depends_on = [azurerm_subnet.yasheela_subnet]
}

# SSH Key for Node Access
resource "azurerm_ssh_public_key" "Server_ssh_key" {
  name                = "yasheela-ssh-key"
  location            = var.location
  resource_group_name = azurerm_resource_group.r-grp.name
  public_key          = file(var.ssh_key_name)
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
  source_address_prefix        = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.r-grp.name
  network_security_group_name = azurerm_network_security_group.yasheela_nsg.name
}
