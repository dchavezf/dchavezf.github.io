---
layout: page
title: "PRD: Enterprise O2C & MDM Resolution Platform"
permalink: /docs/prd/project1-o2c-mdm/
description: >-
  Product Requirements Document for Project 1 — the governed Order-to-Cash
  transformation and MDM resolution platform. Connects the MeridianTrade
  business case to architecture decisions and delivery.
---

# PRD: Enterprise O2C & MDM Resolution Platform

> **Product:** MeridianTrade Order-to-Cash & MDM Resolution Platform
> **Owner:** Daniel Chávez Flores
> **Status:** Approved — in delivery
> **Date:** 2026-07-09
> **Upstream:** [Business Case — MeridianTrade Platform Transformation](/projects/transformation-business-case/)
> **Downstream:** [Architecture Decision Records](/docs/adr/) · [Project page](/projects/dbt-o2c-mdm/) · [Delivery Lifecycle](/docs/delivery-lifecycle/)

This PRD is the bridge between the business case (why we're doing this, what it's worth) and the architecture decisions and code (how it gets built). If the business case answers "should we fund this," the PRD answers "what exactly are we building, for whom, and how do we know it's done."

---

## 1 · Problem Statement

MeridianTrade Group consolidates Order-to-Cash (O2C) results from 20 regional ERP systems manually, in spreadsheets, at month-end close. Customer identifiers collide across regions, "order date" means different things in different countries, and no one can trace a disputed number back to its source without days of forensic investigation.

The cost of inaction is quantified in the [business case](/projects/transformation-business-case/#business-problem): reconciliation labor at close, audit exposure, duplicate credit risk from misattributed customer identity, and a platform that gets less trustworthy — not more — as MeridianTrade onboards additional regions.

## 2 · Goals and Non-Goals

**Goals**

- Deliver one governed, tested Order-to-Cash Gold layer that 500+ business users can query without reconciling numbers themselves.
- Resolve colliding customer identifiers across all 20 regions through a deterministic, auditable MDM layer — not a black-box matching algorithm.
- Track customer master history (Tax ID changes, credit terms) for compliance, via SCD Type 2.
- Reduce warehouse compute cost on heavy fact rebuilds through incremental processing.
- Make onboarding a new region a checklist, not a re-architecture — because 20 regions today does not mean 20 regions forever.

**Non-Goals (explicit scope boundaries)**

- **Probabilistic / ML-based entity resolution.** Deterministic, steward-owned matching is the foundation ([ADR-003](/docs/adr/ADR-003-mdm-as-governed-seed/)). Probabilistic matching is a Phase 2 enhancement, not part of this delivery.
- **Real-time/streaming ingestion.** This platform consumes batch-loaded data from [Project 2](/projects/airflow-iac-pipeline/). Streaming is out of scope until a business case for sub-daily O2C visibility exists.
- **Building the ingestion layer itself.** Extraction from the 20 ERPs is Project 2's mandate. This PRD assumes raw regional tables already land reliably.
- **Self-service semantic layer / BI tool selection.** This PRD delivers governed Gold tables. Which BI tool sits on top is a separate decision.

## 3 · Target Users and Personas

| Persona | Need | How This Platform Serves Them |
|---|---|---|
| **Group Finance / CFO office** | One number they're willing to sign at close | Ratified O2C definitions, single Gold fact table, full lineage |
| **Regional Controller** | Confidence their region's data is represented correctly, without losing local nuance | Region-scoped staging models before consolidation; inferred-member handling instead of dropped orders |
| **Data Steward** | A queue of ambiguous identity matches to resolve, not a black box to trust blindly | `rpt_mdm_stewardship_queue` — auditable, actionable, owned by the business, not engineering |
| **BI Analyst (500+ users)** | Query Gold tables without knowing which of 20 source systems a customer came from | Kimball star schema (`dim_customer`, `dim_date`, `fct_order_cycle`) as the sole serving interface |
| **Platform Engineer (future maintainer)** | Confidence that adding region 21 doesn't require reverse-engineering the pipeline | Documented spec, tested contracts, incremental strategy that scales by config |

## 4 · User Stories and Acceptance Criteria

### Epic A — Governed Identity Resolution

- **US-A1.** As a data steward, I need unmapped customer identities to receive a deterministic surrogate ID and appear in a stewardship queue, so that no order is ever silently dropped or double-counted.
  *Acceptance:* every row in `int_customers__resolved` has a non-null enterprise customer key; unmapped customers are 100% visible in `rpt_mdm_stewardship_queue`; a custom dbt test fails the build on any dropped orphan.
- **US-A2.** As group finance, I need customer identity resolution to be explainable without asking an engineer, so that audit defense doesn't depend on tribal knowledge.
  *Acceptance:* the MDM cross-reference is a version-controlled seed file with a visible diff history; resolution logic is a documented join, not a trained model.

### Epic B — Trustworthy Order-to-Cash Facts

- **US-B1.** As a BI analyst, I need one `fct_order_cycle` table with consistent cycle-time measures across all 20 regions, so that I stop reconciling region-specific definitions myself.
  *Acceptance:* `days_order_to_ship` and `days_invoice_to_cash` are calculated identically for every region; schema tests enforce `not_null`/`relationships` on all foreign keys.
- **US-B2.** As a platform engineer, I need fact rebuilds to be incremental, so that warehouse cost doesn't scale linearly with history as more regions onboard.
  *Acceptance:* incremental merge strategy is documented and measured in `docs/finops.md`; compute reduction vs. full refresh is logged per run.

### Epic C — Compliance-Grade History

- **US-C1.** As an auditor, I need to see what a customer's Tax ID / credit terms were on any past date, so that financial adjustments can be reconstructed without guesswork.
  *Acceptance:* `dbt snapshot` captures SCD Type 2 history on the customer master; a query for "as-of" attributes returns the correct historical row.

### Epic D — Onboarding Velocity

- **US-D1.** As a platform engineer, I need onboarding a new regional source to be a config/model addition, not a rewrite of Silver/Gold logic, so that the 20-country, two-quarter mandate is achievable.
  *Acceptance:* adding a region requires only a new staging model plus an entry in the union — Silver integration and Gold marts require zero changes, verified against the documented 5-step checklist in the [project page](/projects/dbt-o2c-mdm/#5--what-are-the-quantified-outcomes).

## 5 · Success Metrics

Traced directly from the [business case's Expected Outcomes](/projects/transformation-business-case/#expected-outcomes):

| Metric | Baseline | Target |
|---|---|---|
| Warehouse compute on heavy fact rebuilds | Full nightly refresh | Up to 40% reduction via incremental merge |
| Dropped/misattributed customer records | Unquantified silent loss | Zero — every unmapped identity is surrogate-keyed and queued |
| Time to trace a disputed number to source | Days of manual investigation | Seconds, via column-level lineage |
| Time to onboard a new region | Full re-architecture | 5-step checklist |
| Untested transformations reaching Gold | Common | Zero — CI-enforced schema + custom tests block the build |

## 6 · Spec and Architecture

The full technical methodology, data flow diagram, and architecture decision trade-off tables live on the [project page](/projects/dbt-o2c-mdm/#3--what-is-the-methodology). Every architectural choice referenced above is formalized as an ADR:

- [ADR-002](/docs/adr/ADR-002-medallion-kimball-over-data-vault/) — Medallion + Kimball over Data Vault 2.0
- [ADR-003](/docs/adr/ADR-003-mdm-as-governed-seed/) — MDM as governed seed over probabilistic resolution
- [ADR-007](/docs/adr/ADR-007-semantic-layer-ratification/) — Semantic layer ratification before migration
- [ADR-011](/docs/adr/ADR-011-irreversible-strangler-cutover/) — Irreversible strangler cutover

## 7 · Delivery Plan

Work is tracked as epics and stories in the repository's issue tracker, grouped into milestones:

- **Milestone 1 — Bronze & Contracts:** staging models per region, lineage keys, source freshness tests.
- **Milestone 2 — Silver & MDM:** dynamic region union, MDM cross-reference seed, stewardship queue, inferred-member handling.
- **Milestone 3 — Gold & FinOps:** Kimball marts, incremental fact strategy, compute measurement.
- **Milestone 4 — Hardening & Release:** CI gate, test coverage, `docs/runbook.md`, tagged release.

Live backlog: [github.com/dchavezf/marts_order_cycle/issues](https://github.com/dchavezf/marts_order_cycle/issues) · [milestones](https://github.com/dchavezf/marts_order_cycle/milestones)

## 8 · Out of Scope for v1 / Future Considerations

- Probabilistic entity resolution as a stewardship accelerator (Phase 2).
- Sub-daily/streaming O2C visibility.
- Expansion beyond Order-to-Cash into Procure-to-Pay (would reuse the same MDM and Medallion foundation).

## 9 · Assumptions and Risks

Inherited from the [business case Risk Assessment](/projects/transformation-business-case/#risk-assessment): the primary delivery risk is unratified metric definitions reaching production before finance sign-off. This PRD assumes Phase 1 (definition and governance lock) is complete before Epic B work begins.
