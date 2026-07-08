---
layout: page
title: "ADR-008: Decoupled Compute and Storage Platform"
permalink: /docs/adr/ADR-008-decoupled-compute-storage-platform/
---

# ADR-008: Decoupled Compute and Storage Platform

> **Status:** Accepted
> **Date:** 2026-07-08
> **Decision Makers:** Daniel Chavez Flores
> **Project:** [Project 1 - Enterprise O2C & MDM Resolution Platform](/projects/dbt-o2c-mdm/)


### **The Boardroom Hook**
The eight-hour ETL window was a financial constraint disguised as a database problem. Month-end close took eleven days because 20 legal entities were forced through a serialized SQL Server and SSIS chain. The business consequence was trapped finance capacity, delayed reporting, and a CFO who could not get timely numbers during active close pressure.

This ADR documents why the platform had to change the physics of processing rather than merely replace servers.

### **The Real Problem**
The legacy architecture coupled compute and storage in a way that forced serialization. Concurrent regional loads created page-level lock contention, so the system depended on a sequential domino chain. One regional delay elongated the global critical path.

The constraints shaping the decision were:

*   Business risk or stakeholder pressure: finance needed sub-two-hour processing without interrupting the quarter-end close.
*   Data, platform, or delivery scale: 10 terabytes and 20 legal entities exceeded the useful operating range of the shared SQL Server estate.
*   Operational failure modes: a single regional network or schema issue delayed every downstream entity.
*   Governance, auditability, cost, or maintainability concerns: the platform needed isolated compute, controlled cost, and reproducible environments.
*   Why the existing approach does not survive the next stage of delivery: adding hardware would not remove forced serialization or regional coupling.

### **The ADR (The Decision)**
We are choosing **GCP for ingestion and Snowflake for the analytical engine** over **continued SQL Server scaling, AWS Redshift, Azure Synapse, or Spark-first Databricks** because **Snowflake's decoupled compute-storage model allowed parallel entity processing with SQL-native adoption and stronger FinOps controls**.

**The Decision Drivers:**
*   **Processing time as business liquidity:** The business need was faster financial close; the technical mechanism was isolated Snowflake virtual warehouses running entity loads in parallel.
*   **Portability and governance over cloud familiarity:** The trade-off was choosing against deeper AWS familiarity in LATAM because Snowflake's multi-cloud behavior reduced hyperscaler lock-in risk.
*   **Avoiding expertise bottlenecks:** This decision deliberately avoids making Spark tuning a critical path skill for regional teams that already operated in SQL.
*   **Creating controlled parallelism:** The decision creates an operating capability where each entity can process independently without blocking the global batch.

### **The Replicable Engine**
The decision becomes repeatable by making workload physics explicit during platform selection.

1.  **Entity-isolated warehouses:** Provision independent compute per legal entity or workload class so regional processing can run concurrently without lock contention.
2.  **Auto-suspend and cache governance:** Use Snowflake virtual warehouse suspension, result-cache-safe query patterns, and zero-copy clones to improve delivery speed and cost visibility.
3.  **Measurable outcome:** Compress the legacy eight-hour ETL window to under two hours while reducing infrastructure cost through idle compute elimination.
4.  **Accepted trade-off:** The organization accepts Snowflake platform dependency and must govern query patterns to preserve the FinOps model.

### **The Closing**
This decision converted a fragile processing queue into a parallel operating model. The leadership value was not vendor modernization; it was restoring financial reporting speed without sacrificing auditability or forcing the business to wait behind the slowest region.

**What decision does this force leadership to make next?** Which workloads deserve isolated compute budgets, and who owns the cost discipline for each one?

## References

- [Project 1 - Methodology](/projects/dbt-o2c-mdm/#3--what-is-the-methodology)
- [ADR-001](/docs/adr/ADR-001-elt-over-etl/) - ELT decision implemented on elastic warehouse compute
- [ADR-007](/docs/adr/ADR-007-semantic-layer-ratification/) - Semantic prerequisite for the platform migration
