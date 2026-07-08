---
layout: page
title: "ADR-011: Irreversible Strangler Cutover"
permalink: /docs/adr/ADR-011-irreversible-strangler-cutover/
---

# ADR-011: Irreversible Strangler Cutover

> **Status:** Accepted
> **Date:** 2026-07-08
> **Decision Makers:** Daniel Chavez Flores
> **Project:** [Project 1 - Enterprise O2C & MDM Resolution Platform](/projects/dbt-o2c-mdm/)


### **The Boardroom Hook**
The CTO's request to keep 20 legacy SQL Servers alive for six months sounded prudent. In practice, it would have reintroduced the exact definition gap the transformation was designed to eliminate. During financial close, a fallback system does not stay neutral. It becomes a competing source of truth.

This ADR documents the decision to use a Strangler Fig migration pattern, validate parity, then decommission the legacy estate irreversibly.

### **The Real Problem**
The legacy system could not remain available indefinitely without undermining trust in the new system. Parallel availability creates choice under pressure, and choice under pressure lets teams select the number that protects their local incentives.

The constraints shaping the decision were:

*   Business risk or stakeholder pressure: leadership wanted safety without recreating ambiguity.
*   Data, platform, or delivery scale: 20 entities required blast-radius isolation before final cutover.
*   Operational failure modes: extended dual-run would encourage regional controllers to fall back to whichever system produced preferred results.
*   Governance, auditability, cost, or maintainability concerns: maintaining both estates preserved licensing, hardware, support, and audit confusion.
*   Why the existing approach does not survive the next stage of delivery: a migration is not complete while the old system can still contradict the new source of truth.

### **The ADR (The Decision)**
We are choosing **incremental Strangler Fig migration followed by irreversible decommission** over **big-bang cutover or six-month parallel production** because **the enterprise needed one operational source of truth after parity was proven**.

**The Decision Drivers:**
*   **Trust requires finality:** The business need was a single signed number; the technical mechanism was shadow deployment, CDC synchronization, entity-by-entity traffic routing, and 100% decimal parity gates.
*   **Safety through evidence, not nostalgia:** The trade-off was refusing the familiar legacy safety net after proving the new system through real close-cycle parity.
*   **Avoiding competing truth:** This decision deliberately avoids a dual-production state where the old and new platforms both remain socially legitimate.
*   **Creating permanent cost and governance clarity:** The decision creates an operating capability where ownership, incident response, and FinOps accountability converge on the new platform only.

### **The Replicable Engine**
The decision becomes repeatable by making cutover a validated sequence rather than a weekend gamble.

1.  **Shadow plus parity gate:** Run legacy and new systems through real financial close cycles and require exact decimal parity before traffic moves.
2.  **Entity-by-entity routing:** Shift consumers incrementally, verify stability, and retire matching legacy jobs as dependencies disappear.
3.  **Measurable outcome:** Reduce cutover to a routing change while eliminating legacy licensing, hardware, and operational overhead.
4.  **Accepted trade-off:** The organization accepts that rollback becomes a designed incident response process, not an always-on legacy platform.

### **The Closing**
The leadership implication is that the organization could not buy trust by keeping two truths alive. Irreversible decommission converted migration success into operating reality, clarified cost, and forced the business to stand behind the architecture it had validated.

**What decision does this force leadership to make next?** What formal evidence is sufficient to retire a legacy system instead of preserving it as an expensive illusion of safety?

## References

- [Project 1 - Methodology](/projects/dbt-o2c-mdm/#3--what-is-the-methodology)
- [ADR-007](/docs/adr/ADR-007-semantic-layer-ratification/) - Single source of truth requirement
- [ADR-009](/docs/adr/ADR-009-version-controlled-data-factory/) - Recovery controls supporting decommission
