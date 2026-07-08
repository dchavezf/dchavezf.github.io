# ADR-006: Deterministic Lineage Traversal over LLM Generation

> **Status:** Accepted
> **Date:** 2026-07-08
> **Decision Makers:** Daniel Chávez Flores
> **Project:** [Project 3 — Warehouse Copilot: GenAI over Governed Data](../../projects/genai-rag-warehouse.md)

## Context

Warehouse Copilot must answer lineage questions — "What feeds `dim_customer`?", "What breaks if I change `stg_erp_region_a__clientes`?" — which are critical for impact analysis and trust building. dbt's `manifest.json` contains a complete directed acyclic graph (DAG) of model dependencies.

Two approaches were evaluated:

- **LLM-generated lineage answers**: Pass the manifest or schema context to the LLM and ask it to reason about dependencies. Simpler prompt design but introduces hallucination risk on graph structure.
- **Deterministic graph traversal with LLM narration**: Parse the manifest DAG into an in-memory graph. Answer lineage questions by traversing the graph programmatically. Use the LLM only to narrate the result in natural language.

## Decision

Adopt **deterministic graph traversal** for all lineage questions. The manifest DAG is parsed at index build time into a queryable graph structure. Upstream and downstream queries are resolved by BFS/DFS traversal. The LLM receives the traversal result and narrates it — it never invents graph edges.

## Consequences

### Positive

- **100% accuracy on lineage**: Graph traversal is deterministic — there are no hallucinated dependencies or missed edges. This is verifiable in CI with a benchmark suite.
- **No token cost for graph reasoning**: The LLM doesn't need to process the entire manifest to answer "what feeds X?" — only the traversal result is passed as context.
- **Consistent with the governance posture**: Lineage is the backbone of data trust. Making it non-generative eliminates a class of errors that would undermine the platform's credibility.

### Negative

- **Additional code to maintain**: A graph parser and traversal module must be built and tested, adding engineering surface area. Mitigated because the manifest JSON schema is stable and well-documented by dbt.
- **LLM narration can still misinterpret the result**: The natural-language explanation might rephrase the traversal inaccurately. Mitigated by always including the raw lineage path alongside the narrative.

### Neutral

- The same graph structure can support future features: impact analysis alerts, automated documentation of cross-project dependencies, and visual lineage rendering.

## References

- [dbt manifest.json schema](https://docs.getdbt.com/reference/artifacts/manifest-json)
- [Project 3 — Methodology](../../projects/genai-rag-warehouse.md#3--what-is-the-methodology)
- [ADR-005](ADR-005-gold-whitelist-sql-guard.md) — Related decision on SQL safety
