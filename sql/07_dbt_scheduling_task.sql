-- =============================================================================
-- SAP Finance 360 — Pipeline 3: Native Task Scheduling for dbt Projects
-- =============================================================================
-- Demonstrates scheduling dbt project execution using Snowflake Tasks.
-- This is the zero-infrastructure alternative to Airflow — same EXECUTE DBT
-- PROJECT command, but orchestrated natively by Snowflake.
-- =============================================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE SAP_FINANCE_360;

-- =============================================================================
-- 1. TASK: Run dbt models every 6 hours
-- =============================================================================
CREATE OR REPLACE TASK SAP_FINANCE_360.DBT_PROJECTS.TASK_DBT_RUN
  WAREHOUSE = LOAD_WH
  SCHEDULE = '360 MINUTES'
  COMMENT = 'Scheduled dbt run - transforms silver to gold every 6 hours'
AS
  EXECUTE DBT PROJECT SAP_FINANCE_360.DBT_PROJECTS.SAP_FINANCE_GOLD
  ARGS = 'run --target prod';

-- =============================================================================
-- 2. TASK: Run dbt tests after models complete
-- =============================================================================
CREATE OR REPLACE TASK SAP_FINANCE_360.DBT_PROJECTS.TASK_DBT_TEST
  WAREHOUSE = LOAD_WH
  COMMENT = 'Run dbt tests after models complete - validates data quality'
  AFTER SAP_FINANCE_360.DBT_PROJECTS.TASK_DBT_RUN
AS
  EXECUTE DBT PROJECT SAP_FINANCE_360.DBT_PROJECTS.SAP_FINANCE_GOLD
  ARGS = 'test --target prod';

-- =============================================================================
-- 3. RESUME TASKS (activate the schedule)
-- =============================================================================
ALTER TASK SAP_FINANCE_360.DBT_PROJECTS.TASK_DBT_TEST RESUME;
ALTER TASK SAP_FINANCE_360.DBT_PROJECTS.TASK_DBT_RUN RESUME;

-- =============================================================================
-- VERIFICATION: Check task status
-- =============================================================================
-- SHOW TASKS IN SCHEMA SAP_FINANCE_360.DBT_PROJECTS;
-- SELECT * FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY()) ORDER BY SCHEDULED_TIME DESC LIMIT 10;
