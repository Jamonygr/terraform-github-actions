# Terraform GitHub Actions Wiki

Welcome to the documentation for the Terraform GitHub Actions repository. This wiki explains how the unified pipeline works, how to configure it for your Azure subscription, and how to extend it with optional stages like tests, policy checks, and drift detection.

## Quick links

- [Getting Started](Getting-Started.md)
- [Architecture](Architecture.md)
- [Workflow Modes](Workflow-Modes.md)
- [Pipeline Stages](Pipeline-Stages.md)
- [Actions Reference](Actions-Reference.md)
- [Security](Security.md)
- [Cost Estimation](Cost-Estimation.md)
- [Testing](Testing.md)
- [Operations](Operations.md)
- [Troubleshooting](Troubleshooting.md)
- [Glossary](Glossary.md)

## Pipeline overview

![Pipeline overview](assets/pipeline-overview.svg)

## Mode routing

![Modes diagram](assets/modes-diagram.svg)

## What this repository provides

- A single, unified workflow that supports single-environment, multi-environment matrix, and scheduled drift detection.
- Reusable composite actions for Terraform plan/apply/destroy, security scanning, documentation, and reporting.
- Optional gates for tags, canary apply, and ephemeral PR environments.

## Repository layout

- `.github/workflows/terraform.yml` is the unified pipeline.
- `.github/actions/` contains all composite actions used by the workflow.
- `.github/SETUP.md` provides the Azure and GitHub setup checklist.
- `test/` contains a minimal Terraform example for validation.

## Getting started path

1. Follow [Getting Started](Getting-Started.md) to configure Azure credentials and state storage.
2. Run the workflow in `single` mode with `plan` for a first validation.
3. Enable optional stages as needed via repository variables.

## Support

- Use GitHub Issues to report defects or request improvements.
- See [Troubleshooting](Troubleshooting.md) for common errors.

_Last updated: January 2026_
