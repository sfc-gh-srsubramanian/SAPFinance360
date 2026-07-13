# L0 — SAP BDC Standard Data Products (raw / bronze)

The **L0 (bronze)** layer is the set of **SAP Business Data Cloud Standard Data
Products** shared into Snowflake with **zero copy, no ETL**. Finance 360 consumes
six standard products in the `BDCCONNECT` schema of each shared database:

| L0 Source Database | Schema | Object | SAP Meaning |
|--------------------|--------|--------|-------------|
| `SAP_BDC_DEMO_ENTRY_VIEW_JOURNAL_ENTRY` | `BDCCONNECT` | `OPERATIONALACCTGDOCITEM` | GL line items (Universal Journal / ACDOCA) |
| `SAP_BDC_DEMO_JOURNAL_ENTRY_HEADER`     | `BDCCONNECT` | `JOURNALENTRY`            | Accounting document headers |
| `SAP_BDC_DEMO_SUPPLIER_INVOICE`         | `BDCCONNECT` | `SUPPLIERINVOICE`        | Supplier (AP) invoices |
| `SAP_BDC_DEMO_GL_ACCOUNT`               | `BDCCONNECT` | `GENERALLEDGERACCOUNT`   | GL account master |
| `SAP_BDC_DEMO_COST_CENTER`              | `BDCCONNECT` | `COSTCENTER`             | Cost center master |
| `SAP_BDC_DEMO_PROFIT_CENTER`            | `BDCCONNECT` | `PROFITCENTER`           | Profit center master |

## How L0 is provisioned

These databases are created by **mounting the SAP BDC data-product shares** (or
Marketplace / internal listings). No copy of the data is made — Snowflake reads
directly from the provider share.

> In a real SAP BDC tenant these are the governed "Standard Data Products"
> published by SAP. In this demo they are pre-mounted as `SAP_BDC_DEMO_*`
> databases. Nothing in L1/L2 mutates L0 — the medallion only reads from it.

## Design principle

L0 is treated as **read-only, immutable bronze**. All business logic,
enrichment and shaping happens in L1 (silver) and L2 (gold) — see
`02_l1_curated_views.sql` and `03_l2_analytics_dynamic_tables.sql`.
