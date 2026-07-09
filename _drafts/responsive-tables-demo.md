---
layout: post
title: "Responsive Tables Demo"
date: 2026-07-09
categories: [Demo]
tags: [design, responsive]
description: "Visual demonstration of responsive table design on mobile devices"
---

# Responsive Tables Demo

Esta página demuestra cómo las tablas se adaptan automáticamente a dispositivos móviles.

## Tabla 1: Core Expertise

| Area | Evidence |
|------|----------|
| Data Product Management | Product discovery, Design Sprint, stakeholder interviews, KPI storytelling |
| Enterprise Data Architecture | Snowflake, BigQuery, dbt, Kimball, Medallion architecture, MDM |
| Data Engineering | SQL, Python, Airflow, ELT/ETL pipelines, data validation, observability |
| AI Platforms | Claude/RAG automation, governed text-to-SQL, metadata-driven workflows |
| Leadership | Team leadership, executive stakeholder management, delivery planning |

### Comportamiento

**En Desktop (pantalla ≥ 768px):**
- La tabla se muestra normalmente con columnas y filas
- Headers visibles en la parte superior
- Alternancia de colores en las filas para facilitar lectura

**En Móvil (pantalla < 768px):**
- Cada fila se convierte en una tarjeta
- Cada celda muestra el label del header seguido del valor
- Scroll vertical natural sin necesidad de scroll horizontal
- Mejor legibilidad en pantallas pequeñas

## Tabla 2: Professional Experience Timeline

| Empresa | Cargo | Período | Logro Principal |
|---------|-------|---------|-----------------|
| Infovision | Senior Data Solutions Architect | Oct 2025 - Abr 2026 | Plataforma GCP con 500+ microservicios |
| TCS | Data Engineering | Nov 2023 - Ago 2025 | Pipeline ELT de producción en BigQuery |
| Mas por Pieza | Senior Data Solutions Architect | Jul 2023 - Nov 2023 | Discovery empresarial con stakeholders |
| 3M | Data Warehouse Migration Lead | Ene 2022 - Jun 2023 | Migración 10TB a Snowflake sin downtime |

## Tabla 3: Skills Matrix

| Skill | Nivel | Experiencia (años) | Contexto |
|-------|-------|-------------------|----------|
| SQL | Expert | 18+ | Data warehouse, transformation, optimization |
| Python | Advanced | 8+ | Airflow, data processing, APIs |
| Snowflake | Expert | 6+ | Architecture, performance, cost optimization |
| BigQuery | Advanced | 4+ | Pipelines, monitoring, optimization |
| dbt | Advanced | 5+ | Modeling, testing, governance |

## Tips para usar tablas

✅ **Usa tablas cuando:**
- Necesitas mostrar datos tabulares claros
- Hay muchos puntos para comparar
- Datos estructurados en filas/columnas

❌ **Evita tablas cuando:**
- Hay más de 5 columnas (considera dividir)
- El contenido es principalmente descriptivo (usa listas)
- Necesitas mostrar procesos o flows (usa diagramas)

## Prueba en tu navegador

Para ver el comportamiento responsivo:

1. Abre esta página en tu navegador
2. Presiona **F12** para abrir Developer Tools
3. Presiona **Ctrl+Shift+M** para entrar en modo responsive
4. Redimensiona el navegador a menos de 768px de ancho
5. Observa cómo las tablas se convierten en tarjetas

## CSS Behind the Scenes

```scss
@media (max-width: 768px) {
  table {
    display: block;
    border: none;
  }

  table thead {
    display: none;
  }

  table tbody tr {
    display: block;
    margin-bottom: 1rem;
    border: 1px solid var(--color-border-light);
    border-radius: var(--radius-sm);
    padding: 1rem;
  }

  table td {
    display: grid;
    grid-template-columns: minmax(120px, 30%) 1fr;
    gap: 1rem;
  }

  table td::before {
    content: attr(data-label);
    font-weight: 600;
    color: var(--color-primary);
  }
}
```

El plugin Jekyll automáticamente agrega los atributos `data-label` a cada celda con el valor del header correspondiente.

---

**Nota:** Esta es una página de demostración y no se publica en el sitio principal. Para ver ejemplos reales, visita:
- [Resume](/resume/) - Tabla de Core Expertise
- [Projects](/portfolio/) - Tablas de casos de uso
