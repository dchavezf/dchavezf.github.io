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


### **The Boardroom Hook**
Connecting a Large Language Model (LLM) to your production data warehouse without rigid structural constraints is not "innovation"—it is **corporate suicide**. If your data governance is broken, GenAI is simply a machine for manufacturing **GIGO 2.0 (Garbage In, Garbage Out)** at a faster and significantly more expensive rate. We are not here to provide a magic wand that hallucinations can wave at our balance sheet; we are here to build a **governed interface** that converts natural language into audited financial insight without risking the firm’s liquidity or operational trust.

### **The Real Problem**
The status quo of "Open SQL Generation" is a **fiduciary liability**. Generative AI hallucinations aren't just technical errors; they are potential **attack vectors**. A successful **prompt injection** that executes unauthorized DML (Data Manipulation Language) or DDL (Data Definition Language) commands could delete historical audit trails or exfiltrate raw PII (Personally Identifiable Information) from our Bronze layer. 

Furthermore, an unconstrained LLM will eventually generate a "rogue query"—a massive table scan or a **Cartesian join**—that can burn through a monthly compute budget in a single afternoon. Without a physical "chokepoint," the blast radius of a single AI hallucination is the entire enterprise footprint.

### **The ADR (The Decision)**
We have officially **rejected open-ended SQL generation**. We are implementing a **Multi-Layer Security Guardrail** architecture for our Warehouse Copilot.

**The Decision Drivers:**
*   **Gold-Layer Whitelisting:** The Copilot is surgically restricted to the **Gold Serving Layer (Kimball Star Schemas)**. It is physically prohibited from seeing or querying the Raw (Bronze) or Integration (Silver) layers.
*   **Static SQL Guard (sqlglot):** We are deploying **static analysis** via `sqlglot`. Every generated query is parsed and validated before it hits the Snowflake compiler. If the parser detects anything other than a read-only **SELECT** statement, the execution is killed instantly.
*   **Forced Constraints:** Every query is programmatically injected with a **mandatory LIMIT** and a **read-only session parameter**. We are moving from a policy of "asking nicely" to an infrastructure of **mathematical enforcement**.
*   **Radical Transparency:** The "Black Box" is dead. The generated SQL is always visible to the analyst for verification before final execution.

### **The Replicable Engine**
We have engineered **certainty** into the AI-human loop:

1.  **Blast Radius Isolation:** By restricting access to the Gold layer, even a "perfect" prompt injection can only retrieve data the analyst was already authorized to see.
2.  **Scan Caps and FinOps:** We use **Snowflake Resource Monitors** and hard-coded scan caps. If the LLM generates a query that exceeds our "Safe Scan" threshold, the system aborts the request before the bill accrues.
3.  **Accepted False Refusals:** We explicitly accept **False Refusals** as a necessary trade-off. We would rather the Copilot say "I cannot perform that action" 5% of the time than allow a single destructive query to pass through.
4.  **Audit-Ready Logging:** Every prompt, every hallucination attempt, and every successful query is logged with a **deterministic hash**, providing a forensic trail for the Audit Committee.

### **The Closing**
We have stopped treatinig AI as a toy and started treating it as a **regulated industrial actuator**. 

One final question for the Steering Committee: **Are you prepared to explain to the board why a "hallucinated" Cartesian join cost the firm $50,000 in compute credits, or are you ready to invest in the guardrails that make that failure physically impossible?**.
## References

- [sqlglot — SQL parser and transpiler](https://github.com/tobymao/sqlglot)
- [Project 3 — Methodology](/projects/genai-rag-warehouse/#3--what-is-the-methodology)
- [ADR-006](/docs/adr/ADR-006-deterministic-lineage-over-llm-generation/) — Related decision on lineage handling
