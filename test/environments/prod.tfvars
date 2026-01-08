# =============================================================================
# PROD ENVIRONMENT CONFIGURATION
# =============================================================================

# Replace with your subscription ID
subscription_id = "YOUR_SUBSCRIPTION_ID"

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
