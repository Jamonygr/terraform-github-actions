# Operations

This page covers apply/destroy flows, backups, notifications, and audit logging.

## Apply

- Apply runs on manual dispatch or on push unless `AUTO_APPLY=false`.
- Environment protection rules can enforce approvals.
- Optional canary apply runs first when enabled.

![Environment promotion](assets/environment-promotion.svg)

## Destroy

- Destroy runs only on manual dispatch (`action: destroy`).
- Requires `destroy_confirm=DESTROY`.
- State is backed up before destroy.

## State backup and restore

- `state-backup` runs before apply/destroy.
- Use `state-restore` to recover a previous snapshot.
- Backups are stored in the `tfstate-backups` container.

![State backup and restore](assets/state-backup.svg)

## Change freeze

- Set `ENABLE_FREEZE_WINDOW=true` to block deploys on weekends.

## Notifications

- Slack, Teams, and Discord are supported via the `notification` action.
- Use repository secrets `SLACK_WEBHOOK_URL` or `TEAMS_WEBHOOK_URL`.

## Metrics and audit logs

- `metrics` job records duration and change counts.
- Audit logs can be sent to Log Analytics when configured.

![Observability outputs](assets/observability.svg)

## Canary apply (optional)

- Enable with `ENABLE_CANARY=true`.
- Configure `CANARY_ENVIRONMENT` and optional var/state overrides.
- Canary uses its own plan/apply before prod.

_Last updated: January 2026_
