locals {
  registration_token = azurerm_virtual_desktop_host_pool_registration_info.registrationinfo.token
}

resource "azurerm_network_interface" "avd_vm_nic" {
  count               = var.rdsh_count
  name                = "${var.prefix}-${count.index + 1}-nic"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "nic${count.index + 1}_config"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [
    azurerm_resource_group.rg
  ]
}

resource "azurerm_windows_virtual_machine" "avd_vm" {
  count                 = var.rdsh_count
  name                  = "${var.prefix}-${count.index + 1}"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = var.vm_size
  network_interface_ids = ["${azurerm_network_interface.avd_vm_nic.*.id[count.index]}"]
  provision_vm_agent    = true
  admin_username        = var.local_admin_username
  admin_password        = var.local_admin_password

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    name                 = "${lower(var.prefix)}-${count.index + 1}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-11"
    sku       = "win11-22h2-avd"
    version   = "latest"
  }

  boot_diagnostics {
  }

  depends_on = [
    azurerm_resource_group.rg,
    azurerm_network_interface.avd_vm_nic
  ]
}

resource "azurerm_virtual_machine_extension" "dsc" {
  /*
  $publisher="Microsoft.Powershell"
  $extension="DSC"
  $location="eastus"

  $latest=$(az vm extension image list-versions --publisher $publisher -l $location -n $extension --query "[].name" -o tsv | sort |  Select-Object -Last 1)

  az vm extension image show -l $location --publisher $publisher -n $extension --version $latest
  */
  count                      = var.rdsh_count
  name                       = "${var.prefix}-AddToAVD-${count.index + 1}"
  virtual_machine_id         = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.73"
  auto_upgrade_minor_version = true

  settings = <<-SETTINGS
    {
      "modulesUrl":"https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_08-10-2022.zip",
      "configurationFunction":"Configuration.ps1\\AddSessionHost",
      "properties":{
        "hostPoolName":"${azurerm_virtual_desktop_host_pool.hostpool.name}",
        "aadJoin":false,
        "UseAgentDownloadEndpoint":true,
        "aadJoinPreview":true,
        "mdmId":"",
        "sessionHostConfigurationLastUpdateTime":"",
        "registrationInfoToken": "${local.registration_token}"
      }
    }
  SETTINGS
  /*protected_settings = <<PROTECTED_SETTINGS
  {
    "properties": {
      
    }
  }
  PROTECTED_SETTINGS*/

  depends_on = [
    azurerm_virtual_desktop_host_pool.hostpool,
    azurerm_windows_virtual_machine.avd_vm,
    azurerm_virtual_machine_extension.AADLoginForWindows
  ]
}


resource "azurerm_virtual_machine_extension" "AADLoginForWindows" {
  /*
  $publisher="Microsoft.Azure.ActiveDirectory"
  $extension="AADLoginForWindows"
  $location="eastus"

  $latest=$(az vm extension image list-versions --publisher $publisher -l $location -n $extension --query "[].name" -o tsv | sort |  Select-Object -Last 1)

  az vm extension image show -l $location --publisher $publisher -n $extension --version $latest
  */

  count                      = var.rdsh_count
  name                       = "${var.prefix}-AADLoginForWindows-${count.index + 1}"
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  virtual_machine_id         = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
  depends_on = [
    azurerm_windows_virtual_machine.avd_vm,
  ]
}

