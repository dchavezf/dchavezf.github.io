---
layout: page
title: "ADR-009: Version-Controlled Data Factory"
permalink: /docs/adr/ADR-009-version-controlled-data-factory/
---

# ADR-009: Version-Controlled Data Factory

> **Status:** Accepted
> **Date:** 2026-07-08
> **Decision Makers:** Daniel Chavez Flores
> **Project:** [Project 2 - Multi-Source Ingestion Platform with IaC](/projects/airflow-iac-pipeline/)


### **The Boardroom Hook**
The legacy pipeline depended on heroics: undocumented SSIS packages, manual DBA interventions, and failure investigation measured in weeks. That operating model could not support a CFO asking for a signed number this quarter or an auditor asking who changed a calculation and when.

This ADR documents the decision to turn delivery into a data factory where orchestration, transformation, and data quality rules are version-controlled and machine-enforced.

### **The Real Problem**
The current delivery model was structurally insufficient because time-based scheduling assumed upstream success, SSIS hid transformation logic, and data quality defects surfaced after they had already contaminated downstream reports.

The constraints shaping the decision were:

*   Business risk or stakeholder pressure: financial close needed predictable recovery and visible failure ownership.
*   Data, platform, or delivery scale: 20 regional pipelines required causal dependency management, not calendar-based sequencing.
*   Operational failure modes: silent anomalies and undocumented stored procedures produced long forensic investigations.
*   Governance, auditability, cost, or maintainability concerns: SOX evidence required run history, code lineage, and reproducible transformation logic.
*   Why the existing approach does not survive the next stage of delivery: a cloud platform with opaque logic would still fail executive trust.

### **The ADR (The Decision)**
We are choosing **Apache Airflow for orchestration, dbt for version-controlled SQL transformations, and Great Expectations as ingestion-boundary circuit breakers** over **time-based scheduling, opaque SSIS packages, and post-transformation testing alone** because **the factory must prevent bad data from entering the immutable layer and make every calculation traceable in Git**.

**The Decision Drivers:**
*   **Recovery time as executive confidence:** The business need was fast incident recovery; the technical mechanism was task-level Airflow failure isolation with explicit alerts.
*   **Auditability over developer elegance:** The trade-off was accepting Airflow operational complexity because its metadata database and task records provide stronger compliance evidence than thinner orchestration logs.
*   **Avoiding post-facto quality discovery:** This decision deliberately avoids letting corrupt source data enter the governed Bronze and Silver layers, where correction would require expensive replay and audit explanation.
*   **Creating repeatable delivery:** The decision creates an operating capability where a new engagement can reuse orchestration patterns, dbt model conventions, and validation contracts.

### **The Replicable Engine**
The decision becomes repeatable by encoding the factory as code and controls.

1.  **DAG plus contract pattern:** Every entity pipeline has Airflow dependencies, Great Expectations checks at the Bronze boundary, and dbt models downstream.
2.  **Git as the audit surface:** Every transformation rule and data contract is reviewed, versioned, and linked to a commit history.
3.  **Measurable outcome:** Reduce MTTR from multi-week forensic investigation to targeted recovery measured in minutes.
4.  **Accepted trade-off:** The team accepts orchestration overhead and the need for named owners who maintain data contracts as business rules change.

### **The Closing**
The leadership-level implication is that the platform stopped relying on memory and started relying on evidence. The factory model turned data delivery into a repeatable control system that could be inspected, repaired, and scaled without summoning the original author.

**What decision does this force leadership to make next?** Who owns each data contract after go-live, and how is that ownership funded?

## References

- [Project 2 - Methodology](/projects/airflow-iac-pipeline/#3--what-is-the-methodology)
- [ADR-004](/docs/adr/ADR-004-config-driven-dag-factory/) - DAG generation pattern for the factory
- [ADR-001](/docs/adr/ADR-001-elt-over-etl/) - Warehouse transformation pattern protected by ingestion controls
