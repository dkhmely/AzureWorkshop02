resource "random_password" "pass" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_="
}

resource "azurerm_mysql_flexible_server" "mysql" {
  name                   = "${var.application}-${var.env}-sql"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  administrator_login    = "${var.application}${var.env}admin"
  administrator_password = random_password.pass.result
  backup_retention_days  = 7
  sku_name               = var.sql_config.sku_name
  
  storage {
    auto_grow_enabled = var.sql_config.auto_grow_enabled
    iops = var.sql_config.iops
    size_gb = var.sql_config.size_gb
  }
}

resource "azurerm_mysql_flexible_database" "db" {
  name                = "${var.application}db"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}
