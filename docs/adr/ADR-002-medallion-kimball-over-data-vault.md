---
layout: page
title: "ADR-002: Medallion + Kimball Hybrid over Data Vault 2.0"
permalink: /docs/adr/ADR-002-medallion-kimball-over-data-vault/
---

# ADR-002: Medallion + Kimball Hybrid over Data Vault 2.0

> **Status:** Accepted
> **Date:** 2026-07-08
> **Decision Makers:** Daniel Chávez Flores
> **Project:** [Project 1 — Enterprise O2C & MDM Resolution Platform](/projects/dbt-o2c-mdm/)

## Context

The data platform requires a modeling methodology that supports 20 heterogeneous source systems, historical tracking, and consumption by 500+ BI users. Two leading approaches were evaluated:

- **Data Vault 2.0 (DV2):** Hub-Link-Satellite architecture optimized for auditability and agile integration of new sources. High flexibility but adds structural complexity (many join patterns) and a steeper learning curve for BI consumers.
- **Medallion + Kimball:** A three-layer architecture (Bronze/Silver/Gold) where Gold marts use Kimball star schemas (facts and dimensions). Simpler for BI tools and analysts to query directly.

## Decision

Adopt a **Medallion architecture (Bronze/Silver/Gold) with Kimball dimensional modeling** at the Gold layer. Data Vault 2.0 is documented as a viable Phase 2 enhancement if source volatility increases beyond what the current MDM approach handles.

## Consequences

### Positive

- **BI-friendly consumption**: Kimball star schemas are what 500 BI users actually consume — familiar join patterns, performant aggregations, and first-class support in every BI tool.
- **Simpler onboarding**: New analysts and engineers can be productive faster; the mental model (facts, dimensions, measures) is widely understood.
- **Medallion layering provides auditability**: Bronze preserves raw data; Silver handles integration; Gold serves business definitions. Lineage is traceable across layers.

### Negative

- **Less flexible under extreme schema churn**: If source systems change schemas weekly, DV2's hash-key-based structure would absorb changes more gracefully. Mitigated because MeridianTrade's ERPs are stable SQL Server schemas.
- **MDM responsibility shifts to a governed seed**: Without DV2's hub-link structure for entity resolution, identity management is handled by a separate MDM cross-reference (see [ADR-003](ADR-003-mdm-as-governed-seed.md)).

### Neutral

- Both approaches require SCD Type 2 for historical tracking; dbt snapshots handle this identically regardless of modeling methodology.

## References

- Kimball Group: [The Data Warehouse Toolkit](https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/dimensional-modeling-techniques/)
- [Databricks Medallion Architecture](https://www.databricks.com/glossary/medallion-architecture)
- [Project 1 — Methodology](/projects/dbt-o2c-mdm/#3--what-is-the-methodology)
