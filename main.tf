# Resource group name is output when execution plan is applied.
resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.resource_group_location
}




