 terraform {
  backend "local" {}
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.84"
    }
    azuread = {
      source = "hashicorp/azuread"
      version = "~>2.46"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {
} 