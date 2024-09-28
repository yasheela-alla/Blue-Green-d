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
    name              = "Server_OsDisk"
    caching           = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb      = 30
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  disable_password_authentication = true

  admin_ssh_key {
    username   = "ubuntu"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCqStzY7XfVrPLYDcRgDfMRTBQa1q0jdqljjPz7P8zJnANLq75DUkBVTfXBvL+rppKZzZL7/yLFOghXg27hL7sguBliaEN+VIaQyP810stkg8EAKUEEjxMa7jiYXgTfI5H9xCXkdkiEuNteBkDwIpV9pItnDsaSi7M7mRMAXpNGoimg+iSpaxsxYEfN5VCdPpFwhrv5pTffNjXAbogpf28uIHcljgw9PhkB1Ti0QlR7rx4cOl7BEJ0c/ma7VuNidccd6yWQP1p6O6OH6ljZkvmTbp3sF1uXg4mhBMHRL3VoQaNLHYgMc/aoUn63bBHinDEAFYEr5EmukffAkilv8CPumOngmnB8Wuh47NoEXsw9Mw+IXBCIF9RXZtbktS9x4HC9gxmYp9XUH8I39gXGJdwsXfci4u9HOyc83H5Y9e7as02wDe4awfYwjlKS/l+xgxlQ56eVNbZGxw+L3dd1My81UhMlmbUc3gqgBLC1SHQHPpglHXOlpVomWRl0d06DOoU= generated-by-azure"
  }

  boot_diagnostics {
    enabled = true
  }

  security_profile {
    uefi_settings {
      secure_boot_enabled = true
      v_tpm_enabled       = true
    }
    security_type = "TrustedLaunch"
  }

  tags = {
    environment = "production"
  }
}
