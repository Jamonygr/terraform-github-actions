# 🚀 Terraform GitHub Actions

[![Terraform](https://img.shields.io/badge/Terraform-1.9+-623CE4?logo=terraform)](https://www.terraform.io/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-Reusable-2088FF?logo=github-actions)](https://github.com/features/actions)

Reusable GitHub Actions for Terraform workflows. Includes plan, apply, validate, security scanning, cost estimation, and more. Automate your infrastructure deployments with production-ready CI/CD pipelines.

---

## 📋 Table of Contents

- [Features](#-features)
- [Quick Start](#-quick-start)
- [Actions Reference](#-actions-reference)
- [Workflow Example](#-workflow-example)
- [Pipeline Stages](#-pipeline-stages)
- [Configuration](#️-configuration)
- [Cost Estimation](#-cost-estimation)
- [Security Scanning](#-security-scanning)
- [Troubleshooting](#-troubleshooting)
- [Project Structure](#-project-structure)
- [License](#-license)
- [Acknowledgments](#-acknowledgments)

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| **� OIDC Authentication** | Secure Azure authentication without long-lived secrets |
| **🔄 Plan & Apply** | Safe infrastructure changes with plan review and approval gates |
| **🔒 Security Scanning** | Integrated tfsec, Checkov, and TFLint for compliance |
| **💰 Cost Estimation** | Infracost integration for cost visibility |
| **📊 Metrics & Reporting** | Resource inventory, change logs, and dependency graphs |
| **🧪 Testing** | Terratest integration for infrastructure testing |
| **🔍 Drift Detection** | Scheduled detection of infrastructure drift |
| **🔐 Secret Scanning** | Detect hardcoded secrets before deployment |
| **📝 Documentation** | Auto-generate terraform-docs |
| **💾 State Backup & Restore** | Automated state file backups with restore capability |
| **💬 PR Comments** | Automatic plan/cost/security summaries on pull requests |
| **📢 Notifications** | Slack, Teams, Discord integration |
| **🏷️ Module Versioning** | Semantic versioning for modules |
| **🚨 Policy Checks** | OPA/Sentinel policy validation |
| **⚡ Plugin Caching** | Faster builds with Terraform plugin caching |

---

## 🚀 Quick Start

### 1. Copy the Actions to Your Repository

```bash
# Clone this repository
git clone https://github.com/Jamonygr/terraform-github-actions.git

# Copy the .github folder to your Terraform project
cp -r terraform-github-actions/.github your-terraform-project/
```

### 2. Set Up Authentication

#### Option A: OIDC (Recommended) 🔐

Add these **Variables** to your GitHub repository:

| Variable | Description | Required |
|----------|-------------|----------|
| `AZURE_CLIENT_ID` | Azure AD Application (Client) ID | ✅ Yes |
| `AZURE_TENANT_ID` | Azure AD Tenant ID | ✅ Yes |
| `AZURE_SUBSCRIPTION_ID` | Azure Subscription ID | ✅ Yes |
| `USE_OIDC` | Set to `true` | ✅ Yes |

Add these **Secrets**:

| Secret | Description | Required |
|--------|-------------|----------|
| `TF_STATE_RG` | Terraform state resource group | ✅ Yes |
| `TF_STATE_SA` | Terraform state storage account | ✅ Yes |
| `INFRACOST_API_KEY` | Infracost API key | ❌ Optional |

See [SETUP.md](.github/SETUP.md) for detailed OIDC configuration instructions.

#### Option B: Service Principal (Legacy)

Add these **Secrets** to your GitHub repository:

| Secret | Description | Required |
|--------|-------------|----------|
| `AZURE_CREDENTIALS` | Azure service principal JSON | ✅ Yes |
| `TF_STATE_RG` | Terraform state resource group | ✅ Yes |
| `TF_STATE_SA` | Terraform state storage account | ✅ Yes |
| `INFRACOST_API_KEY` | Infracost API key | ❌ Optional |

### 3. Trigger the Workflow

```bash
# Push changes to trigger the pipeline
git add .
git commit -m "Add Terraform GitHub Actions"
git push
```

---

## 📦 Actions Reference

### Core Actions

| Action | Description | Key Inputs |
|--------|-------------|------------|
| [**setup**](.github/actions/setup/) | Shared Terraform setup with caching | `terraform_version`, `use_oidc` |
| [**validate**](.github/actions/validate/) | Terraform format and validate | `working_directory` |
| [**plan**](.github/actions/plan/) | Initialize and create execution plan | `use_oidc`, `var_file`, `state_key` |
| [**apply**](.github/actions/apply/) | Apply Terraform changes | `use_oidc`, `plan_artifact` |
| [**destroy**](.github/actions/destroy/) | Destroy infrastructure | `use_oidc`, `confirm: DESTROY` |

### Security Actions

| Action | Description | Tools Used |
|--------|-------------|------------|
| [**security**](.github/actions/security/) | Security scanning | tfsec, Checkov, TFLint |
| [**secret-scan**](.github/actions/secret-scan/) | Detect hardcoded secrets | Gitleaks with SARIF upload |
| [**policy-check**](.github/actions/policy-check/) | Policy validation | OPA, Conftest |

### State Management Actions

| Action | Description | Key Features |
|--------|-------------|--------------|
| [**state-backup**](.github/actions/state-backup/) | Backup state files | Auto-cleanup, retention policy |
| [**state-restore**](.github/actions/state-restore/) | Restore from backup | List backups, confirm required |
| [**drift-detect**](.github/actions/drift-detect/) | Detect infrastructure drift | Auto-create issues |

### Communication Actions

| Action | Description | Supported |
|--------|-------------|-----------|
| [**pr-comment**](.github/actions/pr-comment/) | Post summaries to PRs | Plan, cost, security |
| [**notification**](.github/actions/notification/) | Send notifications | Slack, Teams, Discord |

### Utility Actions

| Action | Description | Output |
|--------|-------------|--------|
| [**cost-estimate**](.github/actions/cost-estimate/) | Infrastructure cost estimation | Monthly cost, cost diff |
| [**terraform-docs**](.github/actions/terraform-docs/) | Generate documentation | README updates |
| [**graph**](.github/actions/graph/) | Dependency visualization | SVG/PNG graph |
| [**resource-inventory**](.github/actions/resource-inventory/) | List managed resources | Resource report |
| [**changelog**](.github/actions/changelog/) | Generate change log | CHANGELOG.md |
| [**metrics**](.github/actions/metrics/) | Pipeline metrics | Duration, resource counts |
| [**module-version**](.github/actions/module-version/) | Module versioning | Versions JSON, update check |
| [**terratest**](.github/actions/terratest/) | Infrastructure testing | Test results |

---

## 📝 Workflow Example

### Basic Workflow

```yaml
name: 'Terraform'

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  workflow_dispatch:
    inputs:
      action:
        type: choice
        options: [plan, apply, destroy]
        default: 'plan'

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Validate
        uses: ./.github/actions/validate

      - name: Security Scan
        uses: ./.github/actions/security

      - name: Plan
        uses: ./.github/actions/plan
        with:
          azure_credentials: ${{ secrets.AZURE_CREDENTIALS }}
          backend_resource_group: ${{ secrets.TF_STATE_RG }}
          backend_storage_account: ${{ secrets.TF_STATE_SA }}
          state_key: 'myproject.tfstate'
          var_file: 'environments/lab.tfvars'
          environment: 'lab'

      - name: Cost Estimate
        uses: ./.github/actions/cost-estimate
        with:
          api_key: ${{ secrets.INFRACOST_API_KEY }}
          var_file: 'environments/lab.tfvars'
```

---

## 🔄 Pipeline Stages

The included workflow (`terraform.yml`) implements a comprehensive 10-stage pipeline:

```
┌─────────────────────────────────────────────────────────────────────┐
│                        TERRAFORM PIPELINE                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  1️⃣ FORMAT CHECK ──► 2️⃣ VALIDATE ──► 3️⃣ SECURITY (tfsec)           │
│         │                  │                │                       │
│         ▼                  ▼                ▼                       │
│  4️⃣ SECURITY ──────► 5️⃣ SECRET ────► 6️⃣ COST ESTIMATE              │
│    (Checkov)           SCAN               │                         │
│         │                                 ▼                         │
│         └────────────────────────► 7️⃣ PLAN ◄───────────────────    │
│                                       │                             │
│                                       ▼                             │
│                              8️⃣ APPROVAL GATE                       │
│                                       │                             │
│                          ┌────────────┴────────────┐                │
│                          ▼                         ▼                │
│                     9️⃣ APPLY                 10️⃣ DESTROY            │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Stage Details

| Stage | Job Name | Purpose | Blocking |
|-------|----------|---------|----------|
| 1 | `format` | Check Terraform formatting | ✅ Yes |
| 2 | `validate` | Validate configuration syntax | ✅ Yes |
| 3 | `security-tfsec` | tfsec security scan | ❌ No |
| 4 | `security-checkov` | Checkov compliance scan | ❌ No |
| 5 | `secret-scan` | Detect hardcoded secrets | ❌ No |
| 6 | `cost-estimate` | Infracost estimation | ❌ No |
| 7 | `plan` | Generate execution plan | ✅ Yes |
| 8 | `approval` | Manual approval gate | ✅ Yes (prod) |
| 9 | `apply` | Apply infrastructure changes | - |
| 10 | `destroy` | Destroy infrastructure | - |

---

## ⚙️ Configuration

### Workflow Inputs

| Input | Description | Default | Options |
|-------|-------------|---------|---------|
| `environment` | Target environment | `lab` | `dev`, `lab`, `prod` |
| `action` | Pipeline action | `plan` | `plan`, `apply`, `destroy` |
| `destroy_confirm` | Destruction confirmation | - | Type `DESTROY` |
| `working_directory` | Terraform working directory | `.` | Any relative path |

### Environment Variables

```yaml
env:
  TF_VERSION: '1.9.0'          # Terraform version
  ENVIRONMENT: 'lab'            # Default environment
```

### Concurrency Control

```yaml
concurrency:
  group: terraform-${{ github.ref }}-${{ github.event.inputs.environment }}
  cancel-in-progress: false     # Never cancel in-progress runs
```

---

## 💰 Cost Estimation

The pipeline integrates with [Infracost](https://www.infracost.io/) for cost visibility.

### Setup

1. Get a free API key from [Infracost](https://www.infracost.io/pricing/)
2. Add `INFRACOST_API_KEY` to your repository secrets

### Sample Output

```
💰 Cost Estimation

Project: azure-landing-zone
Currency: USD

Monthly Cost: $547.42
├── Azure Firewall:     $350.40
├── VPN Gateway:        $138.70
├── Virtual Machines:    $45.00
├── Load Balancer:       $18.32
└── Storage:              $5.00

Cost Change: +$25.00 (+4.8%)
```

---

## 🔒 Security Scanning

### Tools Integrated

| Tool | Purpose | Checks |
|------|---------|--------|
| **tfsec** | Static analysis | 100+ security rules |
| **Checkov** | Compliance scanning | CIS, SOC2, HIPAA, PCI-DSS |
| **TFLint** | Linting | Best practices, errors |
| **gitleaks** | Secret detection | API keys, passwords |

### Security Best Practices

| Practice | Implementation |
|----------|----------------|
| **No hardcoded secrets** | Use `sensitive = true` and Key Vault |
| **Encryption at rest** | Enable storage encryption |
| **Network security** | NSGs, private endpoints |
| **Least privilege** | Minimal IAM permissions |
| **State protection** | Encrypted backend storage |

---

## 🔧 Troubleshooting

### Common Issues & Solutions

#### Pipeline Fails at Format Check

```bash
# Fix formatting locally
terraform fmt -recursive

# Commit the changes
git add .
git commit -m "Fix: terraform formatting"
git push
```

#### Authentication Failed

```bash
# Verify Azure credentials
az login --service-principal \
  --username $ARM_CLIENT_ID \
  --password $ARM_CLIENT_SECRET \
  --tenant $ARM_TENANT_ID

# Check the credentials JSON format
{
  "clientId": "xxx",
  "clientSecret": "xxx",
  "subscriptionId": "xxx",
  "tenantId": "xxx"
}
```

#### State Lock Error

```bash
# Force unlock (use carefully!)
terraform force-unlock <LOCK_ID>
```

#### Security Scan Fails

Security scans use `soft_fail: true` by default. To block on failures:

```yaml
- name: Security Scan
  uses: ./.github/actions/security
  with:
    soft_fail: false  # Block on security issues
```

### Terraform Timing Reference

| Operation | Typical Duration |
|-----------|------------------|
| Format Check | ~10 seconds |
| Validate | ~30 seconds |
| Security Scans | ~1-2 minutes |
| Plan (small) | ~1-3 minutes |
| Plan (large) | ~5-10 minutes |
| Apply | Varies by resources |

---

## 📁 Project Structure

```
terraform-github-actions/
├── .github/
│   ├── workflows/
│   │   └── terraform.yml      # Main pipeline workflow
│   │
│   ├── actions/               # Reusable composite actions
│   │   ├── apply/             # Terraform apply
│   │   ├── changelog/         # Generate changelogs
│   │   ├── cost-estimate/     # Infracost integration
│   │   ├── destroy/           # Terraform destroy
│   │   ├── graph/             # Dependency visualization
│   │   ├── metrics/           # Pipeline metrics
│   │   ├── module-version/    # Semantic versioning
│   │   ├── plan/              # Terraform plan
│   │   ├── policy-check/      # OPA/Sentinel policies
│   │   ├── resource-inventory/# Resource listing
│   │   ├── secret-scan/       # Secret detection
│   │   ├── security/          # Security scanning
│   │   ├── state-backup/      # State file backup
│   │   ├── terraform-docs/    # Documentation generation
│   │   ├── terratest/         # Infrastructure testing
│   │   └── validate/          # Format & validate
│   │
│   └── SETUP.md               # Detailed setup guide
│
└── README.md                  # This file
```

### Key Files

| File | Purpose |
|------|---------|
| `terraform.yml` | Main workflow orchestrating all stages |
| `SETUP.md` | Step-by-step Azure and GitHub setup |
| `actions/*/action.yml` | Individual composite actions |

---

## 🔗 Using Actions in Other Repositories

### Option 1: Copy Actions

Copy the `.github/actions/` folder to your repository.

### Option 2: Reference Remote Actions

```yaml
# In your workflow
- name: Terraform Plan
  uses: Jamonygr/terraform-github-actions/.github/actions/plan@main
  with:
    azure_credentials: ${{ secrets.AZURE_CREDENTIALS }}
    # ... other inputs
```

---

## 🏷️ Supported Terraform Versions

| Version | Status |
|---------|--------|
| 1.9.x | ✅ Recommended |
| 1.8.x | ✅ Supported |
| 1.7.x | ✅ Supported |
| 1.6.x | ⚠️ Limited |
| < 1.6 | ❌ Not supported |

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [HashiCorp Terraform](https://www.terraform.io/)
- [Infracost](https://www.infracost.io/)
- [tfsec](https://github.com/aquasecurity/tfsec)
- [Checkov](https://www.checkov.io/)
- [TFLint](https://github.com/terraform-linters/tflint)
- [GitHub Actions](https://github.com/features/actions)

---

## 📞 Support

| Resource | Link |
|----------|------|
| **Issues** | [GitHub Issues](https://github.com/Jamonygr/terraform-github-actions/issues) |
| **Terraform Docs** | [Terraform Documentation](https://developer.hashicorp.com/terraform/docs) |
| **GitHub Actions** | [Actions Documentation](https://docs.github.com/en/actions) |

---

**Built with ❤️ for Infrastructure as Code automation**

*Last Updated: January 2026*
