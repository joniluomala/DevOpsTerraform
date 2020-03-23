resource "azurerm_resource_group" "resourcegroup" {
  name     = "odm-devops-${var.environment}-rg"
  location = var.location
}

resource "azurerm_storage_account" "storage" {
  name                      = "odmado${var.environment}st"
  resource_group_name       = azurerm_resource_group.resourcegroup.name
  location                  = var.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true
}

resource "azurerm_app_service_plan" "func-asp" {
  name = "odm-devops-${var.environment}-func-asp"
  location = var.location
  resource_group_name = azurerm_resource_group.resourcegroup.name
  kind = "FunctionApp"
  reserved = true

  sku {
    tier = "Dynamic"
    size = "Y1"
  }

}

resource "azurerm_function_app" "func-app" {
  name =  "odm-devops-${var.environment}-func-app"
  location = var.location
  resource_group_name = azurerm_resource_group.resourcegroup.name
  app_service_plan_id = azurerm_app_service_plan.func-asp.id
  storage_connection_string = azurerm_storage_account.storage.primary_connection_string
  https_only = true
  version = "~3"

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "python"
    FUNCTIONS_EXTENSION_VERSION = "~3"
  }

  site_config {
    linux_fx_version = "python|3.7"
  }
  lifecycle {
    ignore_changes = [
      app_settings
    ]
  }
}