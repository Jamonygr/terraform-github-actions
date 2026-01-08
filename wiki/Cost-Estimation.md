# Cost Estimation

The workflow integrates Infracost to provide cost visibility and budget guardrails.

## How it works

- The `cost-estimate` job runs after module version and graph stages.
- Infracost evaluates the Terraform directory and var file.
- A baseline can be saved and compared to future changes.

## Required secret

- `INFRACOST_API_KEY` (repository secret)

## Threshold controls

- `COST_THRESHOLD`: Warn when monthly cost exceeds this value.
- `COST_INCREASE_THRESHOLD`: Warn when increase exceeds this value.

## Example output

```
Estimated Monthly Cost: $123.45 USD
Previous: $100.00
Change: +$23.45
```

## Tips

- Save a baseline on `main` to compare PRs against.
- Set `fail_on_threshold=true` to block large cost increases.

_Last updated: January 2026_
