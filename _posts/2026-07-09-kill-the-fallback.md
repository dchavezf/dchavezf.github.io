---
layout: post
title: "Kill the Fallback: Why We Decommissioned 20 Legacy Servers on Purpose"
date: 2026-07-09
categories: [Architecture]
tags: [migration, strangler-fig, snowflake, cutover, governance, data-platform]
description: >-
  Keeping the legacy estate alive "just in case" sounds prudent — until financial
  close, when the fallback becomes a competing source of truth. The Strangler Fig
  cutover pattern: shadow runs, parity gates, and irreversible decommission.
---

# Kill the Fallback: Why We Decommissioned 20 Legacy Servers on Purpose

Near the end of every large migration, someone senior makes the same reasonable-sounding request: *"Keep the old system running for six months, just in case."* It sounds like risk management. In a financial data platform, it's usually the opposite — it re-creates the exact problem the migration was funded to eliminate.

This post walks through the cutover strategy behind the [O2C transformation platform](/projects/dbt-o2c-mdm/), formalized in [ADR-011](/docs/adr/ADR-011-irreversible-strangler-cutover/): incremental Strangler Fig migration, evidence-based parity gates, and then — deliberately — irreversible decommission of the legacy estate.

---

## A Fallback System Does Not Stay Neutral

The premise behind "keep it running just in case" is that the legacy system will sit quietly as an insurance policy. It won't. During financial close, a parallel system becomes a **competing source of truth**, and choice under pressure lets every team select the number that protects their local incentives.

If the new platform says regional revenue is down 4% and the legacy report says it's flat, which one lands in the board deck? The migration was justified by a definition gap — three executives presenting three revenue numbers in the same room. Six months of dual production doesn't insure against that failure; it **institutionalizes** it, now with two licensing bills, two support rotations, and an audit trail split across two estates.

A migration is not complete while the old system can still contradict the new one. That's the constraint everything else follows from.

## The Decision: Strangle, Prove, Then Burn the Boats

Rejecting long-term parallel production doesn't mean a big-bang weekend cutover — that trades one kind of risk for a worse one. The pattern is a sequence:

1. **Shadow deployment.** The new platform runs full production workloads alongside legacy through *real financial close cycles* — not synthetic tests, actual month-end under actual stakeholder pressure, with CDC keeping both estates synchronized.
2. **Parity gates.** Cutover eligibility is a measurable standard: 100% decimal parity on ratified metrics across close cycles. Not "close enough," not "explainable variances." Exact, or no cutover.
3. **Entity-by-entity routing.** Consumers move one legal entity at a time. Each shift is small, observable, and individually reversible while it's in flight — blast-radius isolation for the transition itself.
4. **Irreversible decommission.** Once parity is proven and traffic has moved, the matching legacy jobs are retired and the servers are shut down. Rollback stops being a standing system and becomes a *designed incident-response process*, like any other disaster-recovery scenario.

The nuance that makes this defensible to a steering committee: **safety comes from the evidence, not from the fallback.** By the time decommission happens, the new platform has already survived multiple real close cycles at full parity. Keeping the legacy estate after that point doesn't add safety — it adds cost, ambiguity, and a socially legitimate escape hatch from the new definitions.

## The Trade-off We Accepted

This is the most organizationally aggressive decision in the portfolio, and it should be named as such. The organization gives up its comfort blanket: if a catastrophic defect surfaces post-decommission, recovery runs through backups and an incident process, not through flipping a switch back to the old servers. That is a real cost, accepted in exchange for something a dual estate can never provide — **one signed number, with one owner, on one platform**, plus the permanent elimination of legacy licensing, hardware, and support overhead.

## The Replicable Pattern

For any team planning a platform migration, the questions that matter:

- What is your **formal parity evidence** — which metrics, what tolerance, how many real business cycles?
- Is your cutover **incremental and observable**, or a weekend gamble?
- What is the **explicit date and criteria** for legacy decommission — or is "temporary" parallel production quietly becoming permanent?
- Who is accountable when the two systems disagree during the overlap? If the answer is "whoever's number looks better," the overlap is already hurting you.

The uncomfortable question [ADR-011](/docs/adr/ADR-011-irreversible-strangler-cutover/) forces on leadership: **what evidence would be sufficient to retire your legacy system — or are you paying to preserve an expensive illusion of safety?**

---

*The transformation platform this cutover protects — Medallion + Kimball modeling, governed MDM, SCD2 history — is reviewable at [github.com/dchavezf/marts_order_cycle](https://github.com/dchavezf/marts_order_cycle), with the full business context in the [MeridianTrade business case](/projects/transformation-business-case/).*
