resource "azurerm_virtual_network" "vnet" {
  name                = "${var.application}-${var.env}-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "webapp_subnet" {
  name                 = "${var.application}-${var.env}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/29"]
  delegation {
    name = "webapp-delagation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_subnet" "sql_subnet" {
  name                 = "${var.application}-${var.env}-sql-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_subnet" "pep_subnet" {
  name                 = "${var.application}-${var.env}-pep"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_private_endpoint" "sql_pep" {
  name                = "${var.application}-${var.env}-sql-pep"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.pep_subnet.id

  private_service_connection {
    name                           = "${var.application}-${var.env}-sql-psc"
    private_connection_resource_id = azurerm_mysql_flexible_server.mysql.id
    is_manual_connection           = false
    subresource_names              = ["mysqlServer"]
  }
}

resource "azurerm_private_dns_zone" "sql_dns" {
  name                = "privatelink.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_virtual_link" {
  name                  = "${var.application}-${var.env}-sql-vnet-link"
  private_dns_zone_name = azurerm_private_dns_zone.sql_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  resource_group_name   = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_a_record" "sql_dns_record" {
  name                = "${var.application}-${var.env}-sql"
  zone_name           = azurerm_private_dns_zone.sql_dns.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.sql_pep.private_service_connection[0].private_ip_address]
}

resource "azurerm_app_service_virtual_network_swift_connection" "webapp_vnet_integration" {
  app_service_id = azurerm_linux_web_app.web_app.id
  subnet_id      = azurerm_subnet.webapp_subnet.id
}