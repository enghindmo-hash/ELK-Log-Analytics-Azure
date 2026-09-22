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