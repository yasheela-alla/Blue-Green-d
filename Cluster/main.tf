provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "r_grp" {
  name     = "r-grp"
  location = "Japan East"
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.r_grp.location
  resource_group_name = azurerm_resource_group.r_grp.name
}

# Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "subnet"
  resource_group_name  = azurerm_resource_group.r_grp.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Interface
resource "azurerm_network_interface" "nic" {
  name                = "server711_z1"
  location            = azurerm_resource_group.r_grp.location
  resource_group_name = azurerm_resource_group.r_grp.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Public IP
resource "azurerm_public_ip" "public_ip" {
  name                = "server_public_ip"
  location            = azurerm_resource_group.r_grp.location
  resource_group_name = azurerm_resource_group.r_grp.name
  allocation_method   = "Dynamic"
}

# Network Security Group
resource "azurerm_network_security_group" "nsg" {
  name                = "server-nsg"
  location            = azurerm_resource_group.r_grp.location
  resource_group_name = azurerm_resource_group.r_grp.name
}

# NSG Rule to Allow SSH
resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "allow_ssh"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.r_grp.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "Server"
  resource_group_name = azurerm_resource_group.r_grp.name
  location            = azurerm_resource_group.r_grp.location
  size                = "Standard_D4s_v3"
  admin_username      = "ubuntu"

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  os_disk {
    name                = "Server_OsDisk"
    caching             = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb        = 30
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "ubuntu-22.04-lts"  # Corrected version to 22.04 LTS
    sku       = "server"
    version   = "latest"
  }

  disable_password_authentication = true

  admin_ssh_key {
    username   = "ubuntu"
    public_key = "ssh-rsa AAAAB3... generated-by-azure"
  }

  # Optional: Uncomment if you have a storage account
  /*
  boot_diagnostics {
    enabled     = true
    storage_uri = azurerm_storage_account.your_storage_account.primary_blob_endpoint
  }
  */

  tags = {
    environment = "production"
  }
}

# Outputs
output "vm_id" {
  value = azurerm_linux_virtual_machine.vm.id
}

output "public_ip" {
  value = azurerm_public_ip.public_ip.id
}

output "network_interface_ids" {
  value = azurerm_network_interface.nic.id
}

output "resource_group" {
  value = azurerm_resource_group.r_grp.name
}
