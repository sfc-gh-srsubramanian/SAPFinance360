# About SAP BDC Finance 360

## For Executives

**SAP BDC Finance 360 turns your SAP financial data into instant, AI-powered insights — without building a single data pipeline.**

Think of it this way: your SAP system is a library with millions of financial records. Today, getting answers requires a librarian (IT) to manually find, organize, and present the information — taking days or weeks. Finance 360 gives every team member a search engine that understands finance. Ask "What's our revenue by region?" and get an answer in seconds.

### What It Does

- Connects directly to SAP Business Data Cloud — no data copying, no waiting
- Organizes raw SAP data into business-friendly analytics (revenue, expenses, aging, profitability)
- Provides a natural language AI assistant that answers finance questions in plain English
- Deploys as a self-contained app across any region in under a day

### Why It Matters

| Without Finance 360 | With Finance 360 |
|---------------------|-----------------|
| 2-4 week wait for a new report | 30-second answers via AI |
| $2M+/year in ETL maintenance | Zero pipeline costs |
| 8-12 day month-end close | 40-60% faster close |
| IT bottleneck for every question | 80% self-service adoption |

---

## For Technical Teams

### Architecture

SAP BDC Finance 360 implements a **medallion architecture** on Snowflake consuming SAP Business Data Cloud Standard Data Products via zero-copy data sharing:

```
L0 (Bronze) → L1 (Silver) → L2 (Gold) → Semantic View → Cortex Agent → Native App
```

### Layer Details

| Layer | Implementation | Purpose |
|-------|---------------|---------|
| **L0** | Mounted SAP BDC shared databases | Raw SAP tables: ACDOCA (OPERATIONALACCTGDOCITEM), BKPF (JOURNALENTRY), RBKP (SUPPLIERINVOICE), SKA1 (GENERALLEDGERACCOUNT), CSKS (COSTCENTER), CEPC (PROFITCENTER) |
| **L1** | Views in `SAP_BDC_L1` schema | Column-level comments, business-friendly naming, standardized interfaces over L0 |
| **L2** | Dynamic Tables in `ANALYTICS` schema | Joined/enriched analytics objects: Journal Entry 360 (5-table join), P&L Summary, Expense by Cost Center, Revenue by Profit Center, AP Aging, AR Aging |
| **Semantic** | `SAP_FINANCE_360` semantic view | 5 facts, 24 dimensions, 9 metrics with relationships. Powers both the Cortex Agent and the Native App's Analyst page |
| **Agent** | `SAP_FINANCE_360_AGENT` | Cortex Agent using `cortex_analyst_text_to_sql` tool over the semantic view. Available in Snowflake Intelligence |
| **App** | `FINANCE_360_APP` (Native App) | React (Vite) + Express on SPCS. 8 pages covering Overview, GL, Cost Centers, Profit Centers, AP, AR, Period Analysis, Ask the Agent |

### Key Technical Decisions

- **Dynamic Tables with `TARGET_LAG='DOWNSTREAM'`** — Refresh only when downstream consumers need data, minimizing compute costs
- **Semantic View (not YAML model)** — DDL-based governance with dimension/metric definitions directly in Snowflake
- **Native App packaging** — Self-contained with bundled data via `SHARED_DATA` schema, deployable to any account/region without consumer dependencies
- **Container architecture** — Multi-stage Docker build (Node 20), single service on CPU_X64_XS compute pool, 8080 port with readiness probe

### Deployment Topology

```
Provider Account:
├── SAP_FINANCE_360 (database)
│   ├── SAP_BDC_L0 (raw tables / shared DBs)
│   ├── SAP_BDC_L1 (curated views)
│   └── ANALYTICS (dynamic tables + semantic view + agent)
├── FINANCE_360_PKG (application package)
│   ├── SHARED_DATA (bundled tables for app)
│   └── PUBLIC.APP_STAGE (manifest, setup.sql, service_spec)
└── FINANCE_360_APP (installed application)
    ├── APP_DATA (views over SHARED_DATA)
    ├── SERVICES (SPCS container service)
    └── CORE (lifecycle procedures)
```

### Company Codes & Currencies

| Code | Entity | Currency | Region |
|------|--------|----------|--------|
| 1000 | US Operations | USD | Americas |
| 2100 | German Operations | EUR | EMEA |
| 5000 | Japan Operations | JPY | APAC |
