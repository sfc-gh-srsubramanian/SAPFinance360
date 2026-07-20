-- =============================================================================
-- SAP BDC Finance 360 — Infrastructure & L1 Setup Script
-- =============================================================================
-- Run AFTER: 00_synthetic_data_generation.sql (or after mounting SAP BDC shares)
-- Run BEFORE: 03_l2_analytics_dynamic_tables.sql
--
-- This script:
--   1. Creates the SAP_FINANCE_360 database and schemas
--   2. Creates required warehouses and compute infrastructure
--   3. Creates L1 (silver) curated views pointing at local L0 tables
--
-- If using real SAP BDC shares, replace the L1 view definitions to point at
-- SAP_BDC_DEMO_* databases instead of SAP_FINANCE_360.SAP_BDC_L0.
-- =============================================================================

USE ROLE ACCOUNTADMIN;

-- =============================================================================
-- 1. DATABASE & SCHEMAS
-- =============================================================================
CREATE OR REPLACE DATABASE SAP_FINANCE_360 
  COMMENT='SAP BDC Finance 360 - Medallion architecture demo';

CREATE SCHEMA SAP_FINANCE_360.SAP_BDC_L0 
  COMMENT='L0: Synthetic SAP BDC Standard Data Products (bronze)';

CREATE SCHEMA SAP_FINANCE_360.SAP_BDC_L1 
  COMMENT='L1: Curated views with business-friendly names and comments (silver)';

CREATE SCHEMA SAP_FINANCE_360.ANALYTICS 
  COMMENT='L2: Dynamic tables - analytics-ready joined/enriched data (gold)';

-- =============================================================================
-- 2. WAREHOUSES & COMPUTE
-- =============================================================================
CREATE WAREHOUSE IF NOT EXISTS LOAD_WH 
  WAREHOUSE_SIZE='XSMALL' 
  AUTO_SUSPEND=60 
  AUTO_RESUME=TRUE 
  INITIALLY_SUSPENDED=TRUE 
  COMMENT='Warehouse for SAP Finance 360 dynamic table refresh';

-- =============================================================================
-- 3. IMAGE REPOSITORY & COMPUTE POOL (for Native App)
-- =============================================================================
CREATE IMAGE REPOSITORY IF NOT EXISTS SAP_FINANCE_360.PUBLIC.FINANCE_360_REPO 
  COMMENT='Image repo for Finance 360 Native App container';

CREATE COMPUTE POOL IF NOT EXISTS FINANCE_360_POOL 
  MIN_NODES=1 MAX_NODES=1 
  INSTANCE_FAMILY=CPU_X64_XS 
  AUTO_RESUME=TRUE 
  AUTO_SUSPEND_SECS=300;

-- =============================================================================
-- 4. L1 CURATED VIEWS (pointing at local L0 synthetic tables)
--
-- NOTE: If you have SAP BDC shares mounted, replace these with:
--   CREATE VIEW SAP_BDC_L1.OPERATIONALACCTGDOCITEM AS
--     SELECT * FROM SAP_BDC_DEMO_ENTRY_VIEW_JOURNAL_ENTRY.BDCCONNECT.OPERATIONALACCTGDOCITEM;
--   etc.
-- =============================================================================

CREATE OR REPLACE VIEW SAP_FINANCE_360.SAP_BDC_L1.OPERATIONALACCTGDOCITEM
  COMMENT='GL line items (Universal Journal / ACDOCA) - curated from L0'
AS SELECT * FROM SAP_FINANCE_360.SAP_BDC_L0.OPERATIONALACCTGDOCITEM;

CREATE OR REPLACE VIEW SAP_FINANCE_360.SAP_BDC_L1.JOURNALENTRY
  COMMENT='Accounting document headers - curated from L0'
AS SELECT * FROM SAP_FINANCE_360.SAP_BDC_L0.JOURNALENTRY;

CREATE OR REPLACE VIEW SAP_FINANCE_360.SAP_BDC_L1.SUPPLIERINVOICE
  COMMENT='Supplier (AP) invoices - curated from L0'
AS SELECT * FROM SAP_FINANCE_360.SAP_BDC_L0.SUPPLIERINVOICE;

CREATE OR REPLACE VIEW SAP_FINANCE_360.SAP_BDC_L1.GENERALLEDGERACCOUNT
  COMMENT='GL account master - curated from L0'
AS SELECT * FROM SAP_FINANCE_360.SAP_BDC_L0.GENERALLEDGERACCOUNT;

CREATE OR REPLACE VIEW SAP_FINANCE_360.SAP_BDC_L1.COSTCENTER
  COMMENT='Cost center master - curated from L0'
AS SELECT * FROM SAP_FINANCE_360.SAP_BDC_L0.COSTCENTER;

CREATE OR REPLACE VIEW SAP_FINANCE_360.SAP_BDC_L1.PROFITCENTER
  COMMENT='Profit center master - curated from L0'
AS SELECT * FROM SAP_FINANCE_360.SAP_BDC_L0.PROFITCENTER;
