resource "azurerm_resource_group" "elk_rg" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    project = "ELK-Log-Analytics"
    team    = "SentinelFive"
  }
}
resource "azurerm_virtual_network" "elk_vnet" {
  name                = "vnet-sentinelfive-elk"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.elk_rg.location
  resource_group_name = azurerm_resource_group.elk_rg.name

  tags = {
    project = "ELK-Log-Analytics"
    team    = "SentinelFive"
  }
}
resource "azurerm_subnet" "elk_subnet" {
  name                 = "subnet-elk"
  resource_group_name  = azurerm_resource_group.elk_rg.name
  virtual_network_name = azurerm_virtual_network.elk_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}
resource "azurerm_network_security_group" "elk_nsg" {
  name                = "nsg-sentinelfive-elk"
  location            = azurerm_resource_group.elk_rg.location
  resource_group_name = azurerm_resource_group.elk_rg.name

  tags = {
    project = "ELK-Log-Analytics"
    team    = "SentinelFive"
  }
}