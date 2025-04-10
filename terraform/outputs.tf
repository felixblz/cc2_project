output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "public_ip_address" {
  value = azurerm_public_ip.public_ip.ip_address
}

output "private_ip_address" {
  value = azurerm_network_interface.nic.ip_configuration[0].private_ip_address
}

output "vm_fqdn" {
  value = azurerm_public_ip.public_ip.fqdn
}

output "sql_server_name" {
  value = azurerm_mssql_server.mssql_server.name
}

output "admin_password" {
  sensitive = true
  value     = local.admin_password
}

output "admin_password_wo" {
  sensitive = true
  value     = local.admin_password_wo
}

output "openai_endpoint" {
  value = module.openai-cognitiveservices-account.endpoint
}

output "docu_intelli_endpoint" {
  value = module.docu-intelli-cognitiveservices-account.endpoint
}