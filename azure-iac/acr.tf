resource "azurerm_container_registry" "acr" {
  name                = "${var.application}${var.env}acr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = false
}