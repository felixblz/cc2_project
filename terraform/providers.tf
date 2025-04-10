terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~>2.0"
    }
    modtm = {
      source  = "Azure/modtm"
      version = "~>0.3"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = ""
}