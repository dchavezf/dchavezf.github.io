# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**dchavezf.github.io** is a Jekyll-based portfolio site showcasing enterprise data architecture work. The site demonstrates three interconnected architectural projects for a fictional enterprise (MeridianTrade Group), each with documented decision records (ADRs), detailed methodology, and production-grade code examples.

**Live site:** https://dchavezf.github.io/

### Core Purpose
- Portfolio of enterprise data platform work (dbt + Snowflake/BigQuery, Airflow + Terraform, GenAI + RAG)
- Architectural decision documentation (MADR format ADRs in `/docs/adr/`)
- Thought leadership blog and technical library
- Resume and professional narrative

## Tech Stack

- **Static site generator:** Jekyll (jekyll-theme-chirpy)
- **Deployment:** GitHub Pages (automated via `.github/workflows/jekyll.yml`)
- **Content format:** Markdown + YAML frontmatter
- **Styling:** Custom SCSS overrides in `assets/css/jekyll-theme-chirpy.scss`
- **Plugins:** jekyll-seo-tag, jekyll-sitemap, jekyll-archives, jekyll-paginate
- **Ruby:** Managed via Gemfile (jekyll-theme-chirpy gem)

## Development Workflow

### Build and Preview Locally

```bash
bundle install                    # Install Jekyll and dependencies
bundle exec jekyll serve          # Start local server (http://localhost:4000)
bundle exec jekyll build          # Build static site to _site/
```

### Content Structure

```
├── index.html                     # Homepage (hero + post feed)
├── _tabs/
│   ├── portfolio.md               # Portfolio tab
│   ├── library.md                 # Library tab
│   └── about.md                   # About tab
├── _data/
│   ├── contact.yml                # Social links
│   └── share.yml                  # Share buttons
├── _plugins/
│   └── posts-lastmod-hook.rb      # Auto last-modified dates
├── projects/
│   ├── dbt-o2c-mdm.md             # Project 1: O2C & MDM transformation
│   ├── airflow-iac-pipeline.md    # Project 2: Multi-source ingestion + IaC
│   └── genai-rag-warehouse.md     # Project 3: GenAI warehouse copilot
├── docs/adr/                      # Architecture Decision Records
│   ├── ADR-001-elt-over-etl.md
│   ├── ADR-002-medallion-kimball-over-data-vault.md
│   ├── ADR-003-mdm-as-governed-seed.md
│   ├── ADR-004-config-driven-dag-factory.md
│   ├── ADR-005-gold-whitelist-sql-guard.md
│   ├── ADR-006-deterministic-lineage-over-llm-generation.md
│   └── README.md                  # ADR index
├── _posts/                        # Blog articles (Chirpy conventions)
├── assets/css/
│   └── jekyll-theme-chirpy.scss   # Theme customizations
├── _config.yml                    # Jekyll/Chirpy configuration
├── AGENTS.md                      # General agent guidance
└── voice_and_tone.md              # Voice guide for public-facing content
```

### Mermaid Diagrams

Chirpy supports Mermaid diagrams natively. Use fenced code blocks:

    ```mermaid
    graph LR
      A[Source] -->|ELT| B[Warehouse]
      B -->|dbt| C[Analytics]
    ```

## Key Architectural Concepts

### ADR-Driven Documentation

All major technical choices are documented as Architecture Decision Records (ADRs) in MADR format. ADRs form the backbone of the portfolio narrative:
- Each ADR has **Status**, **Context**, **Decision**, **Consequences** (positive/negative)
- ADRs are linked to the projects they govern
- New content additions should reference relevant ADRs or propose new ones

### Three-Project Coherence

The portfolio demonstrates depth across three disciplines, all grounded in a single fictional enterprise context (MeridianTrade Group, a global supply chain company):

1. **Project 1** — Transformation & Modeling (dbt Core, SQL, Jinja) — demonstrates ELT + medallion architecture
2. **Project 2** — Orchestration & Infrastructure as Code (Airflow, Terraform, Python) — demonstrates DAG factory + config-driven design
3. **Project 3** — GenAI over Governed Data (Python, Claude API, vector search) — demonstrates controlled LLM output using dbt artifacts + deterministic lineage

Each project page answers five explicit questions:
- What's the business problem?
- What tools were chosen and why?
- What methodology was applied?
- Where does the code live (GitHub links)?
- What was the quantified outcome?

## Deployment

Deployment is fully automated:
- **Trigger:** Push to `main` branch
- **CI/CD:** `.github/workflows/jekyll.yml` (GitHub Actions)
- **Process:** Jekyll build → GitHub Pages upload
- **Site URL:** `https://dchavezf.github.io` (automatic)

No manual deploy steps needed. Changes merged to `main` are live within minutes.

## File Update Patterns

### Creating or Editing Public Content
- Before writing homepage, portfolio, library, about, post, resume-adjacent, or other public-facing copy, read `voice_and_tone.md`.
- Apply that guide's voice, tone, preferred language, and quality bar to the content.
- If `voice_and_tone.md` changes, keep this file and `AGENTS.md` synchronized.

### Adding a Blog Post
1. Create new `.md` file in `_posts/` with format: `YYYY-MM-DD-title.md`
2. Include Chirpy frontmatter:
   ```yaml
   ---
   layout: post
   title: "Your Title"
   date: 2026-07-08
   categories: [Category]
   tags: [tag1, tag2]
   description: "Short description"
   ---
   ```
3. Push to `main` → auto-deployed

### Adding an ADR
1. Use the template in `docs/adr/template.md`
2. Name: `docs/adr/ADR-NNN-kebab-case-title.md`
3. Update `docs/adr/README.md` index
4. Link from relevant project pages

### Updating a Project Page
- Edit `/projects/*.md` directly
- Ensure all five questions are answered
- Update adjacent ADR references if rationale changes

## Notes

- **No build artifacts in repo:** `./_site/` is generated by CI and not committed
- **Theme is Chirpy:** Use Chirpy's tab, category, and tag conventions for navigation. Do not add custom header navigation.
- **Post frontmatter:** All posts must include `categories` and `tags` arrays in addition to `layout`, `title`, and `date`.
- **Writing for a technical audience:** Assume readers are senior engineers; focus on trade-offs and constraints, not basics
- **All links should be root-relative** (e.g., `/projects/dbt-o2c-mdm/`) for portability
- **SEO and sitemap:** Automatically generated by jekyll-seo-tag and jekyll-sitemap plugins
