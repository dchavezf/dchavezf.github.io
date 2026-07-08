# Chirpy Theme Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrate dchavezf.github.io from Jekyll minima to Chirpy theme with sidebar navigation, dark/light mode, search, TOC, categories/tags, and a hero + feed homepage.

**Architecture:** Replace the minima gem with jekyll-theme-chirpy gem. Adopt the chirpy-starter structure (`_tabs/`, `_data/`, `_plugins/`, `index.html`). Preserve all existing content (project pages, blog posts, ADRs, agent guidance) and adapt frontmatter to Chirpy conventions. Override Chirpy's SCSS with the site's existing design tokens.

**Tech Stack:** Jekyll, jekyll-theme-chirpy (~> 7.6), SCSS, GitHub Pages, GitHub Actions, Markdown frontmatter.

## Global Constraints

- Theme gem version: `~> 7.6`
- Ruby version in CI: `3.4`
- Preserve all existing content — project pages, blog posts, ADRs, voice_and_tone.md, AGENTS.md, CLAUDE.md
- Preserve design tokens: teal `#0f9b8e`, accent `#16213e`, Inter font, JetBrains Mono font, custom radii/shadows
- Categories for all content: Portfolio, DataOps, Architecture, GenAI, Methodology
- Homepage: hero section + Chirpy post feed
- Sidebar tabs: Home, Portfolio, Library, About (plus Chirpy auto-generated Categories, Tags, Archives)
- GitHub Pages deployment via GitHub Actions (not "Deploy from branch")
- Mermaid diagrams work natively in Chirpy — no custom `_includes/head.html` needed
- Post permalink format: `/posts/:title/` (Chirpy default, do not change)
- All internal links must use root-relative paths (e.g., `/projects/dbt-o2c-mdm/`)

---

## Task 1: Chirpy Scaffold

**Files:**
- Modify: `Gemfile`
- Modify: `_config.yml`
- Create: `_data/contact.yml`
- Create: `_data/share.yml`
- Create: `_plugins/posts-lastmod-hook.rb`
- Modify: `.gitignore`

- [ ] **Step 1: Replace Gemfile**

Replace the entire `Gemfile` with:

```ruby
# frozen_string_literal: true

source "https://rubygems.org"

gem "jekyll-theme-chirpy", "~> 7.6"

gem "html-proofer", "~> 5.0", group: :test

platforms :windows, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
end

gem "wdm", "~> 0.2.0", :platforms => [:windows]
```

- [ ] **Step 2: Replace _config.yml**

Replace the entire `_config.yml` with:

```yaml
theme: jekyll-theme-chirpy

lang: en
timezone: America/Mexico_City

title: DanielChavez.mx
tagline: Data & Analytics Engineer
description: >-
  Enterprise Data Architect & AI Platform Engineer. Working evidence of
  Fortune 500-scale data migration, modern ELT design, and applied GenAI
  on governed data — business case first, spec second, code third.

url: "https://dchavezf.github.io"

github:
  username: dchavezf

social:
  name: Daniel Chávez Flores
  email: dchavezf@gmail.com
  links:
    - https://mx.linkedin.com/in/dchavezf
    - https://github.com/dchavezf

theme_mode:

toc: true

pwa:
  enabled: true
  cache:
    enabled: true

paginate: 10

baseurl: ""

kramdown:
  footnote_backlink: "&#8617;&#xfe0e;"
  syntax_highlighter: rouge
  syntax_highlighter_opts:
    css_class: highlight
    span:
      line_numbers: false
    block:
      line_numbers: true
      start_line: 1

collections:
  tabs:
    output: true
    sort_by: order

defaults:
  - scope:
      path: ""
      type: posts
    values:
      layout: post
      comments: true
      toc: true
      permalink: /posts/:title/
  - scope:
      path: _drafts
    values:
      comments: false
  - scope:
      path: ""
      type: tabs
    values:
      layout: page
      permalink: /:title/

sass:
  style: compressed

compress_html:
  clippings: all
  comments: all
  endings: all
  profile: false
  blanklines: false
  ignore:
    envs: [development]

exclude:
  - "*.gem"
  - "*.gemspec"
  - docs
  - tools
  - README.md
  - LICENSE
  - purgecss.js
  - "*.config.js"
  - "package*.json"

jekyll-archives:
  enabled: [categories, tags]
  layouts:
    category: category
    tag: tag
  permalinks:
    tag: /tags/:name/
    category: /categories/:name/
```

- [ ] **Step 3: Create _data/contact.yml**

Create `_data/contact.yml` with:

```yaml
- type: linkedin
  icon: "fab fa-linkedin"
  url: "https://mx.linkedin.com/in/dchavezf"

- type: github
  icon: "fab fa-github"

- type: email
  icon: "fas fa-envelope"
  noblank: true

- type: rss
  icon: "fas fa-rss"
  noblank: true
```

- [ ] **Step 4: Create _data/share.yml**

Create `_data/share.yml` with:

```yaml
platforms:
  - type: Twitter
    icon: "fa-brands fa-square-x-twitter"
    link: "https://twitter.com/intent/tweet?text=TITLE&url=URL"

  - type: Facebook
    icon: "fab fa-facebook-square"
    link: "https://www.facebook.com/sharer/sharer.php?title=TITLE&u=URL"

  - type: Linkedin
    icon: "fab fa-linkedin"
    link: "https://www.linkedin.com/feed/?shareActive=true&shareUrl=URL"
```

- [ ] **Step 5: Create _plugins/posts-lastmod-hook.rb**

Create `_plugins/posts-lastmod-hook.rb` with:

```ruby
#!/usr/bin/env ruby
#
# Check for changed posts

Jekyll::Hooks.register :posts, :post_init do |post|

  commit_num = `git rev-list --count HEAD "#{ post.path }"`

  if commit_num.to_i > 1
    lastmod_date = `git log -1 --pretty="%ad" --date=iso "#{ post.path }"`
    post.data['last_modified_at'] = lastmod_date
  end

end
```

- [ ] **Step 6: Update .gitignore**

Replace the existing `.gitignore` (or create if missing) with:

```
# Bundler cache
.bundle
vendor
Gemfile.lock

# Jekyll cache
.jekyll-cache
.jekyll-metadata
_site

# RubyGems
*.gem

# NPM dependencies
node_modules
package-lock.json

# IDE configurations
.idea
.vscode/*
!.vscode/settings.json
!.vscode/extensions.json
!.vscode/tasks.json

# Misc
_sass/vendors
assets/js/dist
*~
.DS_Store
Thumbs.db
```

- [ ] **Step 7: Commit**

```bash
git add Gemfile _config.yml _data/ _plugins/ .gitignore
git commit -m "feat: scaffold Chirpy theme base"
```

---

## Task 2: Create Navigation Tabs

**Files:**
- Create: `_tabs/portfolio.md`
- Create: `_tabs/library.md`
- Create: `_tabs/about.md`
- Create: `_tabs/categories.md`
- Create: `_tabs/tags.md`
- Create: `_tabs/archives.md`

- [ ] **Step 1: Create _tabs/portfolio.md**

Create `_tabs/portfolio.md` with the full portfolio content. The frontmatter is:

```yaml
---
layout: page
title: Portfolio
icon: fas fa-briefcase
order: 1
---
```

Then copy the body content from the current `portfolio/index.md` (lines 8-138), preserving the MeridianTrade narrative, Mermaid diagram, evidence tables, project links, ADR table, and contact section. Remove the frontmatter block from the old file (lines 1-6) since the new frontmatter above replaces it.

Update all internal links in the body:
- `../projects/dbt-o2c-mdm.html` → `/projects/dbt-o2c-mdm/`
- `../projects/airflow-iac-pipeline.html` → `/projects/airflow-iac-pipeline/`
- `../projects/genai-rag-warehouse.html` → `/projects/genai-rag-warehouse/`
- `../docs/adr/` → `/docs/adr/`
- `../docs/adr/ADR-001-elt-over-etl.md` → `/docs/adr/ADR-001-elt-over-etl/`
- Apply the same pattern for all ADR links (replace `../docs/adr/` with `/docs/adr/` and remove `.md` extension)

- [ ] **Step 2: Create _tabs/library.md**

Create `_tabs/library.md` with:

```yaml
---
layout: page
title: Library
icon: fas fa-book-open
order: 2
---

Articles, architecture decision case studies, and reading lists reflecting a philosophy of continuous engineering.

Browse by [category](/categories/) or [tag](/tags/).

{% for post in site.posts %}
- **[{{ post.title }}]({{ post.url | relative_url }})** — {{ post.date | date: "%b %-d, %Y" }}
  {% if post.description %}{{ post.description }}{% endif %}
{% endfor %}
```

- [ ] **Step 3: Create _tabs/about.md**

Create `_tabs/about.md` with the frontmatter:

```yaml
---
layout: page
title: About
icon: fas fa-user
order: 3
---
```

Then copy the body content from the current `about/index.md` (lines 7-57), preserving the full professional narrative, manifesto, strategic stack, and contact section. Remove the old frontmatter block (lines 1-5).

- [ ] **Step 4: Create _tabs/categories.md**

Create `_tabs/categories.md` with:

```yaml
---
layout: categories
icon: fas fa-stream
order: 4
---
```

- [ ] **Step 5: Create _tabs/tags.md**

Create `_tabs/tags.md` with:

```yaml
---
layout: tags
icon: fas fa-tags
order: 5
---
```

- [ ] **Step 6: Create _tabs/archives.md**

Create `_tabs/archives.md` with:

```yaml
---
layout: archives
icon: fas fa-archive
order: 6
---
```

- [ ] **Step 7: Commit**

```bash
git add _tabs/
git commit -m "feat: add Chirpy navigation tabs"
```

---

## Task 3: Create Homepage

**Files:**
- Create: `index.html` (replaces `index.md`)

- [ ] **Step 1: Create index.html**

Create `index.html` with:

```html
---
layout: home
---

<div class="hero-section">
  <div class="hero-tagline">Chaos in, signal out</div>
  <h1 class="hero-title">DanielChavez<span class="accent">.mx</span></h1>
  <p class="hero-description">
    <strong>Data &amp; Analytics Engineer</strong> — designing scalable platforms,
    optimizing enterprise pipelines, and operationalizing continuous engineering.
  </p>
  <div class="hero-actions">
    <a href="/portfolio/" class="btn-primary">View the portfolio</a>
    <a href="mailto:dchavezf@gmail.com" class="btn-secondary">Get in touch</a>
  </div>
</div>

<div class="expertise-grid">
  <div class="expertise-card">
    <div class="expertise-icon"><i class="fas fa-building"></i></div>
    <h3>Enterprise Architecture</h3>
    <p>10TB+ Snowflake migrations, multi-region identity resolution, governed data platforms for Fortune 500 companies.</p>
  </div>
  <div class="expertise-card">
    <div class="expertise-icon"><i class="fas fa-cogs"></i></div>
    <h3>DataOps &amp; Infrastructure</h3>
    <p>Airflow orchestration, Terraform IaC, CI/CD pipelines, and 99.9% SLA delivery across business domains.</p>
  </div>
  <div class="expertise-card">
    <div class="expertise-icon"><i class="fas fa-brain"></i></div>
    <h3>AI Platforms</h3>
    <p>RAG architectures grounded in warehouse governance, governed text-to-SQL, LLM evaluation and guardrails.</p>
  </div>
</div>
```

- [ ] **Step 2: Commit**

```bash
git add index.html
git commit -m "feat: add Chirpy homepage with hero section"
```

---

## Task 4: SCSS Overrides

**Files:**
- Create: `assets/css/jekyll-theme-chirpy.scss`

- [ ] **Step 1: Create the SCSS override file**

Create `assets/css/jekyll-theme-chirpy.scss` with:

```scss
---
---

@import 'jekyll-theme-chirpy';

@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;500&display=swap');

:root {
  --color-primary: #0f9b8e;
  --color-primary-dark: #0c8277;
  --color-accent: #16213e;
  --color-bg: #ffffff;
  --color-bg-subtle: #f4f5f7;
  --color-bg-card: #ffffff;
  --color-text: #16213e;
  --color-text-muted: #5b6473;
  --color-border: #e4e7ec;
  --color-border-light: #eceef2;
  --font-sans: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  --font-mono: 'JetBrains Mono', 'Fira Code', monospace;
  --radius-sm: 6px;
  --radius-md: 10px;
  --radius-lg: 16px;
  --shadow-sm: 0 1px 3px rgba(0,0,0,0.06);
  --shadow-md: 0 4px 12px rgba(0,0,0,0.08);
  --shadow-lg: 0 8px 30px rgba(0,0,0,0.12);
  --transition: 0.25s cubic-bezier(0.4, 0, 0.2, 1);
}

body {
  font-family: var(--font-sans);
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

code, pre, .highlighter-rouge {
  font-family: var(--font-mono);
}

.hero-section {
  padding: 3rem 0 2rem;
  border-bottom: 1px solid var(--color-border-light);
  margin-bottom: 2rem;
}

.hero-tagline {
  font-family: var(--font-mono);
  font-size: 12px;
  letter-spacing: 0.22em;
  text-transform: uppercase;
  color: var(--color-primary);
  font-weight: 500;
  margin-bottom: 1rem;
}

.hero-title {
  font-size: 3rem;
  font-weight: 800;
  letter-spacing: -0.03em;
  margin-bottom: 0.75rem;
  line-height: 1.1;
}

.accent {
  color: var(--color-primary);
}

.hero-description {
  font-size: 1.15rem;
  color: var(--color-text-muted);
  max-width: 600px;
  line-height: 1.6;
  margin-bottom: 1.5rem;
}

.hero-actions {
  display: flex;
  gap: 1rem;
  flex-wrap: wrap;
}

.btn-primary {
  display: inline-block;
  background: var(--color-primary);
  color: #fff;
  padding: 0.75rem 1.5rem;
  border-radius: var(--radius-sm);
  font-weight: 600;
  text-decoration: none;
  transition: background var(--transition);
}

.btn-primary:hover {
  background: var(--color-primary-dark);
  color: #fff;
}

.btn-secondary {
  display: inline-block;
  background: var(--color-bg-subtle);
  color: var(--color-text);
  border: 1px solid var(--color-border);
  padding: 0.75rem 1.5rem;
  border-radius: var(--radius-sm);
  font-weight: 600;
  text-decoration: none;
  transition: all var(--transition);
}

.btn-secondary:hover {
  border-color: var(--color-primary);
  color: var(--color-primary);
}

.expertise-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
  gap: 1.5rem;
  margin: 2rem 0;
}

.expertise-card {
  padding: 1.5rem;
  border: 1px solid var(--color-border);
  border-radius: var(--radius-md);
  background: var(--color-bg-card);
  box-shadow: var(--shadow-sm);
  transition: transform var(--transition), box-shadow var(--transition);
}

.expertise-card:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-md);
  border-color: var(--color-primary);
}

.expertise-icon {
  color: var(--color-primary);
  font-size: 1.5rem;
  margin-bottom: 0.75rem;
}

.expertise-card h3 {
  margin-top: 0;
  margin-bottom: 0.5rem;
}

.expertise-card p {
  color: var(--color-text-muted);
  font-size: 0.95rem;
  margin: 0;
}

@media (max-width: 768px) {
  .hero-title {
    font-size: 2rem;
  }

  .hero-description {
    font-size: 1rem;
  }

  .expertise-grid {
    grid-template-columns: 1fr;
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add assets/css/jekyll-theme-chirpy.scss
git commit -m "feat: add Chirpy SCSS overrides with brand tokens"
```

---

## Task 5: Adapt Project Pages

**Files:**
- Modify: `projects/dbt-o2c-mdm.md`
- Modify: `projects/airflow-iac-pipeline.md`
- Modify: `projects/genai-rag-warehouse.md`

- [ ] **Step 1: Update dbt-o2c-mdm.md frontmatter**

Replace the frontmatter block (lines 1-9) with:

```yaml
---
layout: page
title: "Project 1 · dbt O2C & MDM"
description: >-
  Enterprise Order-to-Cash transformation and Master Data Management resolution
  platform using dbt Core, Medallion architecture, and Kimball dimensional modeling
  across 20 regional ERPs.
categories: [Portfolio, Architecture]
tags: [dbt, snowflake, bigquery, kimball, medallion, mdm, sql, jinja]
---
```

Remove the `permalink` line — Chirpy uses its own permalink scheme for pages.

Update internal links in the body:
- `../index.html` → `/portfolio/`
- `airflow-iac-pipeline.html` → `/projects/airflow-iac-pipeline/`
- `genai-rag-warehouse.html` → `/projects/genai-rag-warehouse/`
- `dbt-o2c-mdm.html` (self-references) → `/projects/dbt-o2c-mdm/`

- [ ] **Step 2: Update airflow-iac-pipeline.md frontmatter**

Replace the frontmatter block (lines 1-9) with:

```yaml
---
layout: page
title: "Project 2 · Airflow + Terraform"
description: >-
  Config-driven multi-source ingestion platform with Airflow orchestration,
  Terraform IaC, data contracts, and CI/CD — extracting from 20 regional ERPs
  into a governed data lake and warehouse.
categories: [Portfolio, DataOps]
tags: [airflow, terraform, python, s3, gcs, github-actions, data-contracts]
---
```

Remove the `permalink` line.

Update internal links in the body:
- `../index.html` → `/portfolio/`
- `dbt-o2c-mdm.html` → `/projects/dbt-o2c-mdm/`
- `genai-rag-warehouse.html` → `/projects/genai-rag-warehouse/`

- [ ] **Step 3: Update genai-rag-warehouse.md frontmatter**

Replace the frontmatter block (lines 1-9) with:

```yaml
---
layout: page
title: "Project 3 · GenAI Warehouse Copilot"
description: >-
  RAG-powered warehouse assistant grounded in dbt governance artifacts with
  governed text-to-SQL, deterministic lineage, LLM evaluation suites,
  and enterprise-grade safety guardrails.
categories: [Portfolio, GenAI]
tags: [python, claude-api, rag, vector-search, fastapi, dbt, llm]
---
```

Remove the `permalink` line.

Update internal links in the body:
- `../index.html` → `/portfolio/`
- `dbt-o2c-mdm.html` → `/projects/dbt-o2c-mdm/`
- `airflow-iac-pipeline.html` → `/projects/airflow-iac-pipeline/`

- [ ] **Step 4: Commit**

```bash
git add projects/
git commit -m "feat: adapt project pages for Chirpy"
```

---

## Task 6: Adapt Blog Posts

**Files:**
- Modify: `_posts/2026-07-08-medallion-kimball-over-data-vault.md`
- Modify: `_posts/2026-07-08-My-Personal-Library.md`

- [ ] **Step 1: Update medallion-kimball post frontmatter**

Replace the frontmatter block (lines 1-9) with:

```yaml
---
layout: post
title: "Why Medallion + Kimball Over Data Vault 2.0 for a 20-Country Migration"
date: 2026-07-08
categories: [Architecture]
tags: [dbt, kimball, medallion, data-vault, mdm, modeling]
description: >-
  An architectural decision walkthrough: choosing Medallion + Kimball dimensional
  modeling over Data Vault 2.0 for a multinational ERP consolidation, and when
  Data Vault would have been the better call.
---
```

Update internal links in the body:
- `{{ site.baseurl }}/projects/dbt-o2c-mdm.html` → `/projects/dbt-o2c-mdm/`
- Any other `.html` project links → root-relative without `.html`

- [ ] **Step 2: Update My-Personal-Library post frontmatter**

The file currently has no frontmatter. Add this at the top:

```yaml
---
layout: post
title: "My Personal Library"
date: 2026-07-08
categories: [Methodology]
tags: [reading-list, continuous-engineering, books]
description: >-
  A curated reading list reflecting the conceptual framework I operate within —
  data architecture, DevOps, organizational change, and strategic decision-making.
---
```

- [ ] **Step 3: Commit**

```bash
git add _posts/
git commit -m "feat: adapt blog posts with Chirpy categories and tags"
```

---

## Task 7: Replace GitHub Actions Workflow

**Files:**
- Modify: `.github/workflows/jekyll.yml`

- [ ] **Step 1: Replace the workflow**

Replace the entire `.github/workflows/jekyll.yml` with:

```yaml
name: "Build and Deploy"
on:
  push:
    branches:
      - main
      - master
    paths-ignore:
      - .gitignore
      - README.md
      - LICENSE

  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: true

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v7
        with:
          fetch-depth: 0

      - name: Setup Pages
        id: pages
        uses: actions/configure-pages@v6

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.4
          bundler-cache: true

      - name: Build site
        run: bundle exec jekyll b -d "_site${{ steps.pages.outputs.base_path }}"
        env:
          JEKYLL_ENV: "production"

      - name: Test site
        run: |
          bundle exec htmlproofer _site \
            \-\-disable-external \
            \-\-ignore-urls "/^http:\/\/127.0.0.1/,/^http:\/\/0.0.0.0/,/^http:\/\/localhost/"

      - name: Upload site artifact
        uses: actions/upload-pages-artifact@v5
        with:
          path: "_site${{ steps.pages.outputs.base_path }}"

  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v5
```

- [ ] **Step 2: Commit**

```bash
git add .github/workflows/jekyll.yml
git commit -m "feat: replace CI workflow with Chirpy-compatible deploy"
```

---

## Task 8: Remove Old Minima Files

**Files:**
- Delete: `index.md`
- Delete: `portfolio/index.md`
- Delete: `library/index.md`
- Delete: `about/index.md`
- Delete: `_includes/head.html`
- Delete: `assets/css/style.scss`

- [ ] **Step 1: Remove files that are replaced by Chirpy equivalents**

```bash
git rm index.md
git rm portfolio/index.md
git rm library/index.md
git rm about/index.md
git rm _includes/head.html
git rm assets/css/style.scss
```

- [ ] **Step 2: Clean up empty directories**

```bash
# Remove empty directories if they exist
# (git automatically removes empty dirs on rm)
```

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "chore: remove old minima files replaced by Chirpy"
```

---

## Task 9: Update Agent Guidance

**Files:**
- Modify: `CLAUDE.md`
- Modify: `AGENTS.md`

- [ ] **Step 1: Update CLAUDE.md**

Apply these changes to `CLAUDE.md`:

1. In the **Tech Stack** section, change `Jekyll (minima theme)` to `Jekyll (jekyll-theme-chirpy)`

2. Replace the **Content Structure** block with:

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

3. Remove the **Mermaid.js Diagrams** section (Chirpy handles Mermaid natively). Replace it with:

```markdown
### Mermaid Diagrams

Chirpy supports Mermaid diagrams natively. Use fenced code blocks:

    ```mermaid
    graph LR
      A[Source] -->|ELT| B[Warehouse]
      B -->|dbt| C[Analytics]
    ```
```

4. In the **Notes** section, add:
- **Theme is Chirpy:** Use Chirpy's tab, category, and tag conventions for navigation. Do not add custom header navigation.
- **Post frontmatter:** All posts must include `categories` and `tags` arrays in addition to `layout`, `title`, and `date`.

- [ ] **Step 2: Update AGENTS.md**

Apply these changes:

1. In the **Working Rules** section, add:
- Include `categories` and `tags` in all post and project page frontmatter.

2. Replace the **Content Map** with:

```
- `index.html`: homepage with hero section and post feed
- `_tabs/portfolio.md`: technical portfolio
- `_tabs/library.md`: thought leadership index
- `_tabs/about.md`: professional context
- `_posts/`: dated articles with categories and tags
- `projects/`: project evidence pages
- `docs/adr/`: Architecture Decision Records
- `assets/css/jekyll-theme-chirpy.scss`: custom styling
- `_config.yml`: site metadata and Chirpy configuration
- `_data/contact.yml`: social links
- `_data/share.yml`: share buttons
- `voice_and_tone.md`: voice guide for public-facing content
```

- [ ] **Step 3: Commit**

```bash
git add CLAUDE.md AGENTS.md
git commit -m "docs: update agent guidance for Chirpy theme"
```

---

## Task 10: Build Verification and Final Review

**Files:**
- Verify: entire Jekyll site

- [ ] **Step 1: Install dependencies**

Run:

```powershell
bundle install
```

Expected: Bundler installs jekyll-theme-chirpy and all plugins without errors.

- [ ] **Step 2: Build the site**

Run:

```powershell
bundle exec jekyll build
```

Expected: Build completes without Liquid, Markdown, or missing include errors.

- [ ] **Step 3: Verify generated routes**

Run:

```powershell
Get-ChildItem _site -Directory
```

Expected: `_site` contains `portfolio`, `library`, `about`, `categories`, `tags`, `archives`, `projects`, `docs`, and `posts` directories.

- [ ] **Step 4: Search for broken internal links**

Search all `.md` and `.html` files for links ending in `.html` or `../` patterns that should have been updated:

```powershell
Select-String -Path "*.md","*.html" -Pattern "\.\./" -Recurse
Select-String -Path "*.md" -Pattern "\.html\)" -Recurse
```

Expected: No matches — all internal links use root-relative paths without `.html`.

- [ ] **Step 5: Verify no old minima references remain**

```powershell
Select-String -Path "_config.yml","CLAUDE.md","AGENTS.md" -Pattern "minima" -Recurse
```

Expected: No matches — all references to minima have been replaced.

- [ ] **Step 6: Final commit**

```bash
git add -A
git commit -m "feat: complete Chirpy theme migration"
```
