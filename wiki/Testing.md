# Testing

Testing can be enabled at multiple layers: Terraform unit tests, Terratest integration, and optional ephemeral environments for PRs.

![Testing pyramid](assets/testing-pyramid.svg)

## Terraform tests

- The `terraform-tests` job runs `terraform test` when `.tftest.*` files are present.
- Disable with `ENABLE_TERRAFORM_TESTS=false`.

## Terratest

- The `integration-tests` job runs on pull requests.
- Configure the tests under `tests/`.
- Results are uploaded as JUnit when `output_format=junit`.

## Ephemeral PR environments (optional)

- Controlled by `ENABLE_EPHEMERAL_ENV=true` and `EPHEMERAL_VAR_FILE`.
- Creates a temporary state key (e.g., `ephemeral-pr-123.terraform.tfstate`).
- Applies and destroys automatically during the PR workflow.

![Ephemeral PR environment](assets/ephemeral-env.svg)

## Recommended structure

```
/tests
  - unit
  - integration
/test
  - minimal Terraform example
```

_Last updated: January 2026_
