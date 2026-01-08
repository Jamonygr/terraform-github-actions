# =============================================================================
# PROD ENVIRONMENT CONFIGURATION
# =============================================================================

# Azure subscription
subscription_id = "97386c43-2906-40dc-9493-4e82e13b31bf"

# Project settings
project     = "tftest"
environment = "prod"

# Azure region
location       = "eastus2"
location_short = "eus2"

# Additional tags
tags = {
  CostCenter  = "Production"
  Owner       = "Platform"
  Criticality = "High"
}
