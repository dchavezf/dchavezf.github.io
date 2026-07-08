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
