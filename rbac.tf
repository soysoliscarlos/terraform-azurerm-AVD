
data "azuread_user" "aad_user" {
  for_each            = toset(var.avd_users)
  user_principal_name = format("%s", each.key)
}

resource "azuread_group" "aad_group" {
  display_name     = var.aad_group_name
  security_enabled = true
}

resource "azuread_group_member" "aad_group_member" {
  for_each         = data.azuread_user.aad_user
  group_object_id  = azuread_group.aad_group.id
  member_object_id = each.value["id"]
}

data "azurerm_role_definition" "role" { # access an existing built-in role
  name = "Desktop Virtualization User"
}
resource "azurerm_role_assignment" "role" {
  scope              = azurerm_virtual_desktop_application_group.dag.id
  role_definition_id = data.azurerm_role_definition.role.id
  principal_id       = azuread_group.aad_group.id
}

data "azurerm_role_definition" "vmul" { # access an existing built-in role
  name = "Virtual Machine User Login"
}
resource "azurerm_role_assignment" "vmul" {
  count              = var.rdsh_count
  scope              = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
  role_definition_id = data.azurerm_role_definition.vmul.id
  principal_id       = azuread_group.aad_group.id
}
