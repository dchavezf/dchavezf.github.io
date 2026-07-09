---
layout: post
title: "Your 21st Pipeline Should Be a YAML Entry, Not a Code Commit"
date: 2026-07-09
categories: [Architecture]
tags: [airflow, dag-factory, orchestration, data-engineering, config-driven, terraform]
description: >-
  Hand-written DAGs turn every global fix into 20 manual edits and every
  onboarding into a sprint. The config-driven DAG factory pattern: what it
  buys, what it costs, and when it's over-engineering.
---

# Your 21st Pipeline Should Be a YAML Entry, Not a Code Commit

There's a reliable smell test for an orchestration layer: ask what it takes to change a retry policy globally. If the answer involves a developer editing twenty files and hoping they didn't miss one, the platform doesn't have twenty pipelines — it has twenty **liabilities** that happen to share an Airflow instance.

This post walks through the config-driven DAG factory behind the [ingestion platform](/projects/airflow-iac-pipeline/), formalized in [ADR-004](/docs/adr/ADR-004-config-driven-dag-factory/): why hand-written DAGs fail at multi-source scale, what the factory pattern actually buys, and when it's the wrong call.

---

## The Failure Mode: Configuration Drift

MeridianTrade's ingestion problem is twenty regional ERPs, each needing the same pipeline shape: `extract → validate_contract → load → freshness_check`. The obvious approach — copy the last region's DAG, adjust the connection, ship it — works perfectly for the first three regions.

By region ten, entropy wins. Someone tuned a schedule for a slow source and never documented why. A retry fix landed in fourteen files out of twenty. An alerting callback exists in the regions built after March. Now "Mexico works but Colombia doesn't," and the diagnosis requires forensic code comparison instead of a config diff.

This is the **hero dependency** trap: platform consistency depends on individual engineers remembering to apply every global change to every island of code. That's not an engineering discipline; it's a ritual, and rituals don't survive team turnover.

## The Decision: Separate the What from the How

The factory pattern splits the orchestration layer in two:

- **The *how* lives in one Python module** — the factory. Pipeline structure, contract validation gates, retry semantics, SLA callbacks, alerting. Written once, unit-tested, versioned.
- **The *what* lives in YAML** — one declarative config per region: connection reference, entities, watermark columns, schedule. No logic. No branching. Plain static data.

At parse time, Airflow feeds each config through the factory and materializes twenty structurally identical DAGs. Consistency stops being a code-review aspiration and becomes a **property of the construction process** — a region literally cannot drift, because there is no regional code to drift.

The measurable consequences:

- **Onboarding a country dropped from a sprint to under an hour.** A new region is a YAML entry and a pull request.
- **Global changes are single-point.** A new SLA threshold lands in one module and every region inherits it on the next parse cycle.
- **The config files double as an auditable inventory.** "What do we ingest from Colombia, and how fresh is it?" is answered by reading a 30-line YAML contract, not by reverse-engineering a DAG.

## The Trade-offs — Because There Are Always Trade-offs

The factory is not free, and pretending otherwise is how patterns become cargo cults:

- **Debugging gains a level of indirection.** A failing DAG no longer maps to a file you can read top-to-bottom; engineers must understand the factory to reason about any region. That's a real onboarding cost for the platform team, paid in exchange for removing the onboarding cost per source.
- **The factory becomes critical infrastructure.** A bug in the module is a bug in twenty pipelines simultaneously. That's why the factory itself carries comprehensive unit tests and its own CI gate — the engine that builds pipelines has to be more trustworthy than any single pipeline.
- **It's over-engineering below a threshold.** With three heterogeneous pipelines that share no structure, the factory adds indirection and buys nothing. The pattern earns its complexity when sources are numerous and *structurally uniform* — which is exactly the multi-region ERP case, and exactly not the "five bespoke integrations" case.

## The Replicable Pattern

The decision rule I'd offer any platform team: **count how many of your pipelines are the same pipeline wearing different configs.** If the answer is more than five, your orchestration logic wants to be a tested module and your pipelines want to be data. If the answer is two, keep writing DAGs by hand and revisit next quarter.

The question the pattern forces is organizational, not technical: are you funding engineers to copy-paste structure across regions, or to build the engine that makes structure automatic?

---

*The full implementation — factory module, per-region configs, contract validation, and Terraform-provisioned environments — is reviewable at [github.com/dchavezf/airflow-iac-pipeline](https://github.com/dchavezf/airflow-iac-pipeline), with the decision record in [ADR-004](/docs/adr/ADR-004-config-driven-dag-factory/).*
