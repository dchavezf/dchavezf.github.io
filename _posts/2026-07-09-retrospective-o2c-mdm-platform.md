---
layout: post
title: "Retrospective: Building the O2C & MDM Platform"
date: 2026-07-09
categories: [Architecture]
tags: [retrospective, dbt, mdm, delivery, lessons-learned]
description: >-
  What I'd do differently on the Enterprise O2C & MDM platform, now that v1.0.0
  is tagged — honest trade-offs the spec doesn't show, and what the next
  iteration should fix.
---

# Retrospective: Building the O2C & MDM Platform

Every project page in this portfolio leads with what worked. That's the right way to pitch a platform; it's the wrong way to prove judgment. This is the honest version — what I'd change now that [v1.0.0](https://github.com/dchavezf/marts_order_cycle/releases/tag/v1.0.0) of the [O2C & MDM platform](/projects/dbt-o2c-mdm/) is tagged and the [PRD](/docs/prd/project1-o2c-mdm/) is closed against a real backlog.

---

## What I'd keep without changing

**The MDM-as-governed-seed decision ([ADR-003](/docs/adr/ADR-003-mdm-as-governed-seed/)) held up.** Deterministic, steward-owned identity resolution was the right call for a first version, and writing down *why not* probabilistic matching up front meant nobody re-litigated it mid-build. The stewardship queue pattern — surface ambiguity instead of resolving it silently — is the single idea from this project I'd reuse on any future MDM work without hesitation.

**Writing the PRD after the ADRs, not before, was backwards — and I noticed it mid-build.** The ADRs came first because the architectural shape was obvious from the business case. The PRD came later, formalizing user stories that the code had already implicitly satisfied. It worked here because the domain was well-understood going in. On a genuinely ambiguous problem, doing it in that order would have meant discovering scope gaps *after* committing to an architecture — the PRD's non-goals section exists partly because writing it retroactively made two unscoped assumptions visible that hadn't been examined when the ADRs were drafted.

## What I'd change next time

**The backlog was reconstructed, not lived.** The GitHub issues and milestones for this release were written to document the delivery sequence after the fact, mapped onto work that already existed. That's honest as a *specification* of what shipped, but it's not the same signal as a backlog that shaped decisions in real time — no story got re-prioritized mid-sprint, no estimate was wrong and had to be corrected. If I were doing this again as a genuinely agile delivery, I'd open the milestone before writing any model, and let the backlog absorb the actual discovery that happens once you start.

**The 40% compute-reduction figure needs a harder edge.** It's directly modeled on a real engagement, and the incremental-merge mechanism that produces it is real and testable. But `docs/finops.md` documents the *mechanism*, not a benchmark run against representative data volumes on a live warehouse. The honest gap: I have strong architectural reasoning for the number and no independent measurement in this repository. Next iteration, that's a CI job that runs both strategies against a sized synthetic dataset and publishes the delta — not a documented expectation.

**Inferred-member handling is under-tested for the failure mode that matters most.** The test suite confirms inferred members always have a backing order. It does not yet simulate the actual production scenario the design exists for — an order landing before its customer-master sync completes, under real timing, across a batch boundary. The unit test proves the logic is internally consistent; it doesn't prove the self-healing behavior survives a real race condition. That's the next test I'd write, not the next feature I'd build.

**I underestimated how much of "done" is documentation debt.** Closing this out meant writing the test strategy and runbook *after* the models were stable, which meant reconstructing intent from code instead of writing docs alongside decisions. The runbook is accurate, but writing it earlier would have surfaced the escalation-path question — who owns a definition dispute versus a data-quality bug — before it was an edge case in a document instead of a design constraint on the stewardship queue.

## What this changes for the next iteration

If there's a v1.1, the priority order is: (1) a real finops benchmark job, not documentation of the mechanism, (2) a race-condition test for inferred members, (3) probabilistic matching as an explicit Phase 2 spike — scoped, not assumed — against the stewardship queue's actual backlog volume, to see if deterministic-only resolution is still sufficient at scale.

None of this changes the v1.0.0 assessment. It changes what "senior" means here: not that the first version was flawless, but that the gaps are named, scoped, and sequenced instead of discovered by whoever inherits this platform next.

---

*Full delivery trace — business case, PRD, ADRs, backlog, code, release, runbook — is on the [Delivery Lifecycle](/docs/delivery-lifecycle/) page.*
