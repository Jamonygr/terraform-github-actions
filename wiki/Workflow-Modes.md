# Workflow Modes

The unified workflow supports three modes that are routed by the `mode` input (or by schedule):

| Mode | Purpose | Trigger | Notes |
|------|---------|---------|-------|
| `single` | Single-environment plan/apply/destroy | Manual dispatch or push/PR | Default mode |
| `matrix` | Parallel plan/apply across environments | Manual dispatch | Uses a comma-separated environment list |
| `drift` | Scheduled or manual drift detection | Schedule or manual dispatch | Uses refresh-only plans |

## Trigger routing

![Workflow triggers](assets/workflow-triggers.svg)

![Modes diagram](assets/modes-diagram.svg)

## Single mode

Use for most day-to-day workflows:

```yaml
mode: single
environment: lab
action: plan
```

- Plan runs on PRs and pushes by default.
- Apply and destroy require `workflow_dispatch` with the correct `action` value.

## Matrix mode

Use for multi-environment deployments:

```yaml
mode: matrix
environments: dev,staging,prod
action: apply
```

- Plans run for each environment.
- Applies are sequenced (dev -> staging -> prod).
- Environment protection rules still apply.

## Drift mode

Drift detection uses a scheduled trigger or manual dispatch:

```yaml
mode: drift
create_drift_issue: true
```

- Runs `terraform plan -refresh-only` in each configured environment.
- Creates a GitHub issue when drift is found (optional).

## Router logic

The router job determines the mode using:

- `workflow_dispatch` input `mode`
- `schedule` trigger (forces `drift`)
- default `single` mode when unspecified

_Last updated: January 2026_
