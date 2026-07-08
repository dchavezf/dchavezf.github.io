---
layout: page
title: "ADR-003: MDM as Governed Seed over Probabilistic Entity Resolution"
permalink: /docs/adr/ADR-003-mdm-as-governed-seed/
---

# ADR-003: MDM as Governed Seed over Probabilistic Entity Resolution

> **Status:** Accepted
> **Date:** 2026-07-08
> **Decision Makers:** Daniel Chávez Flores
> **Project:** [Project 1 — Enterprise O2C & MDM Resolution Platform](/projects/dbt-o2c-mdm/)

## Context

MeridianTrade's 20 regional ERPs use local customer numbering — customer `1001` in Mexico and customer `1001` in Colombia are different entities. The platform needs a Master Data Management (MDM) layer to resolve these colliding identifiers into a global, trustworthy customer identity.

Two approaches were evaluated:

- **Deterministic resolution via a governed seed file**: A steward-owned CSV cross-reference mapping (`region`, `source_id`) → `global_customer_id`, managed by data stewards and loaded as a dbt seed.
- **Probabilistic ML entity resolution**: Using fuzzy matching (name similarity, address parsing, tax ID matching) to automatically merge candidate records above a confidence threshold.

## Decision

Adopt **deterministic identity resolution via a governed dbt seed** (`mdm_customer_cross_ref.csv`). Unmapped customers receive a deterministic surrogate identity and surface in a stewardship queue. Probabilistic matching is documented as a Phase 2 enhancement.

## Consequences

### Positive

- **Auditable and explainable**: Every identity resolution can be traced to a specific row in the cross-reference. Finance teams can audit exactly why two records were (or weren't) merged — critical for credit exposure consolidation.
- **Business-owned, engineering-operated**: Data stewards own the mapping (business domain knowledge); engineering owns the pipeline. Clear separation of responsibilities.
- **Zero dropped records**: Unmapped customers are never silently lost; they get a surrogate identity and appear in the stewardship queue for human review.
- **Predictable behavior**: No confidence thresholds to tune, no false-positive merges that silently corrupt financial aggregations.

### Negative

- **Manual effort for initial mapping**: The first cross-reference requires stewards to map customers across 20 regions. Mitigated by building the stewardship queue to surface unmapped records systematically.
- **Does not scale to millions of entities automatically**: If MeridianTrade had millions of unique customers across regions, manual stewardship would be impractical. The current scope (enterprise B2B customers) is manageable.

### Neutral

- The dbt seed mechanism limits the cross-reference to in-repo CSV files. For very large mappings, a source table or API integration would replace the seed, but the join logic remains identical.

## References

- [Project 1 — MDM architecture](/projects/dbt-o2c-mdm/#3--what-is-the-methodology)
- [ADR-002](/docs/adr/ADR-002-medallion-kimball-over-data-vault/) — Related decision on modeling methodology
