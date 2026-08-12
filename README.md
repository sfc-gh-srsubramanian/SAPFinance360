# SAP BDC Finance 360

A reference implementation showing how to turn **SAP Business Data Cloud (BDC)
Standard Data Products** into a live, AI-powered finance analytics app on
Snowflake — using a **medallion (L0/L1/L2) architecture**, a governed
**semantic view**, a **Cortex Agent**, and a self-contained **Snowflake Native
App** (React + Express on Snowpark Container Services), deployable across
multiple regions.

Zero ETL. Zero copy. Full SAP business context preserved.

---

## What's in here

```
sap-bdc-finance-360/
├── sql/                 Medallion + semantic + agent + pipelines (run in order)
│   ├── 00_synthetic_data_generation.sql  Synthetic SAP data for demos
│   ├── 01_infrastructure_and_l1.sql      Database, schemas, L1 views
│   ├── 02_l1_curated_views.sql           L1 silver — SAP_BDC_L1 curated views
│   ├── 03_l2_analytics_dynamic_tables.sql  L2 gold — ANALYTICS dynamic tables
│   ├── 04_semantic_view.sql              SAP_FINANCE_360 semantic view
│   ├── 05_cortex_agent.sql               SAP_FINANCE_360_AGENT
│   ├── 06_streams_and_tasks.sql          Streams + Task Graph pipeline
│   └── 07_dbt_scheduling_task.sql        dbt execution scheduled via Tasks
├── dbt/sap_finance_gold/   dbt project deployed natively to Snowflake
│   ├── dbt_project.yml / profiles.yml
│   └── models/ (staging views + gold tables with tests)
├── airflow/dags/        Reference Airflow DAG (EXECUTE DBT PROJECT)
├── app/                 Native App package (manifest, setup.sql, spec, snowflake.yml)
├── service/app/         React (Vite) client + Express server + Dockerfile
├── scripts/             build_and_push · migrate_data · deploy_native_app · create_org_listing
├── solution_presentation/  Marketing & demo materials
└── docs/                ARCHITECTURE.md · INSTALL.md · DEMO_GUIDE.md · demo deck (.pptx)
```

## Architecture at a glance

`SAP BDC Standard Data Products (L0)` → `SAP_BDC_L1 curated views (L1)` →
`ANALYTICS dynamic tables (L2)` → `SAP_FINANCE_360 semantic view` →
`SAP_FINANCE_360_AGENT` + Native App "Ask the Agent".

Full detail (with diagram and per-table transform logic):
[`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

---

## Transformation Pipeline Showcase

This project demonstrates **four native Snowflake approaches** for silver-to-gold
transformation — side by side, producing equivalent outputs from the same L1
silver layer. Built to show Mosaic what Snowflake offers natively for data
engineering.

### 1. Dynamic Tables (Declarative)

**Schema:** `SAP_FINANCE_360.ANALYTICS`

The simplest path. Define the query once; Snowflake handles scheduling,
refresh, and incremental processing automatically.

- 6 dynamic tables (P&L, GL Balance, Expense, Revenue, AP/AR Aging, Journal Entry 360)
- `TARGET_LAG = 'DOWNSTREAM'` — refresh only when a consumer reads
- Incremental where possible, full refresh for complex JOINs
- Zero orchestration code

**Key SQL:** `sql/03_l2_analytics_dynamic_tables.sql`

### 2. dbt Projects on Snowflake (Managed dbt Runtime)

**Schema:** `SAP_FINANCE_360.DBT_GOLD_DBT_GOLD`

A full dbt project deployed as a native Snowflake object via `CREATE DBT
PROJECT`. No dbt CLI installation, no Python environment, no external
infrastructure. Snowflake manages the dbt Core runtime.

- 5 staging views + 4 gold table models
- 15 data quality tests (not_null, accepted_values)
- Deploy: `snow dbt deploy` or `CREATE DBT PROJECT ... FROM @stage`
- Execute: `EXECUTE DBT PROJECT ... ARGS='run --target prod'`
- Monitor: run history, DAG lineage, and artifacts in Snowsight

**Key files:** `dbt/sap_finance_gold/`  
**Deployed object:** `SAP_FINANCE_360.DBT_PROJECTS.SAP_FINANCE_GOLD`

### 3. Streams + Tasks (CDC-Driven Incremental)

**Schema:** `SAP_FINANCE_360.STREAM_GOLD`

Real-time change data capture using Streams to detect new rows in L0, and a
Task Graph that fires only when data arrives (`SYSTEM$STREAM_HAS_DATA`).

- 2 append-only streams on L0 base tables
- Task graph with MERGE-based incremental logic (GL Balance)
- Child tasks rebuild P&L and Expenses after the root task completes
- Separate root task for AP Aging (independent stream)
- Visualize the task graph in Snowsight

**Key SQL:** `sql/06_streams_and_tasks.sql`

### 4. Airflow + dbt Projects (External Orchestration)

**File:** `airflow/dags/sap_finance_dbt_dag.py`

For teams with existing Airflow infrastructure. The same `EXECUTE DBT PROJECT`
SQL command works via Airflow's `SQLExecuteQueryOperator` — no dbt CLI needed
on workers. Demonstrates:

- Daily scheduled DAG (run → test)
- `ENV_VARS` pass-through for dynamic per-run parameters
- Airflow macros ({{ ds }}) resolved at runtime

The native Snowflake Task alternative is in `sql/07_dbt_scheduling_task.sql`
(same result, zero external infrastructure).

### Comparison Matrix

| Dimension | Dynamic Tables | dbt Projects | Streams + Tasks | Airflow |
|-----------|---------------|--------------|-----------------|---------|
| Infrastructure | None | None | None | Airflow cluster |
| Orchestration | Automatic | Task or Airflow | Event-driven | DAG scheduler |
| Incremental | Built-in | Configurable | Custom MERGE | N/A (calls dbt) |
| Testing | N/A | dbt tests | Custom | dbt tests via SQL |
| Lineage | Automatic | Column-level in Snowsight | Manual | Airflow UI |
| Best for | Simple transforms | Complex projects with tests | Real-time CDC | Cross-system workflows |

---

## Quick start

- **Build the data platform + agent:** run `sql/01` → `sql/05` as
  `ACCOUNTADMIN`, then chat with `SAP_FINANCE_360_AGENT` in Snowflake
  Intelligence.
- **Deploy transformation pipelines:** run `sql/06` and `sql/07` for
  streams/tasks and dbt scheduling.
- **Deploy the Native App:** `build_and_push.sh` → `migrate_data.py` →
  `deploy_native_app.py` → `create_org_listing.py`.

Step-by-step runbook: [`docs/INSTALL.md`](docs/INSTALL.md).

## The app

A React dashboard covering **Overview, General Ledger, Cost Centers, Profit
Centers, Accounts Payable, Accounts Receivable, Period Analysis, BDC Data
Products**, plus an **Ask the Agent** page (Cortex Analyst over the bundled
`SAP_FINANCE_360` semantic view). Company codes: **1000 = US, 2100 = DE,
5000 = JP**.

**Live URL:** https://m2rhg2-sfsenorthamerica-srsubramanian-aws1.snowflakecomputing.app

## Demo

See [`docs/DEMO_GUIDE.md`](docs/DEMO_GUIDE.md) and the slide deck
[`docs/SAP_Finance_360_Demo_Guide.pptx`](docs/SAP_Finance_360_Demo_Guide.pptx)
(15 slides + presenter notes).

For the pipeline showcase demo, see
[`solution_presentation/transformation_pipeline_showcase.md`](solution_presentation/transformation_pipeline_showcase.md).

## Security notes

- No credentials are committed. Scripts read key-pair connections from
  `~/.snowflake/connections.toml` by connection name; `.gitignore` excludes
  `*.p8`, `.env`, and `connections.toml`.
- L0 SAP BDC products are read-only zero-copy shares; the medallion only reads
  from them.

## Sibling projects

Same pattern, other SAP domains:
`sap-bdc-supply-chain-360` · `sap-bdc-people-360` · `sap-bdc-sales-360`
