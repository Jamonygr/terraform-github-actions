# =============================================================================
# TEST TERRAFORM CONFIGURATION
# =============================================================================
# Simple resource group for testing GitHub Actions
# =============================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {
    # Backend configuration provided via CLI arguments
    # -backend-config="resource_group_name=..."
    # -backend-config="storage_account_name=..."
    # -backend-config="container_name=tfstate"
    # -backend-config="key=test.tfstate"
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = var.subscription_id
}

# =============================================================================
# RESOURCE GROUP
# =============================================================================

resource "azurerm_resource_group" "test" {
  name     = "rg-${var.project}-${var.environment}-${var.location_short}"
  location = var.location

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    Repository  = "terraform-github-actions"
    CreatedAt   = timestamp()
  }

  lifecycle {
    ignore_changes = [tags["CreatedAt"]]
  }
}

# =============================================================================
# OUTPUTS
# =============================================================================

output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.test.name
}

output "resource_group_id" {
  description = "The ID of the resource group"
  value       = azurerm_resource_group.test.id
}

output "resource_group_location" {
  description = "The location of the resource group"
  value       = azurerm_resource_group.test.location
}
