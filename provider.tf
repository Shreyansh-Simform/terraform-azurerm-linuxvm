# Terraform Block for Initialization and Provider Configuration
terraform {
    required_providers {
        azurerm = {
        source  = "hashicorp/azurerm"
        version = ">= 3.0"
        }
    }
    
    required_version = ">= 1.0.0"
}

#Provider block for Azurerm
provider "azurerm" {
    features {}
}