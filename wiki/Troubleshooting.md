# Troubleshooting

## Authentication failures

- Verify `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, and `AZURE_SUBSCRIPTION_ID`.
- Ensure federated credentials match the repository and branch.
- For legacy auth, validate the `AZURE_CREDENTIALS` JSON format.

## Backend initialization failed

- Confirm the storage account and container exist.
- Verify `TF_STATE_RG` and `TF_STATE_SA` secrets.
- For OIDC, confirm `Storage Blob Data Contributor` role is assigned.

## Plan or apply failures

- Check the workflow summary for plan output.
- Validate `var_file` paths and `working_directory`.
- Confirm provider credentials and required Azure resource providers.
- If you see `Given variables file ... does not exist`, make sure the workflow is pointing at the correct working directory (this repo defaults to `./test`) and that the var file path is relative to that directory.

## Drift detection failures

- Ensure the state key and var file exist for each environment.
- Check permissions for refresh-only plans.

## Secret scan false positives

- Update `.gitleaks.toml` to allowlist paths or patterns.

## TFLint plugin download failures

- Re-run; transient network errors can occur.
- Confirm the runner has outbound network access.

_Last updated: January 2026_
