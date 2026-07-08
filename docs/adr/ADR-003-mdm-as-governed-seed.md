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

### **The Boardroom Hook**
If this board is asked to certify our global credit exposure, and our systems cannot distinguish between "Client 1001" in Mexico and "Client 1001" in Colombia, we are not just facing a technical glitch—we are committing a **fiduciary breach**. When an algorithm has an "85% confidence threshold" to merge two legal entities, it is not a statistical success; it is a **financial disaster waiting to be audited**. At MeridianTrade Group, an "error rate" in identity resolution is simply another name for **unquantified risk**.

### **The Real Problem**
We inherited a **"Regional Data Chaos"** across 20 ERP islands where identifiers were never intended to coexist. Mexico, Colombia, and Brazil each operated their own independent numbering logic, leading to massive **ID collisions**. Because these systems were isolated, the same ID could refer to a high-volume wholesaler in one country and a small retail shop in another. 

The previous strategy of "manual reconciliation" or "probabilistic matching" created a **"Definition Gap"** that made consolidated reporting a hallucination. Finance could not calculate true counterparty risk because our data was "technically correct but organizationally meaningless". We were paying for expensive "Black Box" ML models that produced results no controller could explain to a SOX auditor.

### **The ADR (The Decision)**
We have officially **rejected probabilistic Machine Learning (fuzzy matching)** for identity resolution. Instead, we are implementing a **Deterministic MDM strategy** using **Governed dbt Seeds**.

**The Decision Drivers:**
*   **Radical Explainability:** Unlike ML models, a dbt seed mapping is 100% auditable. Every consolidated identity is traceable line-by-line to a human-governed file in our Git repository.
*   **Separation of Duties:** We have removed Engineering from the "Truth" business. Business **Data Stewards** now own the mapping (the dbt seed); Engineering owns the **Data Factory** that executes it.
*   **Compliance by Design:** By using deterministic mapping, we satisfy the **SOX reproducibility requirement**. We can recreate the exact state of any identity at any millisecond in the past, a feat impossible with non-deterministic probabilistic models.

### **The Replicable Engine**
We have replaced the "Hero Model" of manual cleanup with an **Automated Stewardship Pipeline**:

1.  **Deterministic GUIDs:** We generate **Deterministic Surrogate Keys** (SHA-256) by concatenating the regional ID with a tenant identifier, ensuring global uniqueness across 20 entities without sequence bottlenecks.
2.  **Stewardship Queue:** Any record that does not find a match in our governed dbt seed is automatically assigned a **Surrogate Identification Number** and routed to a dedicated **Stewardship Queue** in Snowflake for human review.
3.  **Circuit Breaker Integration:** Using **Great Expectations**, our pipeline halts if the percentage of "orphan records" exceeds business thresholds, preventing "silent data loss" from reaching the CFO’s dashboard.
4.  **Audit-Ready Lineage:** dbt automatically generates the **DAG** showing exactly how a regional ERP record was resolved into a Master Identity, providing the "Chain of Custody" required by external forensic auditors.

### **The Closing**
We have stopped guessing who our customers are. We have moved from "confidence scores" to **mathematical certainty**.

One final question for the audit committee: **Are you prepared to sign off on a balance sheet where the "Single Source of Truth" is an algorithm you can't explain to a judge, or are you ready to invest in an architecture that guarantees the truth?**## References

- [Project 1 — MDM architecture](/projects/dbt-o2c-mdm/#3--what-is-the-methodology)
- [ADR-002](/docs/adr/ADR-002-medallion-kimball-over-data-vault/) — Related decision on modeling methodology
