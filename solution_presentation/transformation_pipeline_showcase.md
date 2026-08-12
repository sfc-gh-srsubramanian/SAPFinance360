# Snowflake Native Transformation Pipelines — SAP Finance 360 Showcase

## For Mosaic: What Snowflake Offers Natively for Data Transformation

---

## Executive Summary

This showcase demonstrates that Snowflake is a **complete data engineering platform** — not just a data warehouse. Using the same SAP Finance dataset (GL line items, supplier invoices, cost centers, profit centers), we run **four parallel pipelines** that each transform silver-layer data into analytics-ready gold tables.

The message: **Snowflake replaces your entire transformation stack** — no Spark clusters, no external schedulers, no separate dbt infrastructure. Everything runs inside Snowflake.

---

## Pipeline 1: Dynamic Tables (Zero-Code Declarative)

### What It Is
Dynamic Tables are Snowflake's declarative transformation layer. You write a SELECT statement; Snowflake handles scheduling, incremental refresh, dependency ordering, and failure recovery.

### Why It Matters for Mosaic
- **Zero orchestration code** — no DAGs, no cron, no task graphs
- **Automatic incremental** — Snowflake determines whether full or incremental refresh is optimal
- **Built-in lineage** — Snowsight shows the full dependency graph automatically
- **TARGET_LAG = 'DOWNSTREAM'** — refresh only when downstream consumers query the table

### What We Built
```
SAP_BDC_L1 (Silver Views)
    ↓ [automatic refresh]
SAP_FINANCE_360.ANALYTICS (6 Dynamic Tables)
    ├── DT_PNL_SUMMARY         — P&L by company/period
    ├── DT_GL_BALANCE          — GL balances (incremental)
    ├── DT_EXPENSE_BY_COSTCENTER — Expense rollups
    ├── DT_REVENUE_BY_PROFITCENTER — Revenue by segment
    ├── DT_AP_AGING            — Accounts Payable aging buckets
    └── DT_JOURNAL_ENTRY_360   — Enriched journal entry fact table
```

### Demo Talking Point
> "We define the transformation once as SQL. Snowflake decides when to refresh, whether to do it incrementally, and manages all the plumbing. No orchestrator. No scheduler. No ops team."

---

## Pipeline 2: dbt Projects on Snowflake (Managed dbt Runtime)

### What It Is
dbt Projects on Snowflake lets you deploy a full dbt project as a **native Snowflake object** — no dbt CLI installation, no Python, no external infrastructure. Snowflake provides managed dbt Core and dbt Fusion runtimes.

### Why It Matters for Mosaic
- **No infrastructure to manage** — Snowflake hosts the dbt runtime
- **Single SQL command** — `EXECUTE DBT PROJECT ... ARGS='run'` runs everything
- **Built-in testing** — dbt's schema tests validate data quality natively
- **Column-level lineage** — visible in Snowsight, powered by Horizon Catalog
- **CI/CD ready** — `snow dbt deploy` in GitHub Actions, GitLab CI, or Azure DevOps
- **Airflow-compatible** — same SQL command works from any orchestrator

### What We Built
```
dbt/sap_finance_gold/
├── profiles.yml                → target: SAP_FINANCE_360.DBT_GOLD
├── models/staging/
│   ├── sources.yml             → 6 L1 silver sources declared
│   ├── stg_gl_line_items.sql   → Universal Journal staging
│   ├── stg_supplier_invoices.sql
│   ├── stg_cost_centers.sql
│   ├── stg_profit_centers.sql
│   └── stg_journal_entries.sql
└── models/gold/
    ├── pnl_summary.sql         → P&L aggregation
    ├── gl_balance.sql          → GL balance by period
    ├── expense_by_costcenter.sql → Expense rollup with department JOIN
    ├── revenue_by_profitcenter.sql → Revenue by segment
    └── schema.yml              → 15 data quality tests
```

**Deployed object:** `SAP_FINANCE_360.DBT_PROJECTS.SAP_FINANCE_GOLD`

### Key Commands
```sql
-- Deploy (from CLI)
snow dbt deploy sap_finance_gold --source ./dbt/sap_finance_gold

-- Execute transformations
EXECUTE DBT PROJECT SAP_FINANCE_360.DBT_PROJECTS.SAP_FINANCE_GOLD
  ARGS = 'run --target prod';

-- Run data quality tests
EXECUTE DBT PROJECT SAP_FINANCE_360.DBT_PROJECTS.SAP_FINANCE_GOLD
  ARGS = 'test --target prod';

-- Schedule with a native Snowflake Task (no Airflow needed)
CREATE TASK task_dbt_run WAREHOUSE = LOAD_WH SCHEDULE = '360 MINUTES'
AS EXECUTE DBT PROJECT ... ARGS = 'run --target prod';
```

### Demo Talking Point
> "dbt is the most popular transformation framework, and now it runs natively inside Snowflake. No dbt Cloud subscription, no Python environment, no worker nodes. Deploy the project, schedule it with a Task, and monitor everything in Snowsight."

---

## Pipeline 3: Streams + Tasks (Real-Time CDC)

### What It Is
Streams capture change data (inserts, updates, deletes) on base tables. Tasks fire automatically when a stream has data, executing MERGE logic to incrementally update gold tables.

### Why It Matters for Mosaic
- **Real-time incremental** — processes only changed rows, not full table scans
- **Event-driven** — `SYSTEM$STREAM_HAS_DATA()` triggers tasks only when needed
- **Task graphs** — parent/child dependencies with automatic ordering
- **MERGE semantics** — upsert pattern handles late-arriving data
- **Visualized in Snowsight** — task graph UI shows execution history and dependencies

### What We Built
```
L0 Base Tables (with CHANGE_TRACKING = TRUE)
    ↓
Streams (append-only CDC)
├── STREAM_GL_LINE_ITEMS      → captures new GL postings
└── STREAM_SUPPLIER_INVOICES  → captures new AP invoices
    ↓
Task Graph (fires every 5 min when stream has data)
├── TASK_PROCESS_GL_BALANCE [root]  → MERGE into GL_BALANCE
│   ├── TASK_PROCESS_PNL [child]    → rebuild P&L summary
│   └── TASK_PROCESS_EXPENSES [child] → rebuild expense rollup
└── TASK_PROCESS_AP_AGING [root]    → rebuild AP aging buckets
    ↓
STREAM_GOLD Schema (4 gold tables with LAST_UPDATED timestamps)
```

### Key Concepts
```sql
-- Stream captures CDC automatically
CREATE STREAM stream_gl ON TABLE l0.operationalacctgdocitem APPEND_ONLY = TRUE;

-- Task fires only when stream has unconsumed rows
CREATE TASK process_gl WAREHOUSE = LOAD_WH SCHEDULE = '5 MINUTES'
  WHEN SYSTEM$STREAM_HAS_DATA('stream_gl')
AS MERGE INTO gold.gl_balance ...;

-- Child task runs after parent completes
CREATE TASK process_pnl AFTER process_gl
AS INSERT OVERWRITE INTO gold.pnl_summary ...;
```

### Demo Talking Point
> "Insert a row into the bronze table. Within 5 minutes, the stream detects it, the root task fires, the MERGE updates the gold table, and the child tasks rebuild downstream aggregations. All visible in the task graph UI. Zero external infrastructure."

---

## Pipeline 4: Airflow Integration (External Orchestrator)

### What It Is
For teams already running Apache Airflow, `EXECUTE DBT PROJECT` is a standard SQL command that any Snowflake connection can issue. No dbt CLI on workers.

### Why It Matters for Mosaic
- **Leverages existing investment** — teams don't abandon Airflow
- **Single SQL API** — both Tasks and Airflow call the same `EXECUTE DBT PROJECT`
- **Cross-system workflows** — Airflow can coordinate Snowflake + S3 + APIs in one DAG
- **No CLI on workers** — `SQLExecuteQueryOperator` sends SQL, Snowflake runs dbt

### What We Built
```python
# airflow/dags/sap_finance_dbt_dag.py
with DAG("sap_finance_360_dbt_pipeline", schedule="0 6 * * *") as dag:
    dbt_run = SQLExecuteQueryOperator(
        task_id="dbt_run",
        sql="EXECUTE DBT PROJECT SAP_FINANCE_360.DBT_PROJECTS.SAP_FINANCE_GOLD ARGS='run --target prod';",
    )
    dbt_test = SQLExecuteQueryOperator(
        task_id="dbt_test",
        sql="EXECUTE DBT PROJECT ... ARGS='test --target prod';",
    )
    dbt_run >> dbt_test
```

### Demo Talking Point
> "If you already run Airflow, you don't need to change anything. The EXECUTE DBT PROJECT SQL command works from any orchestrator. But if you want to eliminate Airflow entirely, the native Snowflake Task does the same thing with zero infrastructure."

---

## Side-by-Side Comparison

| Dimension | Dynamic Tables | dbt Projects | Streams + Tasks | Airflow |
|-----------|:-------------:|:------------:|:---------------:|:-------:|
| **External infra needed** | None | None | None | Airflow cluster |
| **Lines of config** | ~10 per table | ~50 total project | ~100 (streams + tasks) | ~30 (DAG file) |
| **Incremental by default** | Yes (auto) | Configurable | Yes (MERGE) | Depends on dbt config |
| **Data quality tests** | N/A | 15 built-in | Custom SQL | Via dbt |
| **Real-time capable** | Near-real-time | Batch | Real-time (stream-triggered) | Batch |
| **Lineage in Snowsight** | Automatic | Column-level | Task graph view | External UI |
| **CI/CD integration** | N/A | `snow dbt deploy` in GitHub Actions | SQL scripts | Airflow + Git |
| **Best for** | Simple, always-fresh transforms | Complex multi-model projects | Event-driven CDC | Cross-system orchestration |

---

## Key Takeaway for Mosaic

Snowflake is not "just storage + compute." It is a **complete data engineering platform** with:

1. **Dynamic Tables** — declarative, zero-ops transformation
2. **dbt Projects on Snowflake** — managed runtime for the industry-standard framework
3. **Streams + Tasks** — real-time CDC with event-driven execution
4. **EXECUTE DBT PROJECT** — universal SQL API for any orchestrator

All four produce the same gold-layer output. The choice depends on team preference and use case complexity — not on Snowflake's capabilities. There is no transformation workload that requires leaving the platform.

---

## Live Demo Flow (10 minutes)

1. **Show Snowsight** — navigate to `SAP_FINANCE_360` database, show all 4 schemas side-by-side
2. **Dynamic Tables** — click into ANALYTICS, show refresh history and auto-lineage
3. **dbt Projects** — navigate to Transformation > dbt Projects, show run history, DAG, test results
4. **Streams + Tasks** — show task graph visualization, stream status (0 unconsumed rows)
5. **Trigger the stream** — INSERT a test row into L0, show stream goes to 1 row, wait for task to fire
6. **Compare row counts** — run the validation query showing all pipelines produce identical data
7. **Airflow slide** — show the DAG file, explain it's the same SQL command

### Validation Query
```sql
SELECT 'Dynamic Tables' AS pipeline, COUNT(*) AS rows FROM ANALYTICS.DT_PNL_SUMMARY
UNION ALL SELECT 'dbt Projects', COUNT(*) FROM DBT_GOLD_DBT_GOLD.PNL_SUMMARY
UNION ALL SELECT 'Streams + Tasks', COUNT(*) FROM STREAM_GOLD.PNL_SUMMARY;
-- All return 108 rows
```
