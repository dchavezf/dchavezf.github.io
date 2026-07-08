---
layout: page
title: "ADR-006: Deterministic Lineage Traversal over LLM Generation"
permalink: /docs/adr/ADR-006-deterministic-lineage-over-llm-generation/
---

# ADR-006: Deterministic Lineage Traversal over LLM Generation

> **Status:** Accepted
> **Date:** 2026-07-08
> **Decision Makers:** Daniel Chávez Flores
> **Project:** [Project 3 — Warehouse Copilot: GenAI over Governed Data](/projects/genai-rag-warehouse/)


### **The Boardroom Hook**
Asking a Large Language Model (LLM) to "guess" the topology of your data pipeline is not an innovation; it is a **fiduciary Russian roulette**. When a developer asks what will break if a source schema changes, a hallucinated dependency is not a "minor AI quirk"—it is a **trigger for a silent chain reaction of financial errors**. At MeridianTrade Group, we do not manage impact analysis based on "probabilistic guesses." We manage it based on **mathematical certainty**, because a Single Source of Truth (SSOT) that relies on hallucinations is simply a machine for manufacturing **unquantified corporate risk**.

### **The Real Problem**
The status quo of "AI-washing" in data governance suggests that LLMs can magically understand complex Directed Acyclic Graphs (DAGs) through raw text or prompt injection. This is a **structural liability**. In a 10TB environment with 20 regional ERPs, the dependency web is too dense for a "Black Box" to navigate. 

If an LLM ignores a downstream link in a lead-to-cash calculation, the resulting **silent data corruption** could stay undetected for weeks, leading to misstated quarterly earnings. Furthermore, using an LLM to perform structural reasoning is an **architectural sin of inefficiency**: we would be burning expensive tokens to have a non-deterministic model simulate a calculation that a basic graph algorithm can solve for free in milliseconds.

### **The ADR (The Decision)**
We have officially **rejected LLM-inferred lineage**. We are implementing a **Deterministic Graph Traversal Engine** based strictly on the dbt `manifest.json`.

**The Decision Drivers:**
*   **The manifest.json as the "Physical Truth":** We use the dbt-generated manifest as the absolute authority. It is the geometric encoding of every `ref()` and `source()` relationship in our factory.
*   **Mathematical Algorithms over Stochastic Guesses:** We utilize standard **Breadth-First Search (BFS) and Depth-First Search (DFS)** algorithms to walk the graph. The path from Source to Gold KPI is calculated with **100% mathematical precision**.
*   **LLM as a Narrative Interface Only:** The LLM is surgically restricted to a **narrative role**. It receives the raw, deterministic path provided by the algorithm and translates it into a natural language explanation for business analysts. It is a narrator, not a navigator.
*   **Rejecting GIGO 2.0:** We are preventing "Garbage In, Garbage Out" at the structural layer. By separating the **calculation of the path** from the **narration of the result**, we ensure that even if the AI alucinates a word, it cannot alucinate a dependency.

### **The Replicable Engine**
We have engineered **certainty** into our impact analysis workflow:

1.  **100% Precise Impact Analysis:** Every "what-if" scenario regarding schema changes or pipeline halts is now backed by a verifiable graph audit trail. Zero dependencies are "missed".
2.  **FinOps Optimization:** By moving structural reasoning from the LLM to a local Python parser, we have reduced **token consumption by 90%** for lineage-related queries. We don't pay for the AI to "think" about math.
3.  **Raw Path Visibility:** The system always displays the raw technical route (e.g., `stg_mx_orders -> int_orders -> fct_revenue`) alongside the AI's narration, providing the **Chain of Custody** required for SOX compliance.
4.  **Accepted Maintenance Cost:** We explicitly accept the technical cost of maintaining the manifest parser. In the "C-suite Whisperer" framework, the cost of maintenance is an investment; the cost of uncertainty is a loss.

### **The Closing**
We have stopped treating our metadata as a "creative writing" prompt for an AI. We have returned to the **engineering of certainty**.

One final question for the Data Governance Committee: **Are you willing to bet your personal liability on an AI that "feels" like the data is connected, or are you ready to invest in the math that proves it?**.

## References

- [dbt manifest.json schema](https://docs.getdbt.com/reference/artifacts/manifest-json)
- [Project 3 — Methodology](/projects/genai-rag-warehouse/#3--what-is-the-methodology)
- [ADR-005](/docs/adr/ADR-005-gold-whitelist-sql-guard/) — Related decision on SQL safety
