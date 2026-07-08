---
layout: page
title: "ADR-007: Semantic Layer Ratification Before Migration"
permalink: /docs/adr/ADR-007-semantic-layer-ratification/
---

# ADR-007: Semantic Layer Ratification Before Migration

> **Status:** Accepted
> **Date:** 2026-07-08
> **Decision Makers:** Daniel Chavez Flores
> **Project:** [Project 1 - Enterprise O2C & MDM Resolution Platform](/projects/dbt-o2c-mdm/)


### **The Boardroom Hook**
The migration could not begin as an infrastructure project because the business did not yet have one legally defensible definition of revenue. Mexico, Costa Rica, and the U.S. corporate team each produced a correct number under their own local rules, but the board received three incompatible truths. Moving that conflict into a faster cloud platform would have accelerated executive distrust, not solved it.

This ADR documents the decision to treat semantic agreement as an architectural precondition, not as a governance workshop scheduled after engineering had already started.

### **The Real Problem**
The current state was structurally insufficient because the enterprise had 20 regional legal entities, each with local accounting rules, ERP constraints, fiscal calendars, and manual interpretation layers. The reporting platform did not simply contain bad data. It contained locally valid definitions that could not be consolidated without a signed enterprise definition.

The constraints shaping the decision were:

*   Business risk or stakeholder pressure: the CEO and CFO needed one number they could sign and defend.
*   Data, platform, or delivery scale: 10 terabytes of regional financial data across 20 entities would magnify any unresolved definition conflict.
*   Operational failure modes: local teams would continue producing shadow Excel and Access models whenever the central platform failed to represent their regulatory reality.
*   Governance, auditability, cost, or maintainability concerns: SOX evidence depends on knowing which definition the pipeline is enforcing.
*   Why the existing approach does not survive the next stage of delivery: cloud migration without semantic ratification would produce faster, cleaner, more expensive ambiguity.

### **The ADR (The Decision)**
We are choosing **executive-ratified semantic definitions before migration work** over **coding transformations against unresolved regional definitions** because **the platform can enforce consensus but cannot manufacture it**.

**The Decision Drivers:**
*   **Executive trust before automation:** The business consequence was board-level paralysis; the technical mechanism was a Global Data Definition Agreement used as the binding contract for downstream transformation logic.
*   **Auditability requires named definitions:** The trade-off was delaying infrastructure work to secure written agreement, in exchange for a traceable control surface auditors could inspect.
*   **Avoiding accelerated ambiguity:** This decision deliberately avoids turning Snowflake, dbt, and Airflow into a faster machine for producing contradictory revenue metrics.
*   **Creating a semantic control plane:** The decision creates an operating capability where each metric in the pipeline can be traced to a ratified business definition rather than to an engineer's interpretation.

### **The Replicable Engine**
The decision becomes repeatable by making definition ratification the first gate in the migration methodology.

1.  **Global Data Definition Agreement:** Every enterprise metric that crosses legal entities must have an executive-approved definition before transformation code is written.
2.  **Definition-to-code traceability:** dbt models, tests, and documentation should reference the approved definition they implement, improving auditability and reducing interpretation drift.
3.  **Measurable outcome:** Consolidated reporting should produce one defensible number for executive review, reducing reconciliation cycles and shadow reporting.
4.  **Accepted trade-off:** Delivery starts slower because leadership must resolve political disagreement before engineering can hide it behind automation.

### **The Closing**
The leadership implication is direct: the first architecture decision was not about tooling. It was about forcing the organization to decide what truth the tooling was allowed to enforce. That created the foundation for trust, audit defense, and every downstream technical choice.

**What decision does this force leadership to make next?** Which business definitions must be owned by executives permanently rather than delegated to project teams?

## References

- [Project 1 - Methodology](/projects/dbt-o2c-mdm/#3--what-is-the-methodology)
- [ADR-001](/docs/adr/ADR-001-elt-over-etl/) - ELT implementation that depends on agreed definitions
- [ADR-002](/docs/adr/ADR-002-medallion-kimball-over-data-vault/) - Modeling approach for ratified business definitions
