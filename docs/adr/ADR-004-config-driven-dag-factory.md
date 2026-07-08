---
layout: page
title: "ADR-004: Config-Driven DAG Factory over Hand-Written DAGs"
permalink: /docs/adr/ADR-004-config-driven-dag-factory/
---

# ADR-004: Config-Driven DAG Factory over Hand-Written DAGs

> **Status:** Accepted
> **Date:** 2026-07-08
> **Decision Makers:** Daniel Chávez Flores
> **Project:** [Project 2 — Multi-Source Ingestion Platform with IaC](/projects/airflow-iac-pipeline/)


### **The Boardroom Hook**
Every time we onboard a new regional ERP, we are currently performing "maintenance as a ritual" rather than engineering as a discipline. If a simple update to a retry policy requires a developer to manually touch 20 separate files, we have built a **structural liability**, not a scalable platform. At MeridianTrade Group, "manual labor" in orchestration is just a polite term for **unquantified operational risk**. We are not here to build 20 bespoke pipelines; we are here to build a single **Data Factory** that operates with mechanical consistency across 20 countries.

### **The Real Problem**
The status quo of **hand-written DAGs** is a recipe for **configuration drift**. When each region has its own independent Python file, small discrepancies in schedules, SLAs, or connection logic inevitably creep in. This creates an environment where "Mexico works but Colombia doesn't," and nobody can explain why without an hour of forensic code comparison. This is the **"Hero Dependency"** trap: we rely on individual engineers to remember to apply a global fix across 20 islands of code. It is an unscalable model that turns onboarding into a multi-day sprint and makes global auditing a nightmare.

### **The ADR (The Decision)**
We have officially decided to move away from individual DAG files in favor of a **Config-driven DAG Factory Pattern**. 

**The Decision Drivers:**
*   **Rejecting Replication Toil:** We are automating the "toil" of pipeline creation. Pipeline logic—including our **Shift-Left Testing** gates and PagerDuty callbacks—is written once in a Python module and applied to all regions via YAML.
*   **Separation of Philosophy and Mechanics:** We are separating the *what* (YAML configuration) from the *how* (Python factory logic). This allows us to treat infrastructure as plain static data.
*   **Consistency by Construction:** By using a factory to generate common patterns, we ensure that every region follows the exact same architectural shape: `extract → validate_contract → load → freshness_check`. No exceptions, no drift.

### **The Replicable Engine**
We have transformed our ingestion layer into a **Parameter-Driven Engine**:

1.  **Onboarding Velocity:** Adding a new country is now a **YAML entry**, not a code commit. We have compressed the onboarding time from a full sprint to **under 60 minutes**. 
2.  **Centralized Logic Maintenance:** A change to our global **SLA thresholds** or retry policies is applied in a single location and instantly inherited by all 20 regional DAGs during the Airflow parse cycle.
3.  **Auditable Metadata:** Each region’s YAML config serves as a declarative "contract" specifying its connection reference, entities, and watermark columns. This is the **Single Source of Truth** for our ingestion footprint.
4.  **Unit-Tested Governance:** The factory itself is protected by comprehensive unit tests, ensuring that the "engine" that builds our pipelines is functionally perfect before it ever generates a production DAG.

### **The Closing**
We have stopped writing code for every country and started building an **infrastructure of certainty**.

One final question for the platform team: **Are you satisfied funding a team of "ticket-takers" who manually copy-paste code for 20 regions, or are you ready to invest in an architecture that scales as fast as the business does?**
## References

- [Astronomer: Dynamically Generating DAGs](https://www.astronomer.io/guides/dynamically-generating-dags/)
- [Project 2 — Methodology](/projects/airflow-iac-pipeline/#3--what-is-the-methodology)
