resource "azurerm_service_plan" "app_service_plan" {
  name                = "${var.application}-${var.env}-asp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type               = "Linux"
  sku_name            = "B1"

}

resource "azurerm_linux_web_app" "web_app" {
  name                = "${var.application}-${var.env}-webapp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id      = azurerm_service_plan.app_service_plan.id

  identity {
    type = "SystemAssigned"
  }

  site_config {}

  app_settings = {
    "DB_HOST" = "${azurerm_mysql_flexible_server.mysql.name}.mysql.database.azure.com"
    "DB_USER" = "${azurerm_mysql_flexible_server.mysql.administrator_login}"
    "DB_PASS" = random_password.pass.result
    "DB_NAME" = "${azurerm_mysql_flexible_database.db.name}"
    "DB_PORT" = 3306
  }

  depends_on = [azurerm_mysql_flexible_server.mysql]
}

resource "azurerm_role_assignment" "web_app_acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_linux_web_app.web_app.identity[0].principal_id
}