# ADR-004: Config-Driven DAG Factory over Hand-Written DAGs

> **Status:** Accepted
> **Date:** 2026-07-08
> **Decision Makers:** Daniel Chávez Flores
> **Project:** [Project 2 — Multi-Source Ingestion Platform with IaC](/projects/airflow-iac-pipeline/)

## Context

MeridianTrade's ingestion platform must extract data from 20 regional ERP systems that share the same base schema but differ in connection details, schedules, SLAs, and entity subsets. The Airflow orchestration layer needs to handle all 20 sources.

Two approaches were evaluated:

- **One hand-written DAG per region**: Explicit, easy to understand individually, but results in 20 near-identical files with duplicated logic. Any behavioral change (retry policy, alerting callback) must be applied 20 times.
- **A config-driven DAG factory**: Pipeline logic is written once; each region is defined in a YAML configuration file. Airflow generates per-region DAGs from config at parse time.

## Decision

Adopt a **config-driven DAG factory pattern**. A single Python module reads region YAML configs and generates one Airflow DAG per region. Each config specifies: connection reference, entities to extract, schedule, SLA thresholds, and watermark columns.

## Consequences

### Positive

- **Onboarding a new region is a YAML entry, not new code**: Reduces onboarding from a sprint to under one hour — critical for the 20-country mandate.
- **Single point of logic maintenance**: Retry policies, alerting callbacks, data contract validation, and freshness checks are defined once and apply uniformly.
- **Consistency by construction**: All regions follow the same pipeline shape (`extract → validate_contract → load → freshness_check`); no drift between regions.

### Negative

- **Debugging indirection**: When a DAG fails, an engineer must understand both the factory code and the YAML config to trace the issue. Mitigated by clear logging that references the config source.
- **Factory complexity**: The DAG factory itself is more complex than any single hand-written DAG. Mitigated by comprehensive unit tests on the factory logic.

### Neutral

- Airflow's `DagBag` discovery model natively supports dynamically generated DAGs — no custom scheduler plugins needed.

## References

- [Astronomer: Dynamically Generating DAGs](https://www.astronomer.io/guides/dynamically-generating-dags/)
- [Project 2 — Methodology](/projects/airflow-iac-pipeline/#3--what-is-the-methodology)
