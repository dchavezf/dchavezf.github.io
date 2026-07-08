# DanielChavez.mx Restructuring Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reorganize `dchavezf.github.io` from a portfolio-first homepage into a personal professional hub with clear Home, Portfolio, Library, and About pillars.

**Architecture:** Keep Jekyll + minima as the base and use `header_pages` for global navigation. Preserve the MeridianTrade technical narrative inside `/portfolio/`, make the root homepage a routing and positioning page, define site voice in `voice_and_tone.md`, and document repo working conventions in both `CLAUDE.md` and `AGENTS.md`.

**Tech Stack:** Jekyll, minima, Markdown frontmatter, SCSS in `assets/css/style.scss`, GitHub Pages, MADR ADRs.

---

## Current State

The working tree already contains restructuring changes that must be reviewed before further edits:

- `index.md` has been modified.
- `_config.yml` has been modified and already includes `header_pages`.
- `portfolio/index.md`, `library/index.md`, `about/index.md`, and `CLAUDE.md` exist as untracked or modified files.
- `AGENTS.md` does not exist yet and must be added.
- `voice_and_tone.md` does not exist yet and must be created from `about/ DataEngineer Daniel Chavez Flores.md`.
- `_includes/head.html` exists, but there is no custom `_includes/header.html`; navigation should rely on minima unless a custom header becomes necessary.

Do not overwrite these files blindly. Read each file first, preserve useful existing content, and only edit the specific sections required by the tasks below.

## File Structure

- Modify: `_config.yml`  
  Owns site metadata, GitHub Pages configuration, social links, and global navigation.

- Modify: `index.md`  
  Root homepage. Should be a concise brand and routing page, not the full technical portfolio.

- Modify: `portfolio/index.md`  
  Dedicated technical portfolio page. Should preserve the MeridianTrade narrative, project links, ADR references, and evidence-led structure.

- Modify: `library/index.md`  
  Thought leadership hub. Should list posts from `_posts/` and provide a clean route for ADR-adjacent writing.

- Modify: `about/index.md`  
  Professional context page. Should hold philosophy, experience, hiring signals, contact, and resume-adjacent narrative.

- Modify: `assets/css/style.scss`  
  Visual refinements for cards, page sections, navigation affordances, and responsive spacing.

- Modify: `CLAUDE.md`  
  Claude Code guidance. Must match the actual repo structure after restructuring and document how to work safely in this Jekyll site.

- Create: `AGENTS.md`  
  General agent guidance for Codex and other AI coding agents. Should mirror the operational parts of `CLAUDE.md` without Claude-specific wording.

- Create: `voice_and_tone.md`  
  Content voice guide distilled from `about/ DataEngineer Daniel Chavez Flores.md`. Must be consulted before writing or editing public-facing content.

- Verify only: `_includes/head.html`  
  Confirm Mermaid and SEO-related includes still work. Avoid adding a custom header unless minima navigation cannot satisfy the design.

## Open Decisions

Use these decisions unless the site owner says otherwise:

- The current technical portfolio belongs at `/portfolio/`.
- The writing hub should be named `Library`.
- The primary homepage CTA should be `View the portfolio`, with secondary routes to `Read the library` and `About Daniel`.
- Keep the brand language focused on data architecture, DataOps, AI platforms, and business-case-first delivery.
- All new content should follow `voice_and_tone.md` once that file exists.

## Task 1: Confirm Navigation and Metadata

**Files:**
- Modify: `_config.yml`
- Verify: `_includes/head.html`

- [ ] **Step 1: Inspect current metadata**

Run:

```powershell
Get-Content _config.yml
Get-Content _includes/head.html
```

Expected: `_config.yml` includes `theme: minima`, `plugins`, and `header_pages`; `_includes/head.html` includes existing head customizations such as Mermaid support.

- [ ] **Step 2: Normalize site navigation**

Ensure `_config.yml` contains this navigation block:

```yaml
header_pages:
  - portfolio/index.md
  - library/index.md
  - about/index.md
```

Expected: The site header shows Portfolio, Library, and About through minima.

- [ ] **Step 3: Keep deployment settings intact**

Confirm these settings remain present:

```yaml
theme: minima

plugins:
  - jekyll-seo-tag
  - jekyll-sitemap
```

Expected: GitHub Pages can still build the site with the existing `Gemfile`.

## Task 2: Finalize the Root Homepage

**Files:**
- Modify: `index.md`

- [ ] **Step 1: Read the existing homepage**

Run:

```powershell
Get-Content index.md
```

Expected: The page has Jekyll frontmatter and should now act as the site entry point.

- [ ] **Step 2: Confirm homepage role**

The homepage must include:

- A short positioning statement for Daniel Chavez.
- One primary CTA to `/portfolio/`.
- Secondary links to `/library/` and `/about/`.
- A short summary of expertise across enterprise architecture, DataOps, and AI platforms.

Expected: The root page is scannable and does not duplicate the full portfolio narrative.

- [ ] **Step 3: Check internal links**

Run:

```powershell
rg -n "\]\((?!https?://|mailto:|#)" index.md
```

Expected: Internal links point to valid site paths such as `/portfolio/`, `/library/`, and `/about/`.

## Task 3: Preserve the Technical Portfolio

**Files:**
- Modify: `portfolio/index.md`
- Verify: `projects/*.md`
- Verify: `docs/adr/*.md`

- [ ] **Step 1: Read portfolio content**

Run:

```powershell
Get-Content portfolio/index.md
```

Expected: The page contains or links to the MeridianTrade Group narrative, the three project pages, and the ADR index.

- [ ] **Step 2: Confirm project links**

The portfolio must link to:

```markdown
- [O2C and MDM transformation](/projects/dbt-o2c-mdm/)
- [Multi-source ingestion and IaC pipeline](/projects/airflow-iac-pipeline/)
- [GenAI warehouse copilot](/projects/genai-rag-warehouse/)
- [Architecture Decision Records](/docs/adr/)
```

Expected: Technical reviewers can reach project evidence and ADR rationale from the portfolio page.

- [ ] **Step 3: Validate project page questions**

Each `projects/*.md` page must answer:

- What is the business problem?
- What tools were chosen and why?
- What methodology was applied?
- Where does the code live?
- What was the quantified outcome?

Expected: The portfolio remains evidence-led after being moved out of the root homepage.

## Task 4: Finalize the Library Hub

**Files:**
- Modify: `library/index.md`
- Verify: `_posts/*.md`

- [ ] **Step 1: Read the current library page**

Run:

```powershell
Get-Content library/index.md
```

Expected: The page has frontmatter and a Jekyll loop or explicit list for published posts.

- [ ] **Step 2: Use a Jekyll posts loop**

If missing, add this loop:

```liquid
{% for post in site.posts %}
- [{{ post.title }}]({{ post.url | relative_url }}) - {{ post.date | date: "%Y-%m-%d" }}
{% endfor %}
```

Expected: New files in `_posts/` appear automatically on `/library/`.

- [ ] **Step 3: Verify post frontmatter**

Run:

```powershell
rg -n "^layout:|^title:|^date:" _posts
```

Expected: Each post has `layout`, `title`, and `date` frontmatter.

## Task 5: Finalize the About Page

**Files:**
- Modify: `about/index.md`
- Verify: `resume/*.md`

- [ ] **Step 1: Read about and resume source material**

Run:

```powershell
Get-Content about/index.md
Get-Content resume\master-resume.md
```

Expected: `about/index.md` can summarize experience and philosophy without becoming a full resume dump.

- [ ] **Step 2: Confirm about page sections**

The page must include:

- Professional positioning.
- 22 years of experience.
- Spec-first and business-case-first delivery philosophy.
- Hiring signals or collaboration style.
- Contact routes.

Expected: The page supports cultural and professional fit, while detailed project evidence stays in `/portfolio/`.

## Task 6: Create the Voice and Tone Guide

**Files:**
- Create: `voice_and_tone.md`
- Read: `about/ DataEngineer Daniel Chavez Flores.md`
- Modify later: `CLAUDE.md`
- Modify later: `AGENTS.md`

- [ ] **Step 1: Read the strategic source document**

Run:

```powershell
Get-Content "about\ DataEngineer Daniel Chavez Flores.md"
```

Expected: The source document provides positioning, audience anxieties, buyer language, core beliefs, content quality bar, and examples of the desired strategic tone.

- [ ] **Step 2: Create `voice_and_tone.md`**

Add this file at the repository root:

```markdown
# Voice and Tone

Use this guide before creating or editing public-facing content for DanielChavez.mx. It is distilled from `about/ DataEngineer Daniel Chavez Flores.md`.

## Core Positioning

Daniel Chavez writes for leaders who need enterprise data work to survive real delivery pressure: C-level scrutiny, margin risk, governance, legacy complexity, and the gap between technical execution and business trust.

The voice should position Daniel as a senior data and analytics architect who combines technical depth, commercial fluency, delivery discipline, and calm stakeholder management.

## Audience

Primary readers include consulting partners, practice directors, technical VPs, hiring managers, senior engineers, and executives evaluating whether Daniel can reduce delivery risk.

They care about:

- Whether technical decisions protect margin, trust, and delivery timelines.
- Whether architecture can be explained to CFOs, auditors, and steering committees.
- Whether work becomes reusable operating capability, not one-off heroics.
- Whether the author has lived through real delivery pressure.

## Voice Principles

- Lead with business consequence, then explain the technical mechanism.
- Treat stakeholder communication as an engineering discipline, not a soft-skill add-on.
- Prefer concrete trade-offs, constraints, and decision rationale over generic best practices.
- Write with calm authority: direct, evidence-led, and commercially aware.
- Use memorable contrasts when useful: frameworks over heroes, reusable systems over bespoke effort, signal over noise.
- Keep the tone senior and practical. Avoid hype, empty motivation, and tool worship.

## Content Patterns

Good content should usually include:

- A real or realistic delivery tension.
- The business risk behind the technical problem.
- The architectural or operating decision.
- The trade-offs and consequences.
- A clear signal of repeatability: framework, checklist, ADR, pattern, or reusable asset.

## Language To Prefer

- business case first, spec second, code third
- chaos in, signal out
- delivery risk
- reusable framework
- governed data
- decision record
- stakeholder pressure
- margin protection
- auditability
- operating system
- technical depth plus commercial fluency

## Language To Avoid

- Generic tutorial language with no business stakes.
- Claims that depend on hype rather than evidence.
- Over-indexing on tool names without explaining why they matter.
- Soft claims such as "passionate", "innovative", or "world-class" unless backed by proof.
- Treating communication, governance, or delivery discipline as secondary to code.

## Quality Bar

Before publishing, ask:

- Would a practice director forward this to a team member?
- Does the piece clarify a business risk, not only a technical topic?
- Is there a reusable decision, pattern, or framework?
- Can a senior technical reader see the trade-offs?
- Can a non-technical executive understand why it matters?
```

Expected: The guide is short enough to use in daily content work and specific enough to preserve Daniel's strategic voice.

- [ ] **Step 3: Verify source traceability**

Run:

```powershell
rg -n "business case first|chaos in, signal out|delivery risk|reusable framework|stakeholder" voice_and_tone.md
```

Expected: The guide includes the core positioning phrases and content principles needed for future site writing.

## Task 7: Sync Claude Guidance

**Files:**
- Modify: `CLAUDE.md`

- [ ] **Step 1: Read the file**

Run:

```powershell
Get-Content CLAUDE.md
```

Expected: The file describes the current Jekyll portfolio site and its working conventions.

- [ ] **Step 2: Update structure if needed**

Ensure the content structure section matches the actual target routes:

```text
index.md
portfolio/index.md
library/index.md
about/index.md
projects/
docs/adr/
_posts/
_includes/
assets/css/style.scss
_config.yml
AGENTS.md
voice_and_tone.md
```

Expected: Claude Code can understand the restructured repo without relying on stale homepage assumptions.

- [ ] **Step 3: Document agent-safe editing rules**

Ensure `CLAUDE.md` says:

- Do not commit generated `_site/`.
- Preserve ADR links when moving portfolio content.
- Prefer relative or root-relative internal links.
- Run `bundle exec jekyll build` before claiming completion when Ruby dependencies are available.
- Keep `AGENTS.md` synchronized when operational guidance changes.
- Read `voice_and_tone.md` before creating or editing public-facing content, and apply its style guidance.

Expected: Future Claude sessions can safely maintain the site.

## Task 8: Add General Agent Guidance

**Files:**
- Create: `AGENTS.md`

- [ ] **Step 1: Create `AGENTS.md`**

Add this file at the repository root:

```markdown
# AGENTS.md

This repository is a Jekyll-based professional site for Daniel Chavez. It is deployed through GitHub Pages and uses Markdown, YAML frontmatter, minima, and custom SCSS.

## Working Rules

- Read `CLAUDE.md` for the full project overview and keep this file aligned with it.
- Do not commit `_site/` or other generated build output.
- Preserve the four main routes: `/`, `/portfolio/`, `/library/`, and `/about/`.
- Keep technical portfolio evidence in `/portfolio/`, project pages in `/projects/`, and ADRs in `/docs/adr/`.
- Use root-relative internal links such as `/portfolio/` and `/docs/adr/`.
- Keep ADRs in MADR style and update `docs/adr/README.md` when adding ADR files.
- Read `voice_and_tone.md` before creating or editing public-facing content, and apply its voice, tone, and quality bar.
- Run `bundle exec jekyll build` before final handoff when the local Ruby environment is available.

## Site Commands

```bash
bundle install
bundle exec jekyll serve
bundle exec jekyll build
```

## Content Map

- `index.md`: homepage and routing hub
- `portfolio/index.md`: technical portfolio
- `library/index.md`: thought leadership index
- `about/index.md`: professional context
- `_posts/`: dated articles
- `projects/`: project evidence pages
- `docs/adr/`: Architecture Decision Records
- `assets/css/style.scss`: custom styling
- `_config.yml`: site metadata and navigation
- `voice_and_tone.md`: voice guide for public-facing content
```

Expected: AI coding agents have a neutral, tool-agnostic guide in addition to `CLAUDE.md`.

## Task 9: Visual and Responsive Polish

**Files:**
- Modify: `assets/css/style.scss`
- Verify: `index.md`, `portfolio/index.md`, `library/index.md`, `about/index.md`

- [ ] **Step 1: Read current styles**

Run:

```powershell
Get-Content assets\css\style.scss
```

Expected: Existing brand styling remains the base for any additions.

- [ ] **Step 2: Verify shared page components**

Confirm styles exist for:

- Homepage route cards or link groups.
- Portfolio project cards.
- Library post list.
- About page sections.
- Mobile spacing and readable line length.

Expected: The four main routes feel related and remain readable on mobile.

## Task 10: Build and Link Verification

**Files:**
- Verify: entire Jekyll site

- [ ] **Step 1: Build the site**

Run:

```powershell
bundle exec jekyll build
```

Expected: Build completes without Liquid, Markdown, or missing include errors.

- [ ] **Step 2: Inspect generated routes**

Run:

```powershell
Get-ChildItem _site -Directory
```

Expected: `_site` contains generated `portfolio`, `library`, `about`, `projects`, and `docs` routes.

- [ ] **Step 3: Search for broken local references**

Run:

```powershell
rg -n "portfolio/index.md|library/index.md|about/index.md|PLACEHOLDER" .
```

Expected: No stale `.md` route references in published content and no unfinished placeholders.

## Task 11: Final Review

**Files:**
- Verify: `docs/plan/reestructuring.md`
- Verify: `CLAUDE.md`
- Verify: `AGENTS.md`
- Verify: `voice_and_tone.md`
- Verify: `_config.yml`
- Verify: top-level route files

- [ ] **Step 1: Check git status**

Run:

```powershell
git status --short
```

Expected: Only intentional restructuring files are modified or added.

- [ ] **Step 2: Review final diff**

Run:

```powershell
git diff -- docs/plan/reestructuring.md CLAUDE.md AGENTS.md voice_and_tone.md _config.yml index.md portfolio/index.md library/index.md about/index.md assets/css/style.scss
```

Expected: The diff shows a coherent site restructure and synchronized agent guidance.

- [ ] **Step 3: Commit in a focused change**

Run:

```bash
git add docs/plan/reestructuring.md CLAUDE.md AGENTS.md voice_and_tone.md _config.yml index.md portfolio/index.md library/index.md about/index.md assets/css/style.scss
git commit -m "docs: plan portfolio site restructuring"
```

Expected: Commit contains the plan and related site guidance. If implementation content changes are included, use a broader message such as `feat: restructure professional site navigation`.
