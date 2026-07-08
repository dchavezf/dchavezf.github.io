---
layout: page
title: "ADR-010: Institutional Knowledge as Governed Code"
permalink: /docs/adr/ADR-010-institutional-knowledge-as-governed-code/
---

# ADR-010: Institutional Knowledge as Governed Code

> **Status:** Accepted
> **Date:** 2026-07-08
> **Decision Makers:** Daniel Chavez Flores
> **Project:** [Project 2 - Multi-Source Ingestion Platform with IaC](/projects/airflow-iac-pipeline/)


### **The Boardroom Hook**
The most dangerous data risk was not a failed cloud migration. It was undocumented-but-legitimate financial logic living in the heads and personal scripts of legacy DBAs. Roberto's shadow adjustments represented millions in monthly financial corrections outside the governed pipeline. Firing the person would have removed the evidence, not the risk.

This ADR documents the decision to treat institutional knowledge as source material for governed code.

### **The Real Problem**
The existing approach depended on people who knew how to keep the business correct despite the official system. Their interventions were commercially necessary but procedurally invisible. That made them both valuable and dangerous.

The constraints shaping the decision were:

*   Business risk or stakeholder pressure: manual adjustments materially affected reported financial results.
*   Data, platform, or delivery scale: undocumented logic existed across multiple entities and years of close cycles.
*   Operational failure modes: removing legacy experts would destroy context required to explain parity gaps.
*   Governance, auditability, cost, or maintainability concerns: shadow SQL Agent jobs and personal scripts had no code review, lineage, or approval workflow.
*   Why the existing approach does not survive the next stage of delivery: a cloud migration that ignores tribal logic produces technically clean but financially wrong outputs.

### **The ADR (The Decision)**
We are choosing **codification and role conversion for legacy experts** over **punitive removal or passive knowledge extraction** because **the architecture needs their domain knowledge to become auditable controls**.

**The Decision Drivers:**
*   **Knowledge retention as compliance protection:** The business need was to preserve legitimate adjustments; the technical mechanism was translating them into Great Expectations contracts, dbt models, and approved Airflow tasks.
*   **Ownership over extraction:** The trade-off was investing in upskilling and shared authorship instead of treating DBAs as temporary documentation sources.
*   **Avoiding hidden shadow systems:** This decision deliberately avoids allowing personal scripts to remain outside Git, runbooks, and governance workflows.
*   **Creating cloud governance capacity:** The decision creates an operating capability where former legacy gatekeepers become maintainers of the rules the platform enforces.

### **The Replicable Engine**
The decision becomes repeatable by making knowledge migration a formal workstream.

1.  **Shadow intervention audit:** Review historical manual adjustments, SQL Agent jobs, and local scripts over a defined period before cutover.
2.  **Contract co-authoring:** Pair legacy experts with engineers to convert discovered logic into named, tested, version-controlled controls.
3.  **Measurable outcome:** Reduce unexplained reconciliation gaps and convert undocumented financial adjustments into auditable pipeline behavior.
4.  **Accepted trade-off:** Delivery must allocate time for interviews, audits, and upskilling that do not look like traditional engineering throughput.

### **The Closing**
The leadership implication is that resistance was not merely a change-management problem. It was unmodeled architecture. By converting institutional memory into governed code, the organization reduced dependency on individual memory while honoring the expertise that kept the business running.

**What decision does this force leadership to make next?** Which legacy experts should become accountable owners of cloud governance controls?

## References

- [Project 2 - Methodology](/projects/airflow-iac-pipeline/#3--what-is-the-methodology)
- [ADR-009](/docs/adr/ADR-009-version-controlled-data-factory/) - Factory mechanism for codified controls
- [ADR-004](/docs/adr/ADR-004-config-driven-dag-factory/) - Config-driven orchestration surface for governed code
