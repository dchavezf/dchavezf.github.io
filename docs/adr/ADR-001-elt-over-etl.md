# ADR-001: ELT (Transform In-Warehouse) over ETL

> **Status:** Accepted
> **Date:** 2026-07-08
> **Decision Makers:** Daniel Chávez Flores
> **Project:** [Project 1 — Enterprise O2C & MDM Resolution Platform](/projects/dbt-o2c-mdm/)

## Context

MeridianTrade Group needs to consolidate data from 20 regional ERP systems (SQL Server) into a unified analytical platform. The transformation pipeline must handle 10TB+ of data, support incremental processing, and be maintainable by a SQL-first team. Two paradigms were evaluated: ETL (transform before loading, e.g., via Spark) and ELT (load raw data into the warehouse, transform in place using SQL).

The team's core competency is SQL and analytics engineering, not distributed systems programming. The target warehouses (Snowflake and BigQuery) offer elastic compute that scales on demand.

## Decision

Adopt **ELT** with **dbt Core** as the transformation framework. All transformation logic executes inside the warehouse using SQL and Jinja macros, version-controlled and tested like software.

## Consequences

### Positive

- **Elastic compute**: The warehouse scales horizontally; no need to provision and manage Spark clusters.
- **Testing, docs, and lineage for free**: dbt provides schema tests, auto-generated documentation, and a full DAG lineage graph as first-class features.
- **SQL-first accessibility**: The SQL-first approach matches the team's skill profile and lowers the barrier for analysts to contribute to and review transformation logic.
- **Faster iteration**: Changes to transformations are SQL files in a git repo — no compile-deploy cycles of a Spark application.

### Negative

- **Warehouse cost coupling**: All compute is warehouse compute; poorly optimized queries can generate unexpected costs. Mitigated by incremental materializations and FinOps monitoring.
- **Limited to SQL expressiveness**: Complex ML feature engineering or unstructured data processing may require supplementary tools. Acceptable for the O2C domain.

### Neutral

- The ELT pattern assumes a reliable ingestion layer delivers raw data into the warehouse — this dependency is addressed by [Project 2](/projects/airflow-iac-pipeline/).

## References

- [dbt Core documentation](https://docs.getdbt.com/)
- [Project 1 — Methodology](/projects/dbt-o2c-mdm/#3--what-is-the-methodology)
