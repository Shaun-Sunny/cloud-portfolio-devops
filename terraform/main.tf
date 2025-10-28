terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
  }
  required_version = ">=1.2.0"
}

provider "azurerm" {
  features {}
  subscription_id = "4dc08e1c-0e40-476c-8c86-a890893ab900"
  resource_provider_registrations = "none"
}



# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "shaunsunny-rg"
  location = "South India"
}

# Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                = "shaunsunnyacr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "shaunsunny-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "shaunsunny"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }
}
