# Auditoría del Portafolio — dchavezf.github.io

## Resumen Ejecutivo

El portafolio tiene una **narrativa estratégica excelente** y un posicionamiento claro como Enterprise Data Architect. Sin embargo, evaluado contra tu propio manifiesto de mejores prácticas, hay brechas significativas que podrían debilitar la credibilidad ante reclutadores técnicos senior. La principal: **los tres proyectos son especificaciones sin código**. Un portafolio que promete "working evidence" pero entrega solo documentación corre el riesgo de parecer exactamente lo opuesto a lo que intenta demostrar.

---

## Scorecard: Tu Manifiesto vs. Tu Repositorio Actual

| Criterio del Manifiesto | Estado | Score |
|---|---|---|
| **README como Landing Page Estratégica** | ✅ Excelente posicionamiento, propuesta de valor clara | ⬛⬛⬛⬛⬜ 4/5 |
| **Identidad y Posicionamiento** | ✅ Bien definido: Enterprise Data Architect & AI Platform Engineer | ⬛⬛⬛⬛⬜ 4/5 |
| **Certificaciones Clave** | ⚠️ Solo GitHub Copilot y GitHub Foundations; faltan IBM Data Engineering y otras de alto impacto | ⬛⬛⬜⬜⬜ 2/5 |
| **Stack Estratégico (agrupado por capacidad)** | ⚠️ Hay una lista en "Hiring Signals" pero no está organizada por capacidad como prescribe tu manifiesto | ⬛⬛⬜⬜⬜ 2/5 |
| **3-4 Proyectos Ancla (Pinned Repos)** | ⚠️ 3 proyectos definidos pero **cero repositorios de código enlazados** | ⬛⬜⬜⬜⬜ 1/5 |
| **Proyecto: Migración/Fábrica de Datos** | ✅ Project 1 cubre este eje bien (dbt O2C + MDM) | ⬛⬛⬛⬛⬜ 4/5 |
| **Proyecto: AI Ops & Automation** | ✅ Project 3 (Warehouse Copilot) cubre el eje GenAI | ⬛⬛⬛⬛⬜ 4/5 |
| **Proyecto: App Full-Stack de Metadatos** | ❌ No existe un 4to proyecto ancla de app funcional (BI/local-first) | ⬛⬜⬜⬜⬜ 1/5 |
| **Business Case y ROI en cada README** | ✅ Cada proyecto abre con business case y métricas cuantificadas | ⬛⬛⬛⬛⬛ 5/5 |
| **Infraestructura como Código (IaC)** | ❌ Project 2 lo promete pero no hay Terraform/Docker files | ⬛⬜⬜⬜⬜ 1/5 |
| **CI/CD (GitHub Actions)** | ❌ Ningún workflow `.github/workflows/` existe | ⬛⬜⬜⬜⬜ 1/5 |
| **ADRs (`/docs/adr`)** | ❌ Las tablas de "Architecture decisions" son un buen inicio pero no están en formato ADR estándar | ⬛⬜⬜⬜⬜ 1/5 |
| **Publicaciones / Liderazgo de Pensamiento** | ❌ No hay blog, artículos, ni sección de publicaciones | ⬛⬜⬜⬜⬜ 1/5 |
| **Diseño Visual del Site** | ⚠️ Minima default — funcional pero genérico, sin diferenciación visual | ⬛⬜⬜⬜⬜ 1/5 |
| **Diagramas de Arquitectura** | ✅ Mermaid.js integrado correctamente con head.html override | ⬛⬛⬛⬛⬜ 4/5 |

**Score global: 36/75 (48%)**

---

## Lo Que Ya Funciona Muy Bien

### 1. Narrativa coherente y diferenciada
La idea de un universo ficticio cohesivo (MeridianTrade Group) donde los 3 proyectos se interconectan es **brillante**. Eleva el portafolio muy por encima de tutoriales aislados. El diagrama Mermaid en `index.md` que muestra el flujo P2→P1→P3 lo vende perfectamente.

### 2. Estructura spec-first con "Definition of Done"
Cada proyecto tiene criterios de aceptación verificables y específicos. Esto demuestra madurez profesional. La frase *"verifiable, not vibes"* es memorable y auténtica.

### 3. Tablas de decisiones arquitectónicas
Las tablas "Decision / Alternative Considered / Why This Choice" en cada proyecto son excelentes. Muestran juicio ingenieril, no solo ejecución técnica. La honestidad de "Terraform was flagged as a gap in my profile" genera confianza.

### 4. Business-case-first approach
Cada proyecto abre con el problema de negocio y cuantifica el costo de la inacción. Esto habla directamente al reclutador o hiring manager de nivel senior.

### 5. Integración de Mermaid.js
La solución en [head.html](file:///c:/Claude/dchavezf.github.io/_includes/head.html) para renderizar Mermaid dentro de Jekyll/Minima está correctamente implementada.

---

## Brechas Críticas

### 🔴 Brecha 1: Cero código implementado — la promesa principal está incumplida

**Impacto: ALTO** — Es la brecha más dañina.

El [README.md](file:///c:/Claude/dchavezf.github.io/README.md) dice: *"This portfolio demonstrates, in reviewable documents **and code**"*. El [index.md](file:///c:/Claude/dchavezf.github.io/index.md) dice: *"Anyone can claim skills on a resume. This portfolio is the **working evidence**"*.

Pero los tres proyectos dicen `🚧 implementation in progress`. Un reclutador técnico que haga click y encuentre solo prosa — sin un solo archivo `.sql`, `.py`, `.tf`, ni un `Dockerfile` — concluirá que lo que hay es exactamente eso: claims on a resume.

> [!CAUTION]
> **El portafolio actualmente contradice su propia tesis.** La calidad de la especificación es real, pero sin código ejecutable pierde toda credibilidad de "working evidence". Prioriza implementar al menos un proyecto completo antes de invertir tiempo en los otros.

**Recomendación:**
- Implementar **Project 1 (dbt O2C)** completo primero — es el más tangible y el que mejor demuestra tus skills core.
- Un solo proyecto terminado con `dbt build` verde, datos seed sintéticos, tests pasando y un dbt docs site vale más que tres especificaciones perfectas.

---

### 🔴 Brecha 2: Ausencia total de CI/CD — contradice el manifiesto

**Impacto: ALTO**

Tu manifiesto dice: *"CI/CD Impecable: Configura GitHub Actions para mostrar que entiendes el ciclo de vida del software"*. No existe carpeta `.github/workflows/`. Ni siquiera un lint del Jekyll site.

**Recomendación:** Crear al menos:

```yaml
# .github/workflows/jekyll.yml — build y deploy del site
# .github/workflows/dbt-ci.yml — dbt build + test en PR (cuando exista Project 1)
```

Incluso un workflow básico que valide que el sitio Jekyll compila sin errores sería una mejora inmediata y envía la señal correcta.

---

### 🔴 Brecha 3: Sin ADRs formales — oportunidad desperdiciada

**Impacto: MEDIO-ALTO**

Tu manifiesto dice: *"Los reclutadores técnicos de alto nivel leen los ADRs para entender cómo piensas y por qué elegiste una tecnología sobre otra"*. Las tablas de decisiones en cada proyecto son un 70% del camino, pero no están en formato ADR estándar (ADR-001, contexto, decisión, consecuencias, estado).

**Recomendación:**
```
docs/
  adr/
    ADR-001-elt-over-etl.md
    ADR-002-medallion-plus-kimball-over-data-vault.md
    ADR-003-mdm-seed-over-probabilistic-matching.md
    ADR-004-config-driven-dag-factory.md
    ADR-005-gold-whitelist-sql-guard.md
    ADR-006-deterministic-lineage-over-llm-generation.md
    template.md
```

Las tablas existentes te dan el contenido; solo necesitan reestructurarse en el formato [MADR](https://adr.github.io/madr/) o similar.

---

### 🟡 Brecha 4: Diseño visual genérico (Minima default)

**Impacto: MEDIO**

El tema Minima de Jekyll es funcional pero indistinguible de miles de repos. Para un portafolio que se posiciona como "premium" y de "nivel enterprise", el diseño visual no comunica ese nivel. Cualquier visitante lo percibirá como un repo más de documentación.

**Recomendación:** Hay dos caminos:

| Opción | Esfuerzo | Resultado |
|--------|----------|-----------|
| Customizar Minima con CSS overrides (colores, tipografía, hero section) | Bajo | Mejora notable sin cambiar de tema |
| Migrar a un tema más premium (e.g., `just-the-docs`, `chirpy`, o un diseño custom con Vite) | Alto | Diferenciación visual fuerte |

Si quieres mantener Jekyll, al mínimo: un archivo `assets/css/style.scss` con colores de marca, tipografía profesional (Inter/JetBrains Mono), y un hero section en el index que no sea solo texto plano.

---

### 🟡 Brecha 5: Stack Estratégico no presentado como lo prescribe el manifiesto

**Impacto: MEDIO**

Tu manifiesto dice agrupar herramientas "por capacidad" (Analytics Discovery, Gobierno de Datos, AI-Augmented Dev). La sección "Hiring Signals at a Glance" en [index.md](file:///c:/Claude/dchavezf.github.io/index.md#L91-L98) lista el stack como una cadena de texto separada por `·`. Falta la categorización estratégica.

**Recomendación:** Transformar a una tabla o grid visual:

```markdown
| Capacidad | Herramientas |
|-----------|-------------|
| **Data Modeling & Governance** | dbt · Snowflake · BigQuery · Data Vault 2.0 · Kimball |
| **Orchestration & IaC** | Airflow · Terraform · GitHub Actions |
| **AI-Augmented Development** | Claude API · GitHub Copilot · RAG pipelines |
| **Analytics & BI** | Python · SQL · Data visualization |
| **FinOps & Cost Engineering** | Warehouse optimization · incremental strategies |
```

---

### 🟡 Brecha 6: Certificaciones insuficientes vs. el manifiesto

**Impacto: MEDIO**

Tu manifiesto menciona IBM Data Engineering como certificación de alto impacto. Solo listas GitHub Copilot y GitHub Foundations — ambas valiosas pero de nivel foundational. Un Enterprise Data Architect con 22 años de experiencia debería destacar certificaciones más pesadas si las tiene.

**Recomendación:** Si tienes IBM Data Engineering, AWS/GCP/Azure data certifications, Snowflake SnowPro, o dbt Analytics Engineering — agrégalas con badges. Si no las tienes, considera si vale la pena mencionarlas como "in progress" o simplemente eliminar esa expectativa del manifiesto.

---

### 🟡 Brecha 7: Falta un 4to proyecto ancla de aplicación funcional

**Impacto: MEDIO**

Tu manifiesto prescribe 3-4 proyectos, incluyendo uno de *"Aplicación Full-Stack centrada en Metadatos (Local-First/BI)"*. El portafolio actual tiene 3 proyectos y ninguno es una app funcional desplegada. Project 3 (Warehouse Copilot) se acerca pero es más un backend/API que una app completa.

**Recomendación:** Esto es de menor prioridad que terminar los 3 actuales. Pero considera a futuro: un dashboard interactivo o una app de metadata discovery que sea un "data product" visible y usable.

---

### 🟡 Brecha 8: Sin Publicaciones / Liderazgo de Pensamiento

**Impacto: MEDIO**

Tu manifiesto dice: *"GitHub es un excelente lugar para alojar el sitio web (vía GitHub Pages) o fragmentos de la investigación"*. No hay blog, no hay sección de artículos, no hay referencias a publicaciones externas.

**Recomendación:** El site ya usa Jekyll con GitHub Pages — agregar un blog es trivial:
- Crear `_posts/` con artículos tipo ADR largo o case study.
- Por ejemplo: *"Why I chose Medallion + Kimball over Data Vault 2.0 for a 20-country migration"* — el contenido ya está en tus tablas de decisiones, solo necesita formato de artículo.

---

## Problemas Técnicos Menores

| Problema | Archivo | Recomendación |
|----------|---------|---------------|
| No hay `Gemfile` — el build local de Jekyll depende de la máquina del desarrollador | Raíz del proyecto | Agregar `Gemfile` con `gem "minima"` y `gem "jekyll-seo-tag"` para reproducibilidad |
| `table { display: block; }` en [head.html](file:///c:/Claude/dchavezf.github.io/_includes/head.html#L24) puede romper tablas anchas en mobile | `_includes/head.html` | Considerar `overflow-x: auto` solo en un wrapper, no `display: block` en la tabla misma |
| No hay `favicon` — el browser mostrará un error 404 en la consola | Raíz | Agregar un favicon.ico simple |
| No hay `robots.txt` ni `404.html` | Raíz | Jekyll-sitemap genera sitemap pero falta un 404 personalizado |
| SEO meta descriptions son genéricas | Cada `.md` | Agregar `description:` en el frontmatter de cada página de proyecto |
| Mermaid v10 del CDN — considerar pinear versión exacta | `_includes/head.html` | `mermaid@10.9.1` en vez de `mermaid@10` para evitar breaking changes |
| Git history tiene solo 3 commits | — | La historia de commits no cuenta una narrativa; cuando implementes código, los commits deben ser la "diagnostics narrative" prometida |

---

## Plan de Acción Priorizado

### Fase 1: Credibilidad Inmediata (1-2 semanas)
> Objetivo: Eliminar la contradicción "working evidence sin código".

- [ ] **Implementar Project 1 (dbt O2C + MDM)** completo con datos sintéticos seed
- [ ] Agregar `Gemfile` para reproducibilidad del site
- [ ] Crear `.github/workflows/jekyll.yml` (build/deploy del site)
- [ ] Crear `.github/workflows/dbt-ci.yml` (CI del proyecto dbt)
- [ ] Agregar `favicon.ico` y `404.html`

### Fase 2: Rigor Profesional (2-3 semanas)
> Objetivo: Cumplir los estándares de calidad del manifiesto.

- [ ] Extraer ADRs formales en `/docs/adr/` desde las tablas existentes
- [ ] Agregar meta descriptions en el frontmatter de cada proyecto
- [ ] Reorganizar "Hiring Signals" como stack estratégico por capacidad
- [ ] Pinear versión exacta de Mermaid
- [ ] Agregar sección de certificaciones con badges

### Fase 3: Diferenciación Visual (opcional, 1 semana)
> Objetivo: Que el site se vea tan premium como el contenido que contiene.

- [ ] Crear `assets/css/style.scss` con customización de Minima
- [ ] Hero section visual en el index (no solo texto plano)
- [ ] Tipografía profesional (Inter + JetBrains Mono)
- [ ] Paleta de colores de marca consistente

### Fase 4: Expansión (post-lanzamiento de los 3 proyectos)
> Objetivo: Completar el manifiesto al 100%.

- [ ] Implementar Projects 2 y 3
- [ ] Agregar blog (`_posts/`) con 2-3 artículos de liderazgo de pensamiento
- [ ] Considerar un 4to proyecto ancla de app funcional
- [ ] Convertir decisiones arquitectónicas largas en artículos tipo case study

---

## Conclusión

Tienes **el mejor contenido estratégico que he visto en un portafolio de datos**. La narrativa MeridianTrade, las tablas de decisiones, los Definition of Done verificables — todo esto es de primer nivel. Pero el portafolio está al 48% de su potencial porque **falta la evidencia ejecutable** que es precisamente lo que promete.

La recomendación #1, por encima de todas: **implementa Project 1 hasta `dbt build` verde.** Un proyecto completo con código, tests, CI, y un dbt docs site generado automáticamente transformaría este portafolio de "claims" a "evidence" de la noche a la mañana.
