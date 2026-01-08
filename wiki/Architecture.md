# Architecture

This repository is designed as a reusable pipeline with a single orchestrator workflow and a set of composite actions.

## Components

- **Unified workflow**: `.github/workflows/terraform.yml` routes all modes.
- **Composite actions**: `.github/actions/*` implement reusable steps.
- **State storage**: Azure Storage account with `tfstate` and backup containers.
- **Reporting**: PR comments, artifacts, and optional notifications.

## Authentication

![Authentication options](assets/authentication-options.svg)

## Data flow

1. Source code changes trigger format/validate and security stages.
2. Plan artifacts are created and uploaded.
3. Apply consumes the plan artifact and records audit output.
4. Metrics and inventories are generated post-apply.

## Modes and routing

The router job chooses between single, matrix, and drift modes. See [Workflow Modes](Workflow-Modes.md).

_Last updated: January 2026_
