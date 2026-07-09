---
layout: post
title: "Guardrails Before Copilots: Why Our Text-to-SQL Bot Can Only See the Gold Layer"
date: 2026-07-09
categories: [Architecture]
tags: [genai, rag, text-to-sql, governance, llm, guardrails, finops]
description: >-
  Connecting an LLM to a production warehouse is a governance decision disguised
  as a feature. How a whitelist SQL guard, forced limits, and deterministic
  lineage turn a text-to-SQL copilot from a liability into an auditable interface.
---

# Guardrails Before Copilots: Why Our Text-to-SQL Bot Can Only See the Gold Layer

Every data leader is being asked the same question this year: *"Can our analysts just ask the warehouse in plain English?"* The technical answer is trivially yes. The governance answer is where careers are made or ended.

This post walks through the guardrail architecture behind the [Warehouse Copilot](/projects/genai-rag-warehouse/), formalized in [ADR-005](/docs/adr/ADR-005-gold-whitelist-sql-guard/) and [ADR-006](/docs/adr/ADR-006-deterministic-lineage-over-llm-generation/): why the copilot is physically restricted to the Gold layer, why every query passes static analysis before execution, and why lineage questions never touch the LLM at all.

---

## The Real Risk Is Not Hallucination — It's Blast Radius

The common objection to text-to-SQL is "the model might get the answer wrong." That's real, but it's not the expensive failure. The expensive failures are structural:

- **A prompt injection that executes DML/DDL.** If the model can emit `DROP` or `DELETE`, someone will eventually make it do so.
- **A rogue query.** One hallucinated Cartesian join against a 10TB estate can burn a month of compute budget in an afternoon.
- **PII exposure.** An unconstrained copilot with warehouse-wide access can be talked into reading raw Bronze-layer data the analyst was never authorized to see.

None of these are model-quality problems. They are **access-design problems**, and no amount of prompt engineering fixes access design. Policies that live in the prompt are requests; policies that live in the infrastructure are guarantees.

## The Decision: Enforcement, Not Politeness

The architecture rejects open-ended SQL generation in favor of layered, mechanical enforcement:

1. **Gold-layer whitelisting.** The copilot's schema context contains only the Gold serving layer — governed Kimball star schemas with ratified definitions. Bronze and Silver do not exist as far as the model knows. Even a perfect prompt injection can only retrieve data that was already approved for consumption.
2. **Static SQL guard.** Every generated query is parsed with `sqlglot` before it reaches the warehouse. Anything other than a read-only `SELECT` is killed before compilation — not flagged, not logged-and-allowed: killed.
3. **Forced constraints.** Every query gets a mandatory `LIMIT` and runs in a read-only session. Scan caps and resource monitors abort anything that exceeds a safe-scan threshold before the bill accrues.
4. **No black box.** The generated SQL is always shown to the analyst before execution. Trust in the answer comes from being able to inspect the question.

And for lineage — *"where does this revenue number come from?"* — the copilot doesn't generate an answer at all. It traverses the dbt manifest deterministically and reports the actual dependency graph. Some questions deserve a database lookup, not a probability distribution.

## The Trade-off We Accepted on Purpose

This design produces **false refusals**. Roughly 5% of the time, the copilot declines a request a human reviewer would have approved. We accepted that explicitly: a copilot that occasionally says "I can't do that" costs a few minutes of analyst patience. A copilot that executes one destructive query costs the platform's credibility — and credibility is the only currency a governed data platform has.

## The Replicable Pattern

If you're evaluating a warehouse copilot, the checklist is short:

- Restrict the model's *visible* schema to your governed serving layer — not with instructions, with context construction.
- Parse and validate every query statically before execution. Read-only or dead.
- Enforce limits and scan caps in the session, not in the prompt.
- Route deterministic questions (lineage, definitions, ownership) to deterministic systems.
- Log every prompt and every generated query with a hash. When the audit committee asks, you want a forensic trail, not a shrug.

The uncomfortable question for any team shipping "AI over the warehouse" this quarter: **if your copilot were prompt-injected tomorrow, what is the worst query it could physically execute?** If the answer is "we're not sure," the copilot isn't the next feature to build. The guardrails are.

---

*The full implementation — SQL guard, evals, and lineage traversal — is reviewable at [github.com/dchavezf/genai-rag-warehouse](https://github.com/dchavezf/genai-rag-warehouse), with the decision records in [ADR-005](/docs/adr/ADR-005-gold-whitelist-sql-guard/) and [ADR-006](/docs/adr/ADR-006-deterministic-lineage-over-llm-generation/).*
