---
layout: post
title: "Why Medallion + Kimball Over Data Vault 2.0 for a 20-Country Migration"
date: 2026-07-08
categories: [Architecture]
tags: [dbt, kimball, medallion, data-vault, mdm, modeling]
description: >-
  An architectural decision walkthrough: choosing Medallion + Kimball dimensional
  modeling over Data Vault 2.0 for a multinational ERP consolidation, and when
  Data Vault would have been the better call.
---

# Why Medallion + Kimball Over Data Vault 2.0 for a 20-Country Migration

When consolidating 20 regional ERPs into a single data platform, one of the first and most consequential decisions is the modeling methodology. This post walks through the reasoning behind choosing a Medallion + Kimball hybrid over Data Vault 2.0 — and, equally importantly, the scenarios where Data Vault would have been the right answer.

---

## The Context

MeridianTrade Group (the fictional enterprise behind this portfolio's three projects) grew by acquisition. Each country runs its own SQL Server ERP: same vendor, different schemas, different business rules, different customer numbering. The mandate: consolidate into a single analytical platform within two quarters.

The transformation engine ([Project 1](/projects/dbt-o2c-mdm/)) needs a modeling methodology that handles:

- **20 heterogeneous sources** with colliding identifiers
- **Historical tracking** of master data changes (Tax IDs, credit terms)
- **Consumption by 500+ BI users** with varying technical sophistication
- **Fast onboarding** — adding a new country should be a checklist, not a refactor

---

## The Two Contenders

### Data Vault 2.0

Hub-Link-Satellite architecture. Hubs hold business keys, Links capture relationships, Satellites store descriptive attributes with full historization. Designed for agility under source churn and auditability at the record level.

**Strengths for this use case:**
- Native handling of many-to-many relationships between sources
- Schema changes absorbed gracefully (new Satellite, existing queries unaffected)
- Full history by default — every attribute change tracked

**Concerns for this use case:**
- BI consumption requires a *Business Vault* or *Information Mart* layer on top — the raw vault is not analyst-friendly
- More joins per query (Hub → Link → Satellite vs. Fact → Dimension)
- Steeper learning curve for a SQL-first team
- The additional structural complexity may be over-engineering for ERP schemas that are *stable* (not churning weekly)

### Medallion + Kimball

Three-layer architecture (Bronze/Silver/Gold) where Gold marts use Kimball star schemas: facts with measures, dimensions with descriptive attributes, conformed across sources. The most widely adopted pattern in dbt-based data platforms.

**Strengths for this use case:**
- Star schemas are what BI tools and analysts are designed to query
- Simpler mental model (facts, dimensions, measures) → faster onboarding
- dbt's testing and documentation ecosystem is built around this pattern
- Medallion layers provide the auditability that Data Vault's raw vault provides — just organized differently

**Concerns for this use case:**
- Less flexible under extreme source schema volatility
- Identity resolution isn't structural — requires a separate MDM mechanism

---

## The Decision

We chose **Medallion + Kimball** with three mitigations for the trade-offs:

1. **MDM as a governed seed** ([ADR-003]({{ site.baseurl }}/docs/adr/ADR-003-mdm-as-governed-seed.md)): Identity resolution is handled by a steward-owned cross-reference, not by the modeling structure itself. This is explicit, auditable, and business-owned.

2. **SCD Type 2 via dbt snapshots**: Historical tracking of dimension changes (the feature Data Vault provides structurally) is achieved through dbt's snapshot mechanism. The result is functionally equivalent for this use case.

3. **Data Vault documented as the upgrade path**: If source volatility increases (say, MeridianTrade acquires companies on different ERP platforms with radically different schemas), the Silver layer can be refactored toward a vault structure without touching Bronze or Gold.

---

## When Data Vault Would Have Won

Intellectual honesty requires naming the scenarios where DV2 is the better choice:

- **Weekly schema changes** from upstream sources — DV2's satellite model absorbs these gracefully
- **Regulatory environments** where record-level, immutable auditability is a legal requirement (not just a nice-to-have)
- **Teams with DV2 expertise** — the productivity advantage of Kimball evaporates if the team already thinks in Hubs and Links
- **Hundreds of sources** with complex many-to-many relationships — DV2's Link tables model these more naturally than Kimball bridge tables

None of these applied to MeridianTrade's situation. The ERPs are stable, the team is SQL-first, and the primary consumer is a BI layer that speaks star schema natively.

---

## The Takeaway

The best modeling methodology is the one that matches your constraints: team skills, source volatility, consumption patterns, and timeline. The decision here wasn't "Kimball is better than Data Vault" — it was "Kimball is better *for this context*." The formal reasoning lives in [ADR-002]({{ site.baseurl }}/docs/adr/ADR-002-medallion-kimball-over-data-vault.md).

Senior architecture is choosing what *not* to build. Data Vault 2.0 is excellent engineering — and it was the wrong choice here. Knowing the difference is the job.
