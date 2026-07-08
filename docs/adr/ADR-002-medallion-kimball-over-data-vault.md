---
layout: page
title: "ADR-002: Medallion + Kimball Hybrid over Data Vault 2.0"
permalink: /docs/adr/ADR-002-medallion-kimball-over-data-vault/
---

# ADR-002: Medallion + Kimball Hybrid over Data Vault 2.0

> **Status:** Accepted
> **Date:** 2026-07-08
> **Decision Makers:** Daniel Chávez Flores
> **Project:** [Project 1 — Enterprise O2C & MDM Resolution Platform](/projects/dbt-o2c-mdm/)

**ADR-004: Standardizing on Medallion Architecture with Kimball Dimensional Modeling**

### **The Boardroom Hook**
We have 500 business analysts across 20 regions who are currently "analytic nomads," wandering through a desert of fragmented data. When 500 people cannot agree on a single KPI because they are trapped in the complexity of 20 different ERP schemas, we aren't just facing a technical bottleneck—we are suffering from **organizational latency**. Every hour a VP spends debating a number is an hour spent not moving the needle on revenue. We are choosing a model that prioritizes **time-to-insight** and **fiduciary certainty** over technical abstraction.

### **The Real Problem**
The status quo is a **Definition Gap** of catastrophic proportions. Each of our 20 regional ERPs—from Mexico to Colombia—operates as a "Galapagos Island" of data. In the past, trying to centralize this meant building bespoke, fragile bridges that required "hero engineers" to maintain. Our BI users were forced to learn the "tribal knowledge" of each local system just to run a basic report. This created a **structural liability**: we had no single version of the truth, and the cost of being "wrong" was a complete loss of trust from the CFO’s office. 

### **The ADR (The Decision)**
We are adopting a **Medallion Architecture (Bronze/Silver/Gold)** combined with **Kimball Dimensional Modeling** at the Gold layer. While Data Vault 2.0 was evaluated for its agility in absorbing schema churn, we are rejecting its full implementation in Phase 1 to avoid a "Complexity Tax" that our 500 BI users cannot afford to pay.

**The Decision Drivers:**
*   **BI-First Consumption:** We are optimized for the end-user. Kimball Star Schemas (Facts and Dimensions) are the **universal language of business**. Every tool in our stack, from Power BI to Tableau, is engineered to run at sub-second speeds on this structure.
*   **Onboarding Velocity:** We are eliminating the dependency on "niche heroes." A standard Star Schema allows a new analyst to be productive in hours, not weeks, because the mental model of facts and dimensions is globally understood.
*   **Pragmatic Compliance:** We are using the Medallion layers to enforce a **mechanical chain of custody**. Bronze preserves raw evidence; Silver provides the integration "shock absorber"; Gold serves the ratified truth.
*   **Strategic Deferral:** Data Vault 2.0 remains our "break glass" option. If our ERP schemas move from stable SQL Servers to volatile, rapidly shifting structures, we can pivot Silver to a Vault model without disrupting the Gold layer's Kimball interface.

### **The Replicable Engine**
We have transformed our data pipeline into a **Productized Data Factory**:

1.  **Automated Lineage:** By using **dbt**, we generate an automatic DAG. An auditor can now trace a Q4 revenue figure from a Gold dashboard back to the raw Bronze evidence in under ten minutes.
2.  **SCD Type 2 Historization:** We use **dbt Snapshots** to capture history across all 20 systems. This is no longer a manual coding exercise; it is a mechanical property of our architecture that ensures we never lose "temporal truth".
3.  **Deterministic MDM:** Identity resolution is handled via a **governed seed** [ADR-003]. This removes the "black box" of probabilistic matching, ensuring that our CFO can audit every customer consolidation line-by-line.
4.  **Elastic FinOps:** By materializing Gold marts as tables in Snowflake, we leverage **columnar pruning**, ensuring that 500 users querying the same data don't blow the compute budget.

### **The Closing**
We have stopped building "bespoke reports" and started building an **infrastructure of certainty**.

One final question for the regional controllers: **Are you ready to stop being the "gatekeepers of the spreadsheet" and become the "stewards of a global factory," or would you prefer to keep wasting 15% of your annual budget on reconciliations that shouldn't exist?**

## References

- Kimball Group: [The Data Warehouse Toolkit](https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/dimensional-modeling-techniques/)
- [Databricks Medallion Architecture](https://www.databricks.com/glossary/medallion-architecture)
- [Project 1 — Methodology](/projects/dbt-o2c-mdm/#3--what-is-the-methodology)
