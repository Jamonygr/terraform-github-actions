# Actions Reference

This repository provides composite actions under `.github/actions/`. The unified workflow uses these actions directly.

![Actions catalog](assets/actions-catalog.svg)

## Core actions

| Action | Description | Key inputs |
|--------|-------------|------------|
| `setup` | Common Terraform setup with caching | `terraform_version`, `use_oidc` |
| `validate` | Format + validate | `working_directory` |
| `plan` | Init and plan | `backend_*`, `var_file`, `environment` |
| `apply` | Apply from plan artifact | `plan_artifact`, `environment` |
| `destroy` | Destroy with confirmation | `confirm`, `var_file` |

## Security and quality

| Action | Description | Key inputs |
|--------|-------------|------------|
| `security` | tfsec + checkov + tflint | `working_directory` |
| `secret-scan` | Gitleaks scan | `scan_depth`, `config_path` |
| `policy-check` | Conftest policy validation | `policy_dir`, `soft_fail` |
| `terraform-docs` | Documentation generation | `recursive`, `output_file` |
| `terratest` | Terratest execution | `test_directory`, `timeout` |

## Reporting and ops

| Action | Description | Key inputs |
|--------|-------------|------------|
| `pr-comment` | Comment plan summary on PRs | `plan_file`, `github_token` |
| `notification` | Slack/Teams/Discord/webhook | `type`, `webhook_url` |
| `resource-inventory` | Inventory from state | `format`, `environment` |
| `metrics` | Duration and change metrics | `start_time`, `status` |
| `changelog` | Changelog entry | `environment`, `auto_commit` |
| `state-backup` | Backup remote state | `storage_account`, `state_key` |
| `state-restore` | Restore backup state | `backup_name`, `confirm` |
| `graph` | Dependency graph | `output_format` |
| `module-version` | Provider/module versions | `check_updates` |
| `version-check` | Version/CVE check | `check_cves`, `github_token` |
| `drift-detect` | Refresh-only drift detection | `create_issue`, `fail_on_drift` |
| `cost-estimate` | Infracost | `api_key`, `var_file` |

## Source of truth

Each action is defined in `./.github/actions/<action>/action.yml`. See those files for full input/output details.

_Last updated: January 2026_
