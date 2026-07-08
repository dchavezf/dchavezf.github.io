---
layout: page
title: "ADR-005: Gold Whitelist SQL Guard over Open SQL Generation"
permalink: /docs/adr/ADR-005-gold-whitelist-sql-guard/
---

# ADR-005: Gold Whitelist SQL Guard over Open SQL Generation

> **Status:** Accepted
> **Date:** 2026-07-08
> **Decision Makers:** Daniel Chávez Flores
> **Project:** [Project 3 — Warehouse Copilot: GenAI over Governed Data](/projects/genai-rag-warehouse/)

## Context

Warehouse Copilot includes a text-to-SQL mode that generates SQL from natural-language business questions. In an enterprise context, unrestricted SQL generation by an LLM against a production warehouse poses severe risks: hallucinated table/column names, unintended writes (DML/DDL), access to raw/staging data bypassing governance, and uncontrolled scan costs.

Two approaches were evaluated:

- **Open SQL generation**: The LLM generates arbitrary SQL against the full warehouse schema. Simpler to implement but impossible to bound the blast radius.
- **Gold whitelist with static SQL guard**: SQL generation is restricted to a pre-approved list of documented Gold-layer models. Generated SQL is statically parsed and validated before execution.

## Decision

Adopt a **multi-layered SQL safety architecture**:

1. **Gold model whitelist**: Only documented Gold-layer models (from dbt's manifest) are available for query generation.
2. **Static SQL guard** (via `sqlglot`): Validates that generated SQL is a single `SELECT` statement, references only whitelisted relations, contains no DML/DDL, and includes an enforced `LIMIT` clause.
3. **Read-only database role**: The execution connection has read-only permissions at the database level.
4. **Timeout and scan caps**: Query execution is bounded by time and bytes-scanned limits.
5. **Always show the SQL**: Users see the generated query alongside results — no hidden computation.

## Consequences

### Positive

- **Bounded blast radius by design**: Even a successful prompt injection can, at worst, produce a `SELECT` on Gold models already visible to the user. This is the critical insight: the *constraint* is what makes it deployable in an enterprise.
- **Auditability builds trust**: Showing SQL to analysts satisfies governance requirements and builds organic adoption — they can verify the system's reasoning.
- **Cost control**: LIMIT enforcement and scan caps prevent runaway queries from impacting the warehouse budget.

### Negative

- **Cannot answer questions requiring raw-layer data**: Questions about data freshness, ingestion anomalies, or staging-level debugging require direct warehouse access. Mitigated by the refusal mode, which explains the limitation and provides an escalation path.
- **Whitelist maintenance**: The Gold whitelist must be regenerated when dbt models change. Mitigated by deriving it automatically from `manifest.json` post-`dbt build`.

### Neutral

- The static guard is conservative by design — it may reject valid but complex SQL (CTEs, window functions) if the sqlglot parser doesn't recognize the pattern. This is an acceptable trade-off: false refusals are safe; false acceptances are not.

## References

- [sqlglot — SQL parser and transpiler](https://github.com/tobymao/sqlglot)
- [Project 3 — Methodology](/projects/genai-rag-warehouse/#3--what-is-the-methodology)
- [ADR-006](/docs/adr/ADR-006-deterministic-lineage-over-llm-generation/) — Related decision on lineage handling
