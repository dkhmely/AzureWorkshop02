resource "azurerm_key_vault" "kv" {
  name                        = "${var.application}${var.env}kv"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name = "standard"
  enable_rbac_authorization = true

}

resource "azurerm_key_vault_secret" "sql_admin_secret" {
  name         = "${var.application}-${var.env}-admin-pw"
  value        = random_password.pass.result
  key_vault_id = azurerm_key_vault.kv.id
}