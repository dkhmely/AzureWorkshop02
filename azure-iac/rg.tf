resource "azurerm_resource_group" "rg" {
  name     = "${var.application}-${var.env}-rg"
  location = var.location
}