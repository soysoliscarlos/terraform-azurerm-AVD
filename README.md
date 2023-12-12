# terraform-azurerm-AVD

```terraform
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

module "avd" {
  source  = "github.com/soysoliscarlos/terraform-azurerm-AVD.git"
  # Define the users
  avd_users = [
    "UPN-User1",
    "UPN-UserN",
  ]
  
  # Registration token expiration Ex. 2023-01-31T12:00:00Z (No more than a month)
  rfc3339 = "2023-12-31T12:00:00Z"
}
```
