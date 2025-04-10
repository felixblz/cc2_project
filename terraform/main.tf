resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = var.resource_group_name
}

resource "azurerm_virtual_network" "vnet" {
  name                = "cc2vnet"
  address_space = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "cc2subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "public_ip" {
  name                = "cc2publicip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
  domain_name_label   = "cc2-${var.resource_group_name}"
}

resource "azurerm_network_interface" "nic" {
  name                = "cc2nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_virtual_machine" "vm" {
  name                          = "cc2vm1"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size                       = "Standard_B2als_v2"
  delete_os_disk_on_termination = true

  storage_os_disk {
    name              = "cc2osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Debian"
    offer     = "debian-12"
    sku       = "12"
    version   = "latest"
  }

  os_profile {
    computer_name  = "cc2vm1"
    admin_username = "adminuser"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path = "/home/adminuser/.ssh/authorized_keys"
      key_data = file("~/.ssh/id_rsa.pub")
    }
  }
}

resource "random_password" "admin_password" {
  count       = var.admin_password == null ? 1 : 0
  length      = 20
  special     = true
  min_numeric = 1
  min_upper   = 1
  min_lower   = 1
  min_special = 1
}

locals {
  admin_password = try(random_password.admin_password[0].result, var.admin_password)
  admin_password_wo = try(random_password.admin_password[0].result, var.admin_password)
}

resource "azurerm_mssql_server" "mssql_server" {
  location                                = var.resource_group_location
  name                                    = "cc2-mssql-server"
  resource_group_name                     = var.resource_group_name
  version                                 = "12.0"
  administrator_login                     = var.admin_username
  administrator_login_password            = local.admin_password
}

resource "azurerm_mssql_database" "mssql_db" {
  name      = var.sql_db_name
  server_id = azurerm_mssql_server.mssql_server.id
}


module "docu-intelli-cognitiveservices-account" {
  source              = "Azure/avm-res-cognitiveservices-account/azurerm"
  version             = "0.7.0"
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.rg.name
  name                = "cc2-di"
  sku_name            = "S0"
  kind                = "FormRecognizer"
}

module "openai-cognitiveservices-account" {
  source              = "Azure/avm-res-cognitiveservices-account/azurerm"
  version             = "0.7.0"
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.rg.name
  name                = "cc2-openai"
  sku_name            = "S0"
  kind                = "OpenAI"
  cognitive_deployments = {
    "gpt-35-turbo" = {
      name = "gpt-35-turbo"
      model = {
        format = "OpenAI"
        name   = "gpt-35-turbo"
      }
      scale = {
        type = "Standard"
      }
    }
  }
}