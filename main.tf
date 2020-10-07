# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create Azure Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.rg_location
}