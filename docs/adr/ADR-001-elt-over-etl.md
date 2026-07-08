---
layout: page
title: "ADR-001: ELT (Transform In-Warehouse) over ETL"
permalink: /docs/adr/ADR-001-elt-over-etl/
---

# ADR-001: ELT (Transform In-Warehouse) over ETL

> **Status:** Accepted
> **Date:** 2026-07-08
> **Decision Makers:** Daniel Chávez Flores
> **Project:** [Project 1 — Enterprise O2C & MDM Resolution Platform](/projects/dbt-o2c-mdm/)


### **The Boardroom Hook**
Three regional VPs walked into the boardroom last month with three different revenue numbers for the same fiscal quarter. This is not a technical glitch; it is a **structural liability**. When MeridianTrade Group cannot provide a single, defensible answer to the board, the system is no longer an asset—it is a machine for manufacturing **financial uncertainty**. An architecture choice without a cost rationale is just an opinion, and right now, our legacy "regional chaos" is costing us the board’s trust.

### **The Real Problem**
We inherited a **fragmented data archipelago**: 10 terabytes of historical data trapped across 20 regional ERP islands. Our previous ETL (Extract, Transform, Load) model was built for the era of Windows Server 2003. It relied on a **sequential domino chain** of SSIS packages and custom Spark clusters that required niche "hero developers" to maintain. 

The bottleneck was physical: we were pulling massive datasets across the network into the RAM of a single integration server. This created an **8-hour processing window** that was fundamentally unscalable. If the Spark cluster imploded at 3 AM, we were operationally blind until a specialist could manually unpick the transaction locks. We were paying for **idle silicon** 24/7, even though our critical work happened in a fraction of that time.

### **The ADR (The Decision)**
We are officially transitioning from traditional ETL to an **In-Warehouse ELT (Extract, Load, Transform)** model utilizing **dbt Core** and **Snowflake**. 

**The Decision Drivers:**
*   **SQL as the Universal Language:** We are choosing a SQL-first stack because our central team dominates SQL, not distributed systems programming. By using **dbt**, we treat data transformation like software engineering—version-controlled, testable, and peer-reviewed.
*   **ELT Paradigm Shift:** Instead of transforming data mid-flight in expensive, manual clusters, we load raw data directly into Snowflake and leverage its **massively parallel compute engine** to do the heavy lifting.
*   **Rejecting Spark Clusters:** We are eliminating the overhead of provisioning and tuning Spark infrastructure. Snowflake’s **compute-storage decoupling** allows us to instantiate elastic "Virtual Warehouses" that spin up for the transformation and **auto-suspend** the second they are done.

### **The Replicable Engine**
This is no longer a bespoke project; it is a **Productized Data Factory**. We have engineered certainty into the pipeline through several key mechanisms:

1.  **Incremental Materialization:** Using a `merge` strategy and Jinja macros, we now process only the **50GB daily delta** instead of rebuilding the 10TB base every night. This surgically compresses our ETL window from **8 hours to under 2 hours**.
2.  **Shift-Left Testing:** We’ve embedded **Great Expectations** as automated **circuit breakers**. If a regional ERP emits malformed data, the pipeline halts surgically at the ingestion boundary, preventing "poison data" from ever reaching a C-suite dashboard.
3.  **Automated Documentation & Lineage:** dbt automatically generates a browsable **DAG (Directed Acyclic Graph)** and data catalog. Auditors can now trace any executive KPI back to its raw source without needing a "hero" to explain the code.
4.  **FinOps Certainty:** By replacing fixed-cost legacy servers with Snowflake’s per-second billing and **Zero-Copy Cloning**, we have realized a **40% reduction in annual TCO**.

### **The Closing**
We have transformed our DBAs from defensive gatekeepers into **Cloud Data Guardians**. The instruments have stopped lying.

One final question for the leadership: **Are you satisfied funding an infrastructure that requires a hero to survive the night, or are you ready to invest in a factory that guarantees the truth by 7 AM?**

## References

- [dbt Core documentation](https://docs.getdbt.com/)
- [Project 1 — Methodology](/projects/dbt-o2c-mdm/#3--what-is-the-methodology)
