# 🚀 GitHub Actions Pipeline Setup Guide

This guide helps you set up the CI/CD pipeline for your own Azure subscription.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Authentication Methods](#authentication-methods)
  - [Option A: OIDC (Recommended)](#option-a-oidc-authentication-recommended)
  - [Option B: Service Principal (Legacy)](#option-b-service-principal-legacy)
- [State Storage Setup](#step-2-create-azure-state-storage)
- [GitHub Configuration](#step-4-add-github-secrets-and-variables)
- [Environment Setup](#step-5-create-github-environments)
- [Testing](#step-6-test-the-pipeline)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

- Azure subscription with Owner or Contributor access
- GitHub account
- Azure CLI installed locally (`az --version` ≥ 2.40)
- GitHub CLI installed locally (optional, for easier setup)

---

## Authentication Methods

### Option A: OIDC Authentication (Recommended) 🔐

OIDC (OpenID Connect) is the recommended authentication method because:
- ✅ No long-lived secrets to rotate
- ✅ More secure - tokens are short-lived
- ✅ Native Azure AD integration
- ✅ Better audit trail

#### Step 1: Create Azure AD Application

```bash
# Login to Azure
az login

# Set your subscription
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
TENANT_ID=$(az account show --query tenantId -o tsv)

# Create an Azure AD application
APP_NAME="github-actions-terraform"
APP=$(az ad app create --display-name "$APP_NAME" --query appId -o tsv)
echo "Application (Client) ID: $APP"

# Create a service principal for the app
az ad sp create --id $APP
```

#### Step 2: Configure Federated Credentials

```bash
# Get your GitHub repo info
GITHUB_ORG="YOUR_GITHUB_USERNAME"  # or organization
GITHUB_REPO="terraform-github-actions"

# Create federated credential for the main branch
az ad app federated-credential create \
  --id $APP \
  --parameters '{
    "name": "github-main",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:'$GITHUB_ORG'/'$GITHUB_REPO':ref:refs/heads/main",
    "audiences": ["api://AzureADTokenExchange"]
  }'

# Create federated credential for pull requests
az ad app federated-credential create \
  --id $APP \
  --parameters '{
    "name": "github-pr",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:'$GITHUB_ORG'/'$GITHUB_REPO':pull_request",
    "audiences": ["api://AzureADTokenExchange"]
  }'

# Create federated credential for environments (optional)
for ENV in dev staging prod; do
  az ad app federated-credential create \
    --id $APP \
    --parameters '{
      "name": "github-env-'$ENV'",
      "issuer": "https://token.actions.githubusercontent.com",
      "subject": "repo:'$GITHUB_ORG'/'$GITHUB_REPO':environment:'$ENV'",
      "audiences": ["api://AzureADTokenExchange"]
    }'
done
```

#### Step 3: Grant Azure Permissions

```bash
# Get service principal object ID
SP_OBJECT_ID=$(az ad sp show --id $APP --query id -o tsv)

# Assign Contributor role at subscription level
az role assignment create \
  --assignee-object-id $SP_OBJECT_ID \
  --assignee-principal-type ServicePrincipal \
  --role "Contributor" \
  --scope "/subscriptions/$SUBSCRIPTION_ID"

# (Optional) Assign Storage Blob Data Contributor for state management
az role assignment create \
  --assignee-object-id $SP_OBJECT_ID \
  --assignee-principal-type ServicePrincipal \
  --role "Storage Blob Data Contributor" \
  --scope "/subscriptions/$SUBSCRIPTION_ID"

# Display values for GitHub configuration
echo ""
echo "=== ADD THESE TO GITHUB VARIABLES ==="
echo "AZURE_CLIENT_ID: $APP"
echo "AZURE_TENANT_ID: $TENANT_ID"
echo "AZURE_SUBSCRIPTION_ID: $SUBSCRIPTION_ID"
echo "USE_OIDC: true"
```

#### Step 4: Add to GitHub Variables

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click the **Variables** tab
4. Add these **Repository Variables**:

| Variable Name | Value |
|--------------|-------|
| `AZURE_CLIENT_ID` | Application (client) ID from above |
| `AZURE_TENANT_ID` | Your Azure AD tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Your Azure subscription ID |
| `USE_OIDC` | `true` |

---

### Option B: Service Principal (Legacy)

Use this method if OIDC is not supported in your environment.

#### Step 1: Create Service Principal

```bash
# Login to Azure
az login

# Get subscription ID
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

# Create service principal with Contributor role
az ad sp create-for-rbac \
  --name "sp-github-actions-terraform" \
  --role "Contributor" \
  --scopes "/subscriptions/$SUBSCRIPTION_ID" \
  --sdk-auth

# Copy the entire JSON output for AZURE_CREDENTIALS secret
```

#### Step 2: Add to GitHub Secrets

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add:

| Secret Name | Value |
|-------------|-------|
| `AZURE_CREDENTIALS` | Full JSON from `az ad sp create-for-rbac --sdk-auth` |

---

## Step 2: Create Azure State Storage

Terraform needs a storage account for remote state.

### PowerShell

```powershell
# Login to Azure
az login

# Set variables
$RESOURCE_GROUP = "rg-terraform-state"
$LOCATION = "eastus2"  # Change to your preferred region
$STORAGE_ACCOUNT = "stterraformstate$(Get-Random -Maximum 9999)"

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create storage account
az storage account create `
  --name $STORAGE_ACCOUNT `
  --resource-group $RESOURCE_GROUP `
  --sku Standard_LRS `
  --encryption-services blob `
  --min-tls-version TLS1_2 `
  --allow-blob-public-access false

# Create state container
az storage container create `
  --name tfstate `
  --account-name $STORAGE_ACCOUNT

# Create backup container
az storage container create `
  --name tfstate-backups `
  --account-name $STORAGE_ACCOUNT

# Display values to save
Write-Host "`n=== ADD THESE TO GITHUB SECRETS ===" -ForegroundColor Green
Write-Host "TF_STATE_RG: $RESOURCE_GROUP"
Write-Host "TF_STATE_SA: $STORAGE_ACCOUNT"
```

### Bash

```bash
# Login to Azure
az login

# Set variables
RESOURCE_GROUP="rg-terraform-state"
LOCATION="eastus2"
STORAGE_ACCOUNT="stterraformstate$RANDOM"

# Create resources
az group create --name $RESOURCE_GROUP --location $LOCATION

az storage account create \
  --name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --sku Standard_LRS \
  --encryption-services blob \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false

az storage container create \
  --name tfstate \
  --account-name $STORAGE_ACCOUNT

az storage container create \
  --name tfstate-backups \
  --account-name $STORAGE_ACCOUNT

echo ""
echo "=== ADD THESE TO GITHUB SECRETS ==="
echo "TF_STATE_RG: $RESOURCE_GROUP"
echo "TF_STATE_SA: $STORAGE_ACCOUNT"
```

---

## Step 3: Grant Storage Permissions (for OIDC)

If using OIDC, the service principal needs explicit permissions to the storage account:

```bash
# Get the storage account ID
STORAGE_ID=$(az storage account show \
  --name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --query id -o tsv)

# Grant Storage Blob Data Contributor role
az role assignment create \
  --assignee-object-id $SP_OBJECT_ID \
  --assignee-principal-type ServicePrincipal \
  --role "Storage Blob Data Contributor" \
  --scope $STORAGE_ID
```

---

## Step 4: Add GitHub Secrets and Variables

### Required Secrets

| Secret Name | Description | Required For |
|-------------|-------------|--------------|
| `AZURE_CREDENTIALS` | Full JSON from service principal (legacy auth) | Legacy auth only |
| `TF_STATE_RG` | Resource group for state storage | All |
| `TF_STATE_SA` | Storage account name for state | All |
| `INFRACOST_API_KEY` | Infracost API key ([get free key](https://www.infracost.io/)) | Cost estimation |

### Required Variables (for OIDC)

| Variable Name | Description |
|--------------|-------------|
| `AZURE_CLIENT_ID` | Application (client) ID |
| `AZURE_TENANT_ID` | Azure AD tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Azure subscription ID |
| `USE_OIDC` | Set to `true` to enable OIDC |

### Optional Variables

| Variable Name | Description |
|--------------|-------------|
| `SLACK_WEBHOOK_URL` | Slack webhook for notifications |
| `TEAMS_WEBHOOK_URL` | Microsoft Teams webhook |

---

## Step 5: Create GitHub Environments

Environments add approval gates and protection rules.

1. Go to **Settings** → **Environments**
2. Create these environments:

| Environment | Protection Rules | Secrets |
|-------------|------------------|---------|
| `dev` | None (auto-deploy) | Environment-specific overrides |
| `staging` | Optional: Require reviewer | |
| `prod` | Required: 1+ reviewer, wait 5 min | |
| `dev-destroy` | Required: 1 reviewer | |
| `prod-destroy` | Required: 2 reviewers | |

### Environment-Specific Secrets

Each environment can have its own secrets that override repository secrets:

- Different `AZURE_SUBSCRIPTION_ID` for prod vs dev
- Different Azure credentials per environment
- Environment-specific variable files

---

## Step 6: Test the Pipeline

### Option A: Push to Trigger Validation

```bash
# Clone your repo
git clone https://github.com/YOUR_USERNAME/terraform-github-actions.git
cd terraform-github-actions

# Make a small change
echo "# Test" >> README.md

# Push to trigger pipeline
git add .
git commit -m "test: trigger pipeline"
git push
```

### Option B: Manual Trigger

1. Go to **Actions** tab
2. Select **Terraform Pipeline**
3. Click **Run workflow**
4. Select environment and action

### Option C: Test with the Test Terraform

The `test/` folder contains a minimal Terraform configuration (just a resource group):

1. Update `test/environments/dev.tfvars` with your subscription ID
2. Run the pipeline with `working_directory: ./test`

---

## Workflow Overview

| Workflow | Trigger | Description |
|----------|---------|-------------|
| **Terraform Pipeline** | Push/PR/Manual | Main CI/CD workflow |
| **Drift Detection** | Daily 6 AM UTC / Manual | Detect infrastructure drift |

### Pipeline Stages

1. ✅ Format Check
2. ✅ Validate
3. 🔒 Security Scans (tfsec, Checkov, TFLint)
4. 🔍 Secret Scanning
5. 💰 Cost Estimation
6. 📋 Plan
7. ⏸️ Approval (prod only)
8. ✅ Apply / 💥 Destroy

---

## Migrating from Legacy to OIDC

If you're currently using service principal secrets and want to migrate to OIDC:

1. **Create federated credentials** (Step 1-2 of OIDC setup above)
2. **Add GitHub variables** for OIDC (don't remove secrets yet)
3. **Set `USE_OIDC: true`** variable
4. **Test the pipeline** - it will now use OIDC
5. **Remove old secrets** once verified working

The actions support both authentication methods simultaneously for easy migration.

---

## Troubleshooting

### "AADSTS700016: Application not found"

```bash
# Verify the application exists
az ad app show --id $AZURE_CLIENT_ID

# Check federated credentials
az ad app federated-credential list --id $AZURE_CLIENT_ID
```

### "OIDC token exchange failed"

- Verify the `subject` in federated credentials matches your workflow
- For PRs: `repo:owner/repo:pull_request`
- For branches: `repo:owner/repo:ref:refs/heads/main`
- For environments: `repo:owner/repo:environment:prod`

### "Error: Backend initialization failed"

```bash
# Verify storage account exists
az storage account show --name $TF_STATE_SA

# Check container exists
az storage container exists --name tfstate --account-name $TF_STATE_SA

# For OIDC, verify RBAC permissions
az role assignment list --assignee $AZURE_CLIENT_ID --scope /subscriptions/$SUBSCRIPTION_ID
```

### "Error: Authorization failed"

```bash
# Check role assignments
az role assignment list --assignee $AZURE_CLIENT_ID --all

# Verify Contributor role at subscription level
az role assignment create \
  --assignee $AZURE_CLIENT_ID \
  --role "Contributor" \
  --scope "/subscriptions/$SUBSCRIPTION_ID"
```

### "Resource provider not registered"

```bash
az provider register --namespace Microsoft.Network
az provider register --namespace Microsoft.Compute
az provider register --namespace Microsoft.Storage
az provider register --namespace Microsoft.ManagedIdentity
```

### State Lock Issues

```bash
# Force unlock (use carefully!)
terraform force-unlock <LOCK_ID>

# Check who holds the lock
az storage blob show \
  --account-name $TF_STATE_SA \
  --container-name tfstate \
  --name your-state.tfstate \
  --query metadata
```

---

## Security Best Practices

| Practice | Description |
|----------|-------------|
| ✅ Use OIDC | Eliminates long-lived secrets |
| ✅ Environment protection | Require approvals for production |
| ✅ Least privilege | Grant minimal required permissions |
| ✅ Rotate secrets | If using legacy auth, rotate every 90 days |
| ✅ Review security scans | Address tfsec/Checkov findings |
| ✅ Enable branch protection | Require PR reviews |
| ✅ Use state encryption | Azure Storage encrypts at rest |
| ✅ Enable state locking | Prevent concurrent modifications |

---

## Cost Management

### Minimal Cost Configuration

```hcl
# test/environments/dev.tfvars
subscription_id = "your-sub-id"
project         = "tftest"
environment     = "dev"
```

Resource groups are **free** - the test configuration has zero Azure cost.

### Cost Estimation

Get a free Infracost API key at [infracost.io](https://www.infracost.io/):

1. Sign up for free account
2. Get your API key
3. Add `INFRACOST_API_KEY` to GitHub secrets

---

## Next Steps

1. ✅ Complete setup above
2. 📋 Run your first plan
3. 🚀 Deploy to dev environment  
4. 🔒 Enable environment protection for prod
5. 📊 Set up Slack/Teams notifications

---

*Last Updated: January 2026*
