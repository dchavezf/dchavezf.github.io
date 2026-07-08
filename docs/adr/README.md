---
layout: page
title: "Architecture Decision Records"
permalink: /docs/adr/
---

# Architecture Decision Records (ADRs)

This directory contains the architectural decision records for the MeridianTrade Group data platform portfolio. Each ADR documents a significant technical choice, the alternatives considered, and the trade-offs accepted.

## Index

| ADR | Decision | Status | Project |
|-----|----------|--------|---------|
| [ADR-001](/docs/adr/ADR-001-elt-over-etl/) | ELT (transform in-warehouse) over ETL | Accepted | Project 1 |
| [ADR-002](/docs/adr/ADR-002-medallion-kimball-over-data-vault/) | Medallion + Kimball over Data Vault 2.0 | Accepted | Project 1 |
| [ADR-003](/docs/adr/ADR-003-mdm-as-governed-seed/) | Governed seed MDM over probabilistic entity resolution | Accepted | Project 1 |
| [ADR-004](/docs/adr/ADR-004-config-driven-dag-factory/) | Config-driven DAG factory over hand-written DAGs | Accepted | Project 2 |
| [ADR-005](/docs/adr/ADR-005-gold-whitelist-sql-guard/) | Gold whitelist SQL guard over open SQL generation | Accepted | Project 3 |
| [ADR-006](/docs/adr/ADR-006-deterministic-lineage-over-llm-generation/) | Deterministic lineage traversal over LLM generation | Accepted | Project 3 |

## Format

All ADRs follow the [MADR](https://adr.github.io/madr/) template. See [template.md](template.md) for the structure.

## Why ADRs?

At senior architectural levels, *what you chose not to build* is as important as what you did build. These records demonstrate engineering judgment: the ability to evaluate trade-offs, scope constraints, and make defensible decisions under uncertainty.
