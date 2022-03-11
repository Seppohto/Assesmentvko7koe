# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

resource "azurerm_resource_group" "koe" {
  name     = "${var.prefix}-checkpoint7-rg"
  location = var.location

  tags = {
    team = var.team
  }
}
resource "azurerm_virtual_network" "terraform-checkpoint7-vnet" {
  name                = "${var.prefix}-checkpoint7-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.koe.name
}

resource "azurerm_subnet" "koe" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.koe.name
  virtual_network_name = azurerm_virtual_network.terraform-checkpoint7-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}



resource "azurerm_network_security_group" "koe" {
    depends_on = [
      azurerm_resource_group.koe
    ]
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.koe.location
  resource_group_name = azurerm_resource_group.koe.name
  
  security_rule {
    name                       = "AllowSSH"
    description                = "Allow SSH"
    priority                   = 150
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowHTTP"
    description                = "Allow HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "koe" {
  name                = "${var.prefix}-pip"
  resource_group_name = azurerm_resource_group.koe.name
  location            = azurerm_resource_group.koe.location
  allocation_method   = "Dynamic"
}
resource "azurerm_network_interface" "koe" {
  name                = "${var.prefix}-nic1"
  resource_group_name = azurerm_resource_group.koe.name
  location            = azurerm_resource_group.koe.location

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.koe.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.koe.id
  }
}
resource "azurerm_network_interface_security_group_association" "koe" {
    depends_on = [
      azurerm_network_interface.koe
    ]
  network_interface_id      = azurerm_network_interface.koe.id
  network_security_group_id = azurerm_network_security_group.koe.id
}

resource "azurerm_linux_virtual_machine" "koe" {
depends_on = [
  azurerm_network_interface.koe
]

  name                            = "${var.prefix}-vm"
  resource_group_name             = azurerm_resource_group.koe.name
  location                        = azurerm_resource_group.koe.location
  size                            = "Standard_DS1_v2"
  admin_username                  = var.administrator_login
  admin_password                  = var.administrator_login_password
  disable_password_authentication = false
  network_interface_ids = [azurerm_network_interface.koe.id]
  custom_data    = base64encode(data.template_file.apache-vm-cloud-init.rendered)

  source_image_reference {
    publisher = "Canonical"

    offer     = "0001-com-ubuntu-server-focal"

    sku       = "20_04-lts-gen2"

    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}
data "template_file" "apache-vm-cloud-init" {
  template = file("install-apache.sh")
}
