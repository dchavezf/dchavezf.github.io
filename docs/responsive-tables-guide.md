---
title: Responsive Tables Guide
description: Guide for creating responsive tables in markdown
---

# Responsive Tables Implementation

## Overview

All tables in this site automatically become mobile-friendly on screens smaller than 768px (tablets and phones). The conversion happens via CSS and a Jekyll plugin.

## How It Works

### Desktop (≥ 768px)
- Tables display normally as HTML tables
- Headers visible at the top
- Horizontal scroll enabled if table is too wide

### Mobile (< 768px)
- Tables convert to card-based layout
- Each row becomes a card/block
- Each cell displays as a label-value pair
- Labels come from the table headers via `data-label` attributes

## Table Format Requirements

Tables must follow standard Markdown format with headers:

```markdown
| Column 1 | Column 2 | Column 3 |
|----------|----------|----------|
| Value 1  | Value 2  | Value 3  |
| Value 4  | Value 5  | Value 6  |
```

The Jekyll plugin automatically:
1. Identifies the `<thead>` section and extracts headers
2. Adds `data-label` attributes to each `<td>` cell
3. CSS styling handles responsive layout

## Mobile Layout Example

On mobile, a table like:

```markdown
| Skill | Level |
|-------|-------|
| SQL   | Expert |
| Python | Advanced |
```

Renders as:

```
┌─────────────────────┐
│ Skill: SQL          │
│ Level: Expert       │
└─────────────────────┘
┌─────────────────────┐
│ Skill: Python       │
│ Level: Advanced     │
└─────────────────────┘
```

## Best Practices

### 1. Column Headers
- Keep headers **short and concise** (1-2 words)
- Use clear, unambiguous labels
- Avoid special characters or symbols

### 2. Cell Content
- Keep text concise to avoid excessive line breaks on mobile
- Use bullet points within cells sparingly
- Link text is supported normally

### 3. Wide Tables
- Limit to 4-5 columns maximum for better mobile readability
- If you need more columns, consider splitting into multiple tables
- Alternative: Use lists or descriptive text instead

### 4. Examples

**Good - Readable on mobile:**
```markdown
| Area | Evidence |
|------|----------|
| Data Product Management | Product discovery, Design Sprint, stakeholder interviews |
| Enterprise Data Architecture | Snowflake, BigQuery, dbt, Kimball, Medallion |
| Leadership | Team leadership, executive stakeholder management |
```

**Avoid - Too many columns:**
```markdown
| Col1 | Col2 | Col3 | Col4 | Col5 | Col6 | Col7 |
```

## Testing

To verify tables render correctly:

1. **Desktop:** Tables appear with standard HTML table formatting
2. **Tablet (768px or less):** Tables convert to card layout
3. **Phone:** Tables display as single-column cards with labels

Use browser DevTools to test responsive behavior:
- Open site in browser
- Press F12 for DevTools
- Click device toolbar icon
- Select "iPhone" or another mobile device

## CSS Classes & Styling

The plugin applies these automatically - no manual CSS needed:

- `table` - Main table wrapper
- `thead` - Header row (hidden on mobile)
- `tbody` - Body rows
- `th` - Header cells
- `td` - Data cells (with `data-label` attribute)

All styling is handled by the responsive CSS in `assets/css/jekyll-theme-chirpy.scss`.

## Troubleshooting

### Table appears broken on mobile?
- Check that headers are properly formatted in markdown
- Ensure the `<table>` tag has both `<thead>` and `<tbody>`
- Rebuild: `bundle exec jekyll build`

### `data-label` attributes missing?
- The Jekyll plugin adds these automatically
- If missing, the plugin may not have run
- Check `_plugins/responsive-tables.rb` is present
- Check for Ruby errors in build output

### Labels too long?
- Shorten column headers in your markdown
- Consider using abbreviations if appropriate
- Split wide tables into multiple tables

## Browser Support

Responsive tables work in all modern browsers:
- Chrome 60+
- Firefox 60+
- Safari 12+
- Edge 79+

Mobile browsers:
- iOS Safari 12+
- Chrome Android
- Samsung Internet

## Implementation Details

### Jekyll Plugin (`_plugins/responsive-tables.rb`)
- Runs during Jekyll build
- Extracts headers from `<thead>` tags
- Adds `data-label` to `<tbody>` cells
- Uses Nokogiri for HTML parsing

### CSS Styling (`assets/css/jekyll-theme-chirpy.scss`)
- Desktop: Normal table display
- Mobile: Grid-based layout with labels
- Hover effects on desktop
- Striped rows on desktop for readability
