variable env {
  type        = string
  default     = "test"
  description = "environment variable"
}

variable application {
  type        = string
  default     = "test"
  description = "application name variable"
}

variable location {
    type = string
    default = "westeurope"
    description = "azure resource location"
}

variable sql_config {
  type = object ({
    sku_name = string
    auto_grow_enabled = bool
    iops = number
    size_gb = number
  })
  default = {
    sku_name = "B_Standard_B1ms"
    auto_grow_enabled = false
    iops = 360
    size_gb = 20
  }
  description = "MySql configuration variables"
}