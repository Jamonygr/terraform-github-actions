# Security

This pipeline includes multiple security layers to detect misconfigurations, leaked secrets, and risky changes.

## Security scanners

| Tool | Purpose | Job |
|------|---------|-----|
| tfsec | Terraform static analysis | `security-tfsec` |
| Checkov | Policy/compliance scanning | `security-checkov` |
| Terrascan | IaC security scanning | `security-terrascan` (optional) |
| Gitleaks | Secret detection | `secret-scan` |
| TFLint | Best practices / provider issues | `tflint` |
| Conftest | Policy-as-code validation | `policy-check` |

## SARIF reporting

- tfsec, Checkov, and Terrascan upload SARIF results.
- Results appear in the GitHub Security tab.

## Policy checks

- Policies live under `policies/`.
- Conftest evaluates `tfplan.json` produced from the plan.
- Use `soft_fail=false` to block on policy violations.

## Secret scanning

- Gitleaks runs across repository history by default.
- A local `.gitleaks.toml` is created if missing.
- Set `fail_on_leak=true` in the action inputs to block on findings.

## Recommendations

- Use OIDC for short-lived credentials.
- Enforce branch protection rules and required status checks.
- Configure required tags to enforce ownership and cost attribution.

_Last updated: January 2026_
