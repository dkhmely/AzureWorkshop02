terraform {
  required_providers {
    azurerm = {
        version = "=4.41.0"
        source = "hashicorp/azurerm"
    }
  }
  
}

provider "azurerm" {
    features {}
    subscription_id = "70612abe-819d-4e7f-8b16-ef74e921f18b"
}