# AGENTS.md

This repository is a Jekyll-based professional site for Daniel Chavez. It is deployed through GitHub Pages and uses Markdown, YAML frontmatter, minima, and custom SCSS.

## Working Rules

- Read `CLAUDE.md` for the full project overview and keep this file aligned with it.
- Read `voice_and_tone.md` before creating or editing public-facing content, and apply its voice, tone, preferred language, and quality bar.
- Do not commit `_site/` or other generated build output.
- Preserve the four main routes: `/`, `/portfolio/`, `/library/`, and `/about/`.
- Keep technical portfolio evidence in `/portfolio/`, project pages in `/projects/`, and ADRs in `/docs/adr/`.
- Use root-relative internal links such as `/portfolio/` and `/docs/adr/`.
- Keep ADRs in MADR style and update `docs/adr/README.md` when adding ADR files.
- Include `categories` and `tags` in all post and project page frontmatter.
- Run `bundle exec jekyll build` before final handoff when the local Ruby environment is available.

## Site Commands

```bash
bundle install
bundle exec jekyll serve
bundle exec jekyll build
```

## Content Map

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
