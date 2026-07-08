# Daniel Chávez Flores — Data Platform Portfolio

**Live site: [dchavezf.github.io](https://dchavezf.github.io/)**

Enterprise Data Architect & AI Platform Engineer — 22 years in data, the last decade architecting enterprise platforms (10TB / 20-country Snowflake migration, 99.9% pipeline SLA on GCP/BigQuery, GenAI/RAG platforms in production).

This portfolio demonstrates, in reviewable documents and code, three architectural disciplines on one coherent fictional enterprise (MeridianTrade Group):

| # | Project | Core Stack |
|---|---------|------------|
| 1 | [Enterprise O2C & MDM Resolution Platform](https://dchavezf.github.io/projects/dbt-o2c-mdm.html) | dbt Core · Snowflake/BigQuery · SQL · Jinja |
| 2 | [Multi-Source Ingestion Platform with IaC](https://dchavezf.github.io/projects/airflow-iac-pipeline.html) | Airflow · Terraform · Python · GitHub Actions |
| 3 | [Warehouse Copilot — GenAI over Governed Data](https://dchavezf.github.io/projects/genai-rag-warehouse.html) | Python · Claude API · dbt artifacts · vector search |

Each project page answers five questions explicitly: the business problem, the tools, the methodology, where the code lives, and the quantified outcome.

## Architecture Decision Records

Every significant technical choice is documented as a formal ADR in [`/docs/adr/`](docs/adr/). These records show *why* each decision was made, what alternatives were considered, and what trade-offs were accepted.

## Repository Structure

```
├── index.md                    # Landing page (portfolio home)
├── projects/                   # Project detail pages
│   ├── dbt-o2c-mdm.md          # Project 1: Transformation & Modeling
│   ├── airflow-iac-pipeline.md # Project 2: Ingestion & Infrastructure
│   └── genai-rag-warehouse.md  # Project 3: GenAI Warehouse Copilot
├── docs/adr/                   # Architecture Decision Records
├── _posts/                     # Blog: thought leadership articles
├── _includes/head.html         # Custom head (Mermaid.js integration)
├── assets/css/style.scss       # Custom theme overrides
├── .github/workflows/          # CI/CD (Jekyll build & deploy)
└── _config.yml                 # Jekyll configuration
```

## Contact

- LinkedIn: [mx.linkedin.com/in/dchavezf](https://mx.linkedin.com/in/dchavezf)
- Email: dchavezf@gmail.com

## License

Content and code in this repository are released under the [MIT License](LICENSE).
