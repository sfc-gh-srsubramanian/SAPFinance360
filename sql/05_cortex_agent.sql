-- =====================================================================
-- Cortex Agent — SAP_FINANCE_360_AGENT
-- Account-level agent for Snowflake Intelligence, matching the
-- SAP_SC360_ANALYST_AGENT / SAP_PEOPLE_ANALYST pattern. Uses the
-- cortex_analyst_text_to_sql tool over the SAP_FINANCE_360 semantic view.
-- Prereqs: 04_semantic_view.sql + SNOWFLAKE.CORTEX_USER on the executing role.
-- =====================================================================

CREATE OR REPLACE AGENT SAP_FINANCE_360.ANALYTICS.SAP_FINANCE_360_AGENT
WITH PROFILE='{"display_name":"SAP Finance 360 Analyst","color":"blue"}'
COMMENT='Cortex Agent for SAP Finance 360 natural language analytics. Answers questions about revenue, expenses, GL postings, cost centers, profit centers, and accounts receivable aging using the SAP_FINANCE_360 semantic view.'
FROM SPECIFICATION $$
{
  "models": {"orchestration": "auto"},
  "orchestration": {"budget": {"seconds": 60, "tokens": 32000}},
  "instructions": {
    "response": "You are an SAP Finance analytics expert. Answer questions about revenue, expenses, general ledger postings, cost centers, profit centers, and accounts receivable aging. Provide clear, concise answers with key figures highlighted in currency terms. When trends are relevant, describe the direction (improving/declining) and always state the fiscal period.",
    "orchestration": "For any question about revenue, expenses, GL accounts, journal postings, or document counts, use the Analyst tool. For cost-center expense analysis, use the Analyst tool. For profit-center or segment revenue, use the Analyst tool. For accounts receivable, aging buckets, DSO, or open amounts, use the Analyst tool.",
    "sample_questions": [
      {"question": "What is total revenue versus expenses by company code?"},
      {"question": "Show the monthly revenue trend."},
      {"question": "Which cost centers have the highest expenses?"},
      {"question": "What is the accounts receivable aging breakdown?"},
      {"question": "What is the average DSO and which customers are the slowest to pay?"},
      {"question": "Which profit centers generate the most revenue?"},
      {"question": "What is the open AR amount by aging bucket?"},
      {"question": "How many journal documents were posted this fiscal year?"}
    ]
  },
  "tools": [
    {"tool_spec": {"type": "cortex_analyst_text_to_sql", "name": "SAP_Finance360_Analyst", "description": "Converts natural language finance questions into SQL against the SAP Finance 360 semantic view. Covers revenue, expenses, GL postings, cost centers, profit centers, segments, and accounts receivable aging (open amounts, DSO, aging buckets)."}}
  ],
  "skills": [],
  "tool_resources": {
    "SAP_Finance360_Analyst": {"semantic_view": "SAP_FINANCE_360.ANALYTICS.SAP_FINANCE_360"}
  }
}
$$;
