"""
SAP Finance 360 — Airflow DAG for dbt Projects on Snowflake
============================================================
This DAG demonstrates how Apache Airflow orchestrates dbt Projects on Snowflake
using the native EXECUTE DBT PROJECT SQL command. No dbt CLI installation needed
on the Airflow workers — Snowflake manages the dbt runtime.

Prerequisites:
  - A deployed dbt project object: SAP_FINANCE_360.DBT_PROJECTS.SAP_FINANCE_GOLD
  - Apache Airflow with apache-airflow-providers-snowflake installed
  - A Snowflake connection configured in Airflow (conn_id: snowflake_sap_finance)
    with ACCOUNTADMIN role and LOAD_WH warehouse

Architecture:
  Airflow Scheduler → SQLExecuteQueryOperator → EXECUTE DBT PROJECT → Snowflake
"""

from datetime import datetime
from airflow import DAG
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator

# ---------------------------------------------------------------------------
# DAG Definition
# ---------------------------------------------------------------------------
with DAG(
    dag_id="sap_finance_360_dbt_pipeline",
    description="Silver-to-gold transformation using dbt Projects on Snowflake",
    start_date=datetime(2025, 1, 1),
    schedule="0 6 * * *",  # Daily at 6 AM
    catchup=False,
    tags=["sap", "finance", "dbt", "snowflake"],
    default_args={
        "conn_id": "snowflake_sap_finance",
        "retries": 1,
    },
) as dag:

    # -----------------------------------------------------------------------
    # Task 1: Run dbt models (silver → gold transformation)
    # -----------------------------------------------------------------------
    dbt_run = SQLExecuteQueryOperator(
        task_id="dbt_run",
        sql="""
            EXECUTE DBT PROJECT SAP_FINANCE_360.DBT_PROJECTS.SAP_FINANCE_GOLD
            ARGS = 'run --target prod';
        """,
    )

    # -----------------------------------------------------------------------
    # Task 2: Run dbt tests (data quality validation)
    # -----------------------------------------------------------------------
    dbt_test = SQLExecuteQueryOperator(
        task_id="dbt_test",
        sql="""
            EXECUTE DBT PROJECT SAP_FINANCE_360.DBT_PROJECTS.SAP_FINANCE_GOLD
            ARGS = 'test --target prod';
        """,
    )

    # -----------------------------------------------------------------------
    # Task 3: Run with dynamic ENV_VARS (demonstrates per-run parameterization)
    # Airflow macros like {{ ds }} are resolved at runtime before sending to SF
    # -----------------------------------------------------------------------
    dbt_run_with_vars = SQLExecuteQueryOperator(
        task_id="dbt_run_with_env_vars",
        sql="""
            EXECUTE DBT PROJECT SAP_FINANCE_360.DBT_PROJECTS.SAP_FINANCE_GOLD
            ARGS = 'run --target prod'
            ENV_VARS = (
                'DBT_RUN_DATE' = '{{ ds }}',
                'DBT_TRIGGERED_BY' = 'airflow_scheduler'
            );
        """,
    )

    # -----------------------------------------------------------------------
    # DAG dependency graph
    # -----------------------------------------------------------------------
    dbt_run >> dbt_test
    dbt_run_with_vars  # Independent task showing ENV_VARS usage
