# Project 2 — Multi-Source Ingestion Platform Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a config-driven multi-source ingestion platform with Airflow orchestration, Terraform IaC, data contracts, and CI/CD — extracting from 20 regional SQL Server ERPs into a governed data lake and warehouse.

**Architecture:** A single parametrized DAG factory generates per-region Airflow DAGs from YAML configs. Each DAG follows the shape `extract → validate_contract → load → freshness_check`. Terraform modules provision all infrastructure (buckets, warehouse schemas, secrets, alerting). Data contracts validate schemas at the lake-to-warehouse boundary. GitHub Actions enforce quality gates on every PR.

**Tech Stack:** Apache Airflow · Terraform · Python · S3/GCS (MinIO locally) · Snowflake/BigQuery · Docker · GitHub Actions · Great Expectations · Parquet

**Spec:** [Project 2 — Airflow + Terraform](/projects/airflow-iac-pipeline/)
**Business Case:** [MeridianTrade Platform Transformation](/projects/transformation-business-case/)
**ADRs:** [ADR-004](/docs/adr/ADR-004-config-driven-dag-factory/) · [ADR-009](/docs/adr/ADR-009-version-controlled-data-factory/) · [ADR-010](/docs/adr/ADR-010-institutional-knowledge-as-governed-code/)

---

## Repository Structure

The code lives in a dedicated repository: `github.com/dchavezf/ingestion-platform` (to be created). The portfolio page at `projects/airflow-iac-pipeline.md` links to it.

```
ingestion-platform/
├── README.md
├── pyproject.toml
├── Makefile
├── docker-compose.yml
├── Dockerfile
├── .github/
│   └── workflows/
│       ├── ci.yml
│       ├── terraform-plan.yml
│       └── terraform-apply.yml
├── configs/
│   └── regions/
│       ├── region_a.yml
│       ├── region_b.yml
│       └── region_c.yml
├── contracts/
│   ├── customers_v1.yml
│   ├── orders_v1.yml
│   └── order_items_v1.yml
├── dags/
│   ├── __init__.py
│   ├── dag_factory.py
│   └── tasks/
│       ├── __init__.py
│       ├── extract.py
│       ├── validate_contract.py
│       ├── load.py
│       └── freshness_check.py
├── lib/
│   ├── __init__.py
│   ├── watermark.py
│   ├── parquet_writer.py
│   ├── contract_validator.py
│   └── alerting.py
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── environments/
│   │   ├── dev.tfvars
│   │   ├── staging.tfvars
│   │   └── prod.tfvars
│   └── modules/
│       ├── storage/
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── outputs.tf
│       ├── warehouse/
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── outputs.tf
│       ├── secrets/
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── outputs.tf
│       └── alerting/
│           ├── main.tf
│           ├── variables.tf
│           └── outputs.tf
├── seeds/
│   ├── sql/
│   │   ├── create_erp_schema.sql
│   │   └── seed_erp_data.sql
│   └── expected/
│       ├── region_a_customers.parquet
│       └── region_a_orders.parquet
├── tests/
│   ├── conftest.py
│   ├── unit/
│   │   ├── test_dag_factory.py
│   │   ├── test_extract.py
│   │   ├── test_validate_contract.py
│   │   ├── test_load.py
│   │   ├── test_watermark.py
│   │   └── test_contract_validator.py
│   └── integration/
│       ├── test_end_to_end.py
│       └── test_idempotency.py
├── docker/
│   ├── airflow/
│   │   └── Dockerfile
│   └── sqlserver/
│       ├── Dockerfile
│       └── init.sql
└── docs/
    ├── runbook.md
    ├── onboarding.md
    └── local-development.md
```

---

## Definition of Done (from spec)

Every task in this plan traces back to one or more of these verifiable acceptance criteria:

1. **Zero-to-provisioned:** `terraform apply` provisions everything from zero with no console steps.
2. **Idempotency:** Kill-and-rerun test yields identical row counts and checksums.
3. **Region-per-hour:** Region-3 onboarding executed with only a new YAML file, timed under 1 hour.
4. **Contract quarantine:** A simulated breaking schema change is quarantined with an alert.
5. **CI gates:** CI blocks broken DAGs, failed tests, invalid Terraform, and unlabeled destructive plans.

---

## Phase 1: Repository Skeleton and Local Development Environment

**Goal:** Create the repository structure, Docker Compose local stack (Airflow + MinIO + SQL Server), and a working `docker-compose up` that gives engineers a running platform.

**Acceptance criteria:** `docker-compose up` starts Airflow webserver, scheduler, MinIO (S3-compatible), and a seeded SQL Server instance. The Airflow UI is reachable at `localhost:8080`.

### Task 1.1: Repository Bootstrap

**Files:**
- Create: `README.md`, `pyproject.toml`, `Makefile`, `.gitignore`, `.env.example`

- [ ] **Step 1: Create repository and initialize Python project**

Create the repository with:
- `pyproject.toml` declaring dependencies: `apache-airflow[postgres]==2.9.*`, `pyodbc`, `pyarrow`, `pandas`, `great-expectations`, `boto3`, `pyyaml`, `pytest`, `pytest-mock`
- `.gitignore` excluding `__pycache__/`, `.env`, `_site/`, `*.egg-info/`, `.terraform/`, `*.tfstate*`, `.venv/`
- `.env.example` with placeholder values for all connection strings

- [ ] **Step 2: Create Makefile with standard targets**

```makefile
.PHONY: setup up down test lint format terraform-plan terraform-apply seed

setup:
	pip install -e ".[dev]"
	docker-compose build

up:
	docker-compose up -d

down:
	docker-compose down -v

test:
	pytest tests/unit -v

test-integration:
	pytest tests/integration -v

lint:
	ruff check dags/ lib/ tests/
	terraform fmt -check terraform/

format:
	ruff format dags/ lib/ tests/
	terraform fmt terraform/

terraform-plan:
	terraform -chdir=terraform plan -var-file=environments/dev.tfvars

terraform-apply:
	terraform -chdir=terraform apply -var-file=environments/dev.tfvars

seed:
	docker-compose exec sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$$MSSQL_SA_PASSWORD" -i /seeds/create_erp_schema.sql
	docker-compose exec sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$$MSSQL_SA_PASSWORD" -i /seeds/seed_erp_data.sql
```

### Task 1.2: Docker Compose Local Stack

**Files:**
- Create: `docker-compose.yml`, `docker/airflow/Dockerfile`, `docker/sqlserver/Dockerfile`, `docker/sqlserver/init.sql`

- [ ] **Step 1: Define Docker Compose services**

Services:
- **postgres** — Airflow metadata database (postgres:15)
- **minio** — S3-compatible object storage (minio/minio), ports 9000/9001, pre-created `raw` and `quarantine` buckets via init container
- **sqlserver** — Source ERP simulation (mcr.microsoft.com/mssql/server:2022-latest), seeded with multi-region schema and sample data
- **airflow-init** — one-shot container to run `airflow db migrate` and create admin user
- **airflow-webserver** — port 8080
- **airflow-scheduler** — runs DAG parsing and task execution

All Airflow containers mount `./dags:/opt/airflow/dags`, `./configs:/opt/airflow/configs`, `./contracts:/opt/airflow/contracts`, `./lib:/opt/airflow/lib`.

Environment variables: `AIRFLOW__CORE__DAGS_FOLDER`, `AIRFLOW__CORE__LOAD_EXAMPLES=False`, `AIRFLOW_CONN_MINIO`, `AIRFLOW_CONN_SQLSERVER`, `AIRFLOW_CONN_SNOWFLAKE` (placeholder).

- [ ] **Step 2: Create Airflow Dockerfile**

Based on `apache/airflow:2.9.*-python3.11`. Install: `pyodbc`, `pyarrow`, `pandas`, `great-expectations`, `boto3`, `pyyaml`, `snowflake-connector-python`. Install MSODBC driver for SQL Server.

- [ ] **Step 3: Create SQL Server seed scripts**

`docker/sqlserver/init.sql`:
- Create schema `erp_region_a`, `erp_region_b`, `erp_region_c`
- Each schema contains tables: `clientes` (customer_id, name, tax_id, region, created_at, updated_at), `ordenes` (order_id, customer_id, order_date, ship_date, invoice_date, amount, currency, status, updated_at), `order_items` (item_id, order_id, product_id, quantity, unit_price, discount)
- Watermark columns (`updated_at`) on all tables for incremental extraction

`seeds/sql/seed_erp_data.sql`:
- Insert 50+ customers per region with overlapping IDs (customer 1001 in region_a is different from 1001 in region_b)
- Insert 200+ orders per region with realistic statuses and dates
- Insert order items with realistic quantities and prices

### Task 1.3: Verify Local Stack

**Files:**
- Verify: `docker-compose.yml`

- [ ] **Step 1: Build and start all services**

```bash
docker-compose build
docker-compose up -d
```

Expected: All containers start. `docker-compose ps` shows 5 running services.

- [ ] **Step 2: Verify Airflow UI access**

Open `http://localhost:8080` (admin/admin). Expected: Airflow UI loads with no DAGs yet.

- [ ] **Step 3: Verify MinIO access**

Open `http://localhost:9001` (minioadmin/minioadmin). Expected: Two buckets exist: `raw` and `quarantine`.

- [ ] **Step 4: Verify SQL Server seed data**

```bash
docker-compose exec sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -Q "SELECT COUNT(*) FROM erp_region_a.clientes"
```

Expected: Returns 50+ rows per region.

---

## Phase 2: Terraform Infrastructure Modules

**Goal:** Create reusable Terraform modules that provision the complete infrastructure from code. Locally, these target MinIO and a local Snowflake/DuckDB substitute; the same modules target real cloud with different tfvars.

**Acceptance criteria:** `terraform apply -var-file=environments/dev.tfvars` provisions storage buckets, warehouse schemas, secrets, and alerting channels from zero with no console steps (DoD #1).

### Task 2.1: Terraform Module — Storage

**Files:**
- Create: `terraform/modules/storage/main.tf`, `variables.tf`, `outputs.tf`

- [ ] **Step 1: Define storage module**

Resources:
- Raw data bucket: `raw-{environment}` with versioning, lifecycle rules (transition to cold storage after 90 days in prod)
- Quarantine bucket: `quarantine-{environment}` for contract-violation batches
- Both buckets use S3-compatible API (MinIO locally, S3/GCS in cloud)

Variables: `environment`, `project_name`, `storage_backend` (local/s3/gcs), `cold_storage_transition_days`

Outputs: `raw_bucket_name`, `raw_bucket_arn`, `quarantine_bucket_name`, `quarantine_bucket_arn`

### Task 2.2: Terraform Module — Warehouse

**Files:**
- Create: `terraform/modules/warehouse/main.tf`, `variables.tf`, `outputs.tf`

- [ ] **Step 1: Define warehouse module**

Resources (Snowflake provider, with DuckDB fallback for local dev):
- Database: `{project_name}_{environment}`
- Schemas: `raw`, `silver`, `gold`
- Roles: `ingestion_writer`, `transformation_reader`, `transformation_writer`
- Grants: `ingestion_writer` gets `USAGE` on `raw` schema and `CREATE TABLE`; `transformation_reader` gets `SELECT` on `raw`; `transformation_writer` gets `USAGE` on `silver` and `gold`
- Storage integration for external stage (S3/GCS → warehouse COPY INTO)

Variables: `environment`, `project_name`, `warehouse_provider` (snowflake/bigquery/duckdb), `raw_bucket_url`

Outputs: `database_name`, `raw_schema`, `ingestion_role`, `storage_integration_name`

### Task 2.3: Terraform Module — Secrets

**Files:**
- Create: `terraform/modules/secrets/main.tf`, `variables.tf`, `outputs.tf`

- [ ] **Step 1: Define secrets module**

Resources:
- Secret entries for each regional ERP connection (host, port, database, username, password)
- Secret for warehouse connection
- Secret for MinIO/S3 access keys
- All secrets referenced by Airflow connection IDs, never hardcoded

Variables: `environment`, `regions` (list of region objects with connection metadata), `secret_backend` (env/local/aws-secrets-manager/gcp-secret-manager)

Outputs: `airflow_connection_ids` (map of region → connection ID)

### Task 2.4: Terraform Module — Alerting

**Files:**
- Create: `terraform/modules/alerting/main.tf`, `variables.tf`, `outputs.tf`

- [ ] **Step 1: Define alerting module**

Resources:
- PagerDuty service (or webhook endpoint for local dev)
- SLA breach alert: triggered when DAG misses SLA deadline
- Contract violation alert: triggered when quarantine receives a batch
- Freshness alert: triggered when data freshness exceeds threshold

Variables: `environment`, `alert_backend` (pagerduty/webhook/slack), `sla_threshold_minutes`, `freshness_threshold_hours`

Outputs: `pagerduty_service_id`, `alert_webhook_url`

### Task 2.5: Root Terraform Configuration and Environments

**Files:**
- Create: `terraform/main.tf`, `terraform/variables.tf`, `terraform/outputs.tf`
- Create: `terraform/environments/dev.tfvars`, `terraform/environments/staging.tfvars`, `terraform/environments/prod.tfvars`

- [ ] **Step 1: Compose root module**

The root `main.tf` calls all four modules with environment-specific variables. Provider configuration uses `required_providers` for `aws` (or `google`), `snowflake`, and `null` (for local fallbacks).

- [ ] **Step 2: Define environment tfvars**

`dev.tfvars`:
- `environment = "dev"`
- `storage_backend = "local"` (MinIO)
- `warehouse_provider = "duckdb"`
- `secret_backend = "env"`
- `alert_backend = "webhook"`
- `regions = [{ name = "region_a", ... }, { name = "region_b", ... }]`

`staging.tfvars`:
- `environment = "staging"`
- `storage_backend = "s3"`
- `warehouse_provider = "snowflake"`
- `regions` includes 3 regions

`prod.tfvars`:
- `environment = "prod"`
- `storage_backend = "s3"`
- `warehouse_provider = "snowflake"`
- `regions` includes all 20 regions
- `sla_threshold_minutes = 60`
- `freshness_threshold_hours = 4`

- [ ] **Step 3: Run terraform init and plan for dev**

```bash
terraform -chdir=terraform init
terraform -chdir=terraform plan -var-file=environments/dev.tfvars
```

Expected: Plan shows bucket creation, DuckDB schema setup, environment-variable secrets, and webhook alerting. No errors.

- [ ] **Step 4: Apply dev environment**

```bash
terraform -chdir=terraform apply -var-file=environments/dev.tfvars -auto-approve
```

Expected: All resources created. MinIO buckets exist. DuckDB schemas and roles created. (DoD #1: zero-to-provisioned)

### Task 2.6: Terraform Validation

**Files:**
- Verify: `terraform/`

- [ ] **Step 1: Run terraform validate**

```bash
terraform -chdir=terraform validate
```

Expected: Success with no errors.

- [ ] **Step 2: Run terraform fmt check**

```bash
terraform -chdir=terraform fmt -check -recursive
```

Expected: All files formatted correctly.

- [ ] **Step 3: Verify destroy and re-apply**

```bash
terraform -chdir=terraform destroy -var-file=environments/dev.tfvars -auto-approve
terraform -chdir=terraform apply -var-file=environments/dev.tfvars -auto-approve
```

Expected: Full destroy and re-apply succeed with no manual steps. (DoD #1 reinforced)

---

## Phase 3: Python Extraction Library

**Goal:** Build the reusable Python library that handles watermark-based incremental extraction from SQL Server, Parquet writing, and S3/MinIO upload.

**Acceptance criteria:** Unit tests pass for all extraction functions. Integration test extracts from seeded SQL Server, writes partitioned Parquet to MinIO, and verifies row counts.

### Task 3.1: Watermark Manager

**Files:**
- Create: `lib/watermark.py`
- Create: `tests/unit/test_watermark.py`

- [ ] **Step 1: Implement WatermarkManager class**

```python
class WatermarkManager:
    """Manages incremental extraction watermarks per region/entity."""

    def __init__(self, metadata_store: str):
        """Initialize with path to watermark metadata (JSON file or DB table)."""

    def get_last_watermark(self, region: str, entity: str) -> datetime | None:
        """Return the last successful watermark value, or None for first run."""

    def update_watermark(self, region: str, entity: str, new_watermark: datetime) -> None:
        """Persist the new watermark after successful load."""

    def get_extraction_query(self, table: str, watermark_column: str, last_watermark: datetime | None) -> str:
        """Generate SQL query with WHERE clause for incremental extraction."""
```

Watermark metadata stored as a JSON file locally (`watermarks.json`), with a DuckDB table option for production.

- [ ] **Step 2: Write unit tests**

Test cases:
- First run (no watermark) returns full extraction query
- Subsequent run returns `WHERE updated_at > '{last_watermark}'`
- Watermark update persists correctly
- Concurrent region/entity watermarks are isolated

### Task 3.2: Parquet Writer

**Files:**
- Create: `lib/parquet_writer.py`
- Create: `tests/unit/test_parquet_writer.py`

- [ ] **Step 1: Implement ParquetWriter class**

```python
class ParquetWriter:
    """Writes extracted DataFrames to partitioned Parquet on S3/MinIO."""

    def __init__(self, s3_client, bucket: str):
        """Initialize with boto3 S3 client and target bucket."""

    def write(self, df: pd.DataFrame, region: str, entity: str, load_date: str) -> str:
        """Write DataFrame to s3://{bucket}/raw/region={region}/entity={entity}/load_date={load_date}/data.parquet
        Returns the S3 path written."""

    def compute_checksum(self, s3_path: str) -> str:
        """Compute MD5 checksum of the written Parquet file for idempotency verification."""
```

Partition scheme: `raw/region={region}/entity={entity}/load_date={YYYY-MM-DD}/data.parquet`

Key behavior: partition-overwrite semantics — writing to the same partition replaces the previous file, enabling safe re-runs.

- [ ] **Step 2: Write unit tests**

Test cases:
- Writes Parquet with correct partition path
- Overwrites existing partition (idempotency)
- Checksum is deterministic for identical data
- Handles empty DataFrames gracefully

### Task 3.3: Extraction Task

**Files:**
- Create: `dags/tasks/extract.py`
- Create: `tests/unit/test_extract.py`

- [ ] **Step 1: Implement extract task function**

```python
def extract_from_source(
    connection_id: str,
    region: str,
    entity: str,
    schema: str,
    table: str,
    watermark_column: str,
    **context
) -> dict:
    """Airflow task: extract incremental data from SQL Server source.

    Returns dict with: s3_path, row_count, watermark_value, checksum.
    """
```

Uses `WatermarkManager` to get the last watermark, builds the incremental query, executes via `pyodbc`, writes to Parquet via `ParquetWriter`, updates watermark on success.

Connection managed via Airflow's connection store (never hardcoded credentials).

- [ ] **Step 2: Write unit tests**

Test cases:
- Extracts correct incremental slice based on watermark
- Returns expected metadata dict (path, row_count, watermark, checksum)
- Handles empty result set (no new rows since last watermark)
- Connection failure raises retryable exception

### Task 3.4: Alerting Callbacks

**Files:**
- Create: `lib/alerting.py`
- Create: `tests/unit/test_alerting.py`

- [ ] **Step 1: Implement alerting callbacks**

```python
def on_sla_miss(dag, task_list, blocking_task_list, slas, blocking_tis):
    """Callback for Airflow SLA misses. Sends alert to configured backend."""

def on_failure_callback(context):
    """Callback for task failures. Includes task metadata, region, entity in alert."""

def on_contract_violation(region: str, entity: str, violations: list[dict]):
    """Called when data contract validation fails. Quarantines batch and alerts."""
```

Alert backends: PagerDuty (prod), webhook (staging), log-only (dev). Selected via environment variable.

---

## Phase 4: Data Contracts

**Goal:** Define versioned YAML schemas per entity and implement validation at the lake-to-warehouse boundary. Breaking changes quarantine the batch; additive changes load with a warning.

**Acceptance criteria:** A simulated breaking schema change is quarantined with an alert (DoD #4).

### Task 4.1: Contract Schema Definition

**Files:**
- Create: `contracts/customers_v1.yml`, `contracts/orders_v1.yml`, `contracts/order_items_v1.yml`

- [ ] **Step 1: Define contract YAML format**

```yaml
entity: customers
version: 1
columns:
  - name: customer_id
    type: integer
    nullable: false
    description: "Natural key from source ERP"
  - name: name
    type: string
    nullable: false
  - name: tax_id
    type: string
    nullable: true
  - name: region
    type: string
    nullable: false
  - name: created_at
    type: timestamp
    nullable: false
  - name: updated_at
    type: timestamp
    nullable: false
breaking_changes:
  - column_removed
  - type_narrowing
  - nullable_to_not_null
additive_changes:
  - column_added
  - type_widening
```

- [ ] **Step 2: Create contracts for all three entities**

Define `customers_v1.yml`, `orders_v1.yml`, `order_items_v1.yml` with realistic column definitions matching the SQL Server seed schema.

### Task 4.2: Contract Validator

**Files:**
- Create: `lib/contract_validator.py`
- Create: `tests/unit/test_contract_validator.py`

- [ ] **Step 1: Implement ContractValidator class**

```python
class ContractValidator:
    """Validates a Parquet file's schema against a versioned contract."""

    def __init__(self, contracts_dir: str):
        """Load all contracts from the contracts directory."""

    def validate(self, entity: str, parquet_path: str) -> ValidationResult:
        """Compare Parquet schema against contract.
        Returns ValidationResult with:
        - is_valid: bool (True if no breaking changes)
        - violations: list of breaking changes
        - warnings: list of additive changes
        """

    def quarantine(self, s3_path: str, region: str, entity: str, violations: list) -> str:
        """Move the Parquet file from raw/ to quarantine/ and return quarantine path."""
```

Validation logic:
- Read Parquet schema via `pyarrow`
- Compare each column against contract definition
- Detect: column removed, type narrowing, nullable-to-not-null (breaking); column added, type widening (additive)
- Breaking → quarantine + alert; additive → load with warning logged

- [ ] **Step 2: Write unit tests**

Test cases:
- Valid Parquet matching contract exactly → `is_valid=True`, no violations
- Parquet with missing column → `is_valid=False`, violation listed
- Parquet with new column → `is_valid=True`, warning listed
- Parquet with type change (int → string) → `is_valid=False`, type narrowing violation
- Quarantine moves file to correct quarantine path

### Task 4.3: Validate Contract Airflow Task

**Files:**
- Create: `dags/tasks/validate_contract.py`

- [ ] **Step 1: Implement validate_contract task**

```python
def validate_contract_task(
    region: str,
    entity: str,
    s3_path: str,
    contracts_dir: str,
    **context
) -> dict:
    """Airflow task: validate extracted Parquet against data contract.

    On success: returns validation result with warnings (if any).
    On breaking violation: quarantines file, alerts, raises AirflowException.
    """
```

Uses `ContractValidator`. On breaking violation, calls `quarantine()` and `on_contract_violation()`, then raises `AirflowException` to fail the DAG and prevent downstream load.

### Task 4.4: Contract Quarantine Verification

**Files:**
- Create: `tests/integration/test_quarantine.py`

- [ ] **Step 1: Write integration test for contract quarantine**

Test flow:
1. Extract data from SQL Server (valid)
2. Modify the Parquet schema to simulate a breaking change (remove a column)
3. Run validate_contract task
4. Assert: file moved to quarantine bucket
5. Assert: alert fired (check webhook received payload)
6. Assert: downstream load task was NOT executed

(DoD #4: contract quarantine)

---

## Phase 5: DAG Factory

**Goal:** Implement the config-driven DAG factory that generates per-region DAGs from YAML configs. Each DAG follows the shape `extract → validate_contract → load → freshness_check`, with entities in parallel and regions fully independent.

**Acceptance criteria:** Adding `configs/regions/region_c.yml` and restarting Airflow produces a new DAG `dag_ingest_region_c` with no code changes (DoD #3).

### Task 5.1: Region Config Schema

**Files:**
- Create: `configs/regions/region_a.yml`, `configs/regions/region_b.yml`, `configs/regions/region_c.yml`

- [ ] **Step 1: Define region config schema**

```yaml
region: region_a
connection_id: sqlserver_region_a
schedule: "0 2 * * *"  # 2 AM daily
sla_minutes: 120
entities:
  - name: customers
    schema: erp_region_a
    table: clientes
    watermark_column: updated_at
    contract: customers_v1
  - name: orders
    schema: erp_region_a
    table: ordenes
    watermark_column: updated_at
    contract: orders_v1
  - name: order_items
    schema: erp_region_a
    table: order_items
    watermark_column: updated_at
    contract: order_items_v1
freshness_threshold_hours: 26
alert_channel: pagerduty
```

- [ ] **Step 2: Create configs for three regions**

`region_a.yml`, `region_b.yml`, `region_c.yml` — each with different connection IDs, schemas, and entity mappings reflecting realistic regional ERP variations.

### Task 5.2: DAG Factory Implementation

**Files:**
- Create: `dags/dag_factory.py`
- Create: `tests/unit/test_dag_factory.py`

- [ ] **Step 1: Implement the DAG factory**

```python
def generate_dag(config_path: str) -> DAG:
    """Generate an Airflow DAG from a region YAML config.

    DAG shape per region:
    - For each entity (parallel):
        extract → validate_contract → load → freshness_check
    - All entities run in parallel (no cross-entity dependencies)
    - SLA set from config
    - on_failure_callback and sla_miss_callback configured
    """
```

Implementation:
- Read YAML config
- Create DAG with `dag_id=f"dag_ingest_{region}"`, schedule from config, SLA from config
- For each entity, create a task chain: `extract_task >> validate_task >> load_task >> freshness_task`
- Entity chains are independent (parallel)
- Attach `on_failure_callback` and `sla_miss_callback` from `lib/alerting.py`

- [ ] **Step 2: Implement DAG auto-discovery**

At the bottom of `dag_factory.py`:

```python
import glob
for config_file in glob.glob("/opt/airflow/configs/regions/*.yml"):
    dag = generate_dag(config_file)
    globals()[dag.dag_id] = dag
```

- [ ] **Step 3: Write unit tests**

Test cases:
- Factory generates correct DAG ID from config
- DAG has correct number of tasks (4 per entity × N entities)
- Tasks are chained correctly (extract → validate → load → freshness)
- Entity tasks are independent (parallel)
- SLA is set from config
- Invalid config raises descriptive error
- DAG is parseable by Airflow's DagBag

### Task 5.3: Load and Freshness Tasks

**Files:**
- Create: `dags/tasks/load.py`
- Create: `dags/tasks/freshness_check.py`
- Create: `tests/unit/test_load.py`

- [ ] **Step 1: Implement load task**

```python
def load_to_warehouse(
    region: str,
    entity: str,
    s3_path: str,
    warehouse_conn_id: str,
    target_schema: str = "raw",
    **context
) -> dict:
    """Airflow task: COPY Parquet from S3 into warehouse raw schema.

    Uses partition-overwrite semantics: replaces the target partition.
    Returns dict with: target_table, row_count, checksum.
    """
```

For local dev: reads Parquet and writes to DuckDB. For prod: generates and executes `COPY INTO` SQL for Snowflake/BigQuery.

- [ ] **Step 2: Implement freshness check task**

```python
def check_freshness(
    region: str,
    entity: str,
    warehouse_conn_id: str,
    target_schema: str = "raw",
    threshold_hours: float = 26,
    **context
) -> dict:
    """Airflow task: verify that the loaded data is fresh enough.

    Checks MAX(updated_at) in the target table.
    Raises AirflowException if freshness exceeds threshold.
    """
```

- [ ] **Step 3: Write unit tests**

Load test cases:
- Loads Parquet into correct schema.table
- Partition overwrite replaces previous data
- Returns correct row count and checksum

Freshness test cases:
- Fresh data passes
- Stale data raises AirflowException
- Threshold is configurable per region

### Task 5.4: DAG Factory Verification

**Files:**
- Verify: `dags/dag_factory.py`, `configs/regions/`

- [ ] **Step 1: Start Airflow and verify DAGs appear**

```bash
docker-compose restart airflow-scheduler airflow-webserver
```

Expected: Three DAGs visible in Airflow UI: `dag_ingest_region_a`, `dag_ingest_region_b`, `dag_ingest_region_c`.

- [ ] **Step 2: Trigger region_a DAG manually**

Trigger from Airflow UI. Expected: All three entity chains run in parallel, each completing extract → validate → load → freshness.

- [ ] **Step 3: Verify region onboarding (DoD #3)**

Create `configs/regions/region_d.yml` with a new region config. Restart Airflow scheduler. Expected: `dag_ingest_region_d` appears in the UI within the DAG parse interval. Time from config creation to DAG visible: under 5 minutes (the "under 1 hour" DoD includes connection setup, which is a YAML entry + Airflow connection).

---

## Phase 6: Idempotency and Backfill

**Goal:** Ensure that re-running any extraction window produces identical final state. Backfills are safe by construction.

**Acceptance criteria:** Kill-and-rerun test yields identical row counts and checksums (DoD #2).

### Task 6.1: Idempotency Test

**Files:**
- Create: `tests/integration/test_idempotency.py`

- [ ] **Step 1: Write kill-and-rerun integration test**

Test flow:
1. Run full extraction for region_a (all entities)
2. Record: row counts per entity, checksums per Parquet file, warehouse row counts
3. Delete all Parquet files from MinIO raw bucket
4. Delete all rows from warehouse raw schema
5. Re-run full extraction for region_a
6. Assert: row counts match exactly
7. Assert: checksums match exactly
8. Assert: warehouse row counts match exactly

- [ ] **Step 2: Write partial-rerun test**

Test flow:
1. Run extraction for region_a
2. Modify one entity's data in SQL Server (add 5 new rows with new updated_at)
3. Re-run extraction
4. Assert: only the modified entity has new data
5. Assert: other entities are unchanged
6. Assert: total row count = original + 5

### Task 6.2: Backfill Support

**Files:**
- Modify: `lib/watermark.py`, `dags/tasks/extract.py`

- [ ] **Step 1: Add backfill mode to extraction**

Add a `backfill` parameter to the extract task that accepts a date range (`start_date`, `end_date`) instead of using the watermark. When backfill mode is active:
- Extract uses `WHERE updated_at BETWEEN start_date AND end_date`
- Parquet is written to the specified `load_date` partition
- Watermark is NOT updated (backfill doesn't advance the watermark)

- [ ] **Step 2: Document backfill procedure**

Add to `docs/runbook.md`:
- How to trigger a backfill via Airflow CLI: `airflow dags backfill dag_ingest_region_a --start-date 2026-01-01 --end-date 2026-01-31`
- How to verify backfill completeness
- Safety: backfill never advances watermarks, so regular schedule is unaffected

---

## Phase 7: CI/CD Pipeline

**Goal:** GitHub Actions workflows that enforce quality gates on every PR and automate deployment through dev → staging → prod.

**Acceptance criteria:** CI blocks broken DAGs, failed tests, invalid Terraform, and unlabeled destructive plans (DoD #5).

### Task 7.1: CI Workflow

**Files:**
- Create: `.github/workflows/ci.yml`

- [ ] **Step 1: Define CI workflow**

Triggers: `push` to `main`, `pull_request` to `main`.

Jobs:
1. **lint** — `ruff check dags/ lib/ tests/` + `terraform fmt -check -recursive terraform/`
2. **unit-tests** — `pytest tests/unit -v --tb=short` with coverage report
3. **dag-validation** — Parse all DAGs with Airflow's `DagBag` and assert zero import errors:
   ```python
   from airflow.models import DagBag
   dag_bag = DagBag(dag_folder="dags/", include_examples=False)
   assert len(dag_bag.import_errors) == 0, f"DAG import errors: {dag_bag.import_errors}"
   ```
4. **terraform-validate** — `terraform validate` + `terraform plan` (dev tfvars) with plan output as PR comment
5. **secret-scan** — `gitleaks detect --source . --verbose` to catch hardcoded credentials

All jobs run in parallel. PR merge is blocked if any job fails.

### Task 7.2: Terraform Plan on PR

**Files:**
- Create: `.github/workflows/terraform-plan.yml`

- [ ] **Step 1: Define Terraform plan workflow**

Triggers: `pull_request` when `terraform/**` changes.

Jobs:
1. **terraform-plan** — Run `terraform plan` for each environment (dev, staging, prod)
2. **destructive-change-guard** — Parse plan output for `destroy` actions. If any resource would be destroyed, check for PR label `approved-destructive-change`. If label missing, fail the job with a descriptive error.
3. **plan-comment** — Post plan output as a PR comment for review.

### Task 7.3: Staged Deployment

**Files:**
- Create: `.github/workflows/terraform-apply.yml`

- [ ] **Step 1: Define deployment workflow**

Triggers: `push` to `main` (after merge).

Jobs:
1. **deploy-staging** — `terraform apply -var-file=environments/staging.tfvars -auto-approve`
2. **idempotency-test** — Run kill-and-rerun integration test against staging
3. **deploy-prod** — Requires manual approval (GitHub environment protection rule). `terraform apply -var-file=environments/prod.tfvars -auto-approve`
4. **post-deploy-verify** — Trigger all region DAGs once and verify successful completion

### Task 7.4: CI Verification

**Files:**
- Verify: `.github/workflows/`

- [ ] **Step 1: Verify CI blocks broken DAGs**

Introduce a syntax error in `dags/dag_factory.py`. Push to a PR. Expected: `dag-validation` job fails.

- [ ] **Step 2: Verify CI blocks failed tests**

Break a unit test. Push to a PR. Expected: `unit-tests` job fails.

- [ ] **Step 3: Verify CI blocks invalid Terraform**

Introduce invalid HCL in a module. Push to a PR. Expected: `terraform-validate` job fails.

- [ ] **Step 4: Verify destructive change guard**

Add a resource destruction to a PR without the `approved-destructive-change` label. Expected: `destructive-change-guard` fails.

(DoD #5: CI gates)

---

## Phase 8: Operations Runbook and Documentation

**Goal:** Document operational procedures so the platform is maintainable by a team, not just the original author.

### Task 8.1: Operations Runbook

**Files:**
- Create: `docs/runbook.md`

- [ ] **Step 1: Write runbook sections**

Sections:
- **Backfill procedure** — How to re-extract a date range without affecting watermarks
- **Quarantine triage** — How to investigate a quarantined batch, fix the contract or source, and re-process
- **Credential rotation** — How to rotate ERP passwords via secrets module + Airflow connection update
- **Environment rebuild** — `terraform destroy` + `terraform apply` to recreate any environment from scratch
- **Adding a new region** — Step-by-step: create YAML config, add Airflow connection, run terraform apply, verify DAG appears
- **SLA monitoring** — How to interpret SLA miss alerts and common causes
- **Incident response** — Task-level diagnosis: which region, which entity, which task failed; targeted restart vs full DAG rerun

### Task 8.2: Onboarding Guide

**Files:**
- Create: `docs/onboarding.md`

- [ ] **Step 1: Write onboarding guide**

Sections:
- **Prerequisites** — Docker, Python 3.11+, Terraform, SQL Server client tools
- **Local setup** — `make setup && make up && make seed`
- **Running your first extraction** — Trigger `dag_ingest_region_a` from Airflow UI
- **Understanding the DAG factory** — How YAML configs become DAGs
- **Understanding data contracts** — How to read and write contract YAML
- **Running tests** — `make test` and `make test-integration`

### Task 8.3: Local Development Guide

**Files:**
- Create: `docs/local-development.md`

- [ ] **Step 1: Write local development guide**

Sections:
- Architecture diagram (same Mermaid from the portfolio page)
- How to add a new entity to an existing region
- How to add a new region
- How to test contract violations locally
- How to simulate infrastructure failures

---

## Phase 9: Portfolio Page Update

**Goal:** Update the portfolio page to link to the live repository and reflect implementation status.

### Task 9.1: Update Project Page

**Files:**
- Modify: `projects/airflow-iac-pipeline.md` (in `dchavezf.github.io`)

- [ ] **Step 1: Update code repository link**

Replace:
```markdown
> **Code repository:** 🚧 *implementation in progress — spec-first, the design below is the contract the code will be verified against*
```

With:
```markdown
> **Code repository:** [github.com/dchavezf/ingestion-platform](https://github.com/dchavezf/ingestion-platform)
```

- [ ] **Step 2: Update status section**

Replace the "implementation in progress" status with live status and link to the repository's CI badge.

- [ ] **Step 3: Verify Definition of Done claims**

Run each DoD criterion and document results:
1. `terraform apply` from zero — screenshot or log
2. Kill-and-rerun checksums — test output
3. Region-3 onboarding time — timed execution
4. Contract quarantine — test output
5. CI gates — PR screenshots

---

## Execution Order and Dependencies

```
Phase 1 (Repo + Docker)
    ↓
Phase 2 (Terraform)  ←──→  Phase 3 (Python lib)  [parallel]
    ↓                            ↓
Phase 4 (Contracts) ←────────────┘
    ↓
Phase 5 (DAG Factory) ←── depends on Phases 3 + 4
    ↓
Phase 6 (Idempotency) ←── depends on Phase 5
    ↓
Phase 7 (CI/CD) ←── depends on Phases 2 + 5
    ↓
Phase 8 (Runbook) ←── can start after Phase 5
    ↓
Phase 9 (Portfolio update) ←── last
```

## Estimated Effort

| Phase | Effort | Priority |
|-------|--------|----------|
| Phase 1: Repo + Docker | 1-2 days | Critical path |
| Phase 2: Terraform | 2-3 days | Critical path |
| Phase 3: Python lib | 2-3 days | Critical path (parallel with Phase 2) |
| Phase 4: Contracts | 1-2 days | Critical path |
| Phase 5: DAG Factory | 2-3 days | Critical path |
| Phase 6: Idempotency | 1 day | Critical path |
| Phase 7: CI/CD | 1-2 days | High |
| Phase 8: Runbook | 1 day | Medium |
| Phase 9: Portfolio | 0.5 day | Low |

**Total: 11-17 days** for a single engineer working full-time.
