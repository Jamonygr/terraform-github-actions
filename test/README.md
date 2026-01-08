# Test Terraform Configuration

This folder contains a minimal Terraform configuration for testing the GitHub Actions.

## Resources Created

- 1 Resource Group (`rg-tftest-{environment}-{location}`)

## Usage

### Local Testing

```bash
cd test

# Initialize
terraform init \
  -backend-config="resource_group_name=rg-terraform-state" \
  -backend-config="storage_account_name=YOUR_STORAGE_ACCOUNT" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=test-dev.tfstate"

# Plan
terraform plan -var-file="environments/dev.tfvars"

# Apply
terraform apply -var-file="environments/dev.tfvars"

# Destroy
terraform destroy -var-file="environments/dev.tfvars"
```

### CI/CD Testing

The GitHub Actions workflow uses this configuration to validate the actions work correctly.

## Estimated Cost

**$0** - Resource groups are free in Azure.
