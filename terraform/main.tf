resource "azurerm_resource_group" "elk_rg" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    project = "ELK-Log-Analytics"
    team    = "SentinelFour"
  }
}
resource "azurerm_virtual_network" "elk_vnet" {
  name                = "vnet-SentinelFour-elk"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.elk_rg.location
  resource_group_name = azurerm_resource_group.elk_rg.name

  tags = {
    project = "ELK-Log-Analytics"
    team    = "SentinelFour"
  }
}
resource "azurerm_subnet" "elk_subnet" {
  name                 = "subnet-elk"
  resource_group_name  = azurerm_resource_group.elk_rg.name
  virtual_network_name = azurerm_virtual_network.elk_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}
resource "azurerm_network_security_group" "elk_nsg" {
  name                = "nsg-SentinelFour-elk"
  location            = azurerm_resource_group.elk_rg.location
  resource_group_name = azurerm_resource_group.elk_rg.name

  tags = {
    project = "ELK-Log-Analytics"
    team    = "SentinelFour"
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
  resource_group_name         = azurerm_resource_group.elk_rg.name
  network_security_group_name = azurerm_network_security_group.elk_nsg.name
}
resource "azurerm_subnet_network_security_group_association" "elk_nsg_association" {
  subnet_id                 = azurerm_subnet.elk_subnet.id
  network_security_group_id = azurerm_network_security_group.elk_nsg.id
}
resource "azurerm_public_ip" "elk_public_ip" {
  name                = "pip-sentinelfour-elk"
  resource_group_name = azurerm_resource_group.elk_rg.name
  location            = azurerm_resource_group.elk_rg.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    project = "ELK-Log-Analytics"
    team    = "SentinelFour"
  }
}
resource "azurerm_network_interface" "elk_nic" {
  name                = "nic-sentinelfour-elk"
  location            = azurerm_resource_group.elk_rg.location
  resource_group_name = azurerm_resource_group.elk_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.elk_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.elk_public_ip.id
  }

  tags = {
    project = "ELK-Log-Analytics"
    team    = "SentinelFour"
  }
}
resource "azurerm_linux_virtual_machine" "elk_vm" {
  name                = var.vm_name
  resource_group_name = azurerm_resource_group.elk_rg.name
  location            = azurerm_resource_group.elk_rg.location
  size                = "Standard_DC2ds_v3"
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.elk_nic.id
  ]

  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("~/.ssh/elk_azure.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = {
    project = "ELK-Log-Analytics"
    team    = "SentinelFour"
  }
}