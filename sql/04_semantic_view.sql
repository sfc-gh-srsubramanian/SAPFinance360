-- =====================================================================
-- Semantic layer — SAP_FINANCE_360 semantic view
-- Powers both the Native App "Ask the Agent" page and the account-level
-- SAP_FINANCE_360_AGENT Cortex Agent (see 05_cortex_agent.sql).
-- =====================================================================

create or replace semantic view SAP_FINANCE_360.ANALYTICS.SAP_FINANCE_360
	tables (
		JOURNAL as SAP_FINANCE_360.ANALYTICS.DT_JOURNAL_ENTRY_360 comment='Journal entry line items with full SAP dimensions',
		EXPENSE as SAP_FINANCE_360.ANALYTICS.DT_EXPENSE_BY_COSTCENTER comment='Expenses by cost center and department',
		REVENUE as SAP_FINANCE_360.ANALYTICS.DT_REVENUE_BY_PROFITCENTER comment='Revenue by profit center and segment',
		AR as SAP_FINANCE_360.ANALYTICS.DT_AR_AGING comment='Accounts receivable aging with DSO and payment performance'
	)
	facts (
		JOURNAL.AMOUNTINTRANSACTIONCURRENCY as AMOUNTINTRANSACTIONCURRENCY comment='Transaction amount in currency',
		EXPENSE.EXPENSE_AMOUNT as EXPENSE_AMOUNT comment='Expense amount',
		REVENUE.REVENUE_AMOUNT as REVENUE_AMOUNT comment='Revenue amount',
		AR.OPENAMOUNT as OPENAMOUNT comment='Open outstanding amount',
		AR.DAYS_TO_PAY as DAYS_TO_PAY comment='Days to pay'
	)
	dimensions (
		JOURNAL.COMPANYCODE as COMPANYCODE comment='SAP company code (1000=US, 2100=DE, 5000=JP)',
		JOURNAL.FISCALYEAR as FISCALYEAR comment='Fiscal year',
		JOURNAL.FISCALPERIOD as FISCALPERIOD comment='Fiscal period within the year',
		JOURNAL.GLACCOUNT as GLACCOUNT comment='General ledger account number',
		JOURNAL.COSTCENTER as COSTCENTER comment='Cost center code',
		JOURNAL.PROFITCENTER as PROFITCENTER comment='Profit center code',
		JOURNAL.SEGMENT as SEGMENT comment='Business segment',
		JOURNAL.ACCOUNTINGDOCUMENTTYPE as ACCOUNTINGDOCUMENTTYPE comment='Document type (DR=Customer Invoice, KR=Vendor Invoice, SA=GL Posting)',
		JOURNAL.DEBITCREDITCODE as DEBITCREDITCODE comment='S=Debit, H=Credit',
		JOURNAL.POSTINGDATE as POSTINGDATE comment='Posting date',
		JOURNAL.COSTCENTER_DEPARTMENT as COSTCENTER_DEPARTMENT comment='Department mapped from cost center',
		EXPENSE.EXP_COSTCENTER as COSTCENTER comment='Cost center code',
		EXPENSE.EXP_COMPANYCODE as COMPANYCODE comment='Company code',
		EXPENSE.EXP_FISCALYEAR as FISCALYEAR comment='Fiscal year',
		EXPENSE.DEPARTMENT as DEPARTMENT comment='Department name',
		REVENUE.REV_PROFITCENTER as PROFITCENTER comment='Profit center code',
		REVENUE.REV_COMPANYCODE as COMPANYCODE comment='Company code',
		REVENUE.REV_FISCALYEAR as FISCALYEAR comment='Fiscal year',
		REVENUE.REV_SEGMENT as SEGMENT comment='Business segment',
		AR.CUSTOMERNAME as CUSTOMERNAME comment='Customer name',
		AR.AR_COMPANYCODE as COMPANYCODE comment='Company code',
		AR.AR_FISCALYEAR as FISCALYEAR comment='Fiscal year',
		AR.AGING_BUCKET as AGING_BUCKET comment='Aging classification (Current, 1-30 Days, 31-60 Days, etc.)',
		AR.CLEARINGSTATUS as CLEARINGSTATUS comment='Payment status (Cleared, Current, Overdue)'
	)
	metrics (
		JOURNAL.TOTAL_AMOUNT as SUM(JOURNAL.AMOUNTINTRANSACTIONCURRENCY) comment='Sum of transaction amounts',
		JOURNAL.REVENUE as SUM(CASE WHEN JOURNAL.GLACCOUNT LIKE '4%' AND JOURNAL.DEBITCREDITCODE = 'H' THEN ABS(JOURNAL.AMOUNTINTRANSACTIONCURRENCY) ELSE 0 END) comment='Total revenue (GL accounts starting with 4)',
		JOURNAL.EXPENSES as SUM(CASE WHEN (JOURNAL.GLACCOUNT LIKE '5%' OR JOURNAL.GLACCOUNT LIKE '6%') AND JOURNAL.DEBITCREDITCODE = 'S' THEN JOURNAL.AMOUNTINTRANSACTIONCURRENCY ELSE 0 END) comment='Total expenses (GL accounts starting with 5 or 6)',
		JOURNAL.DOCUMENT_COUNT as COUNT(DISTINCT JOURNAL.ACCOUNTINGDOCUMENT || JOURNAL.COMPANYCODE || JOURNAL.FISCALYEAR) comment='Number of unique documents',
		EXPENSE.TOTAL_EXPENSE as SUM(EXPENSE.EXPENSE_AMOUNT) comment='Total expense amount',
		REVENUE.TOTAL_REVENUE as SUM(REVENUE.REVENUE_AMOUNT) comment='Total revenue amount',
		AR.TOTAL_OPEN as SUM(AR.OPENAMOUNT) comment='Total open/outstanding amount',
		AR.AVG_DSO as AVG(AR.DAYS_TO_PAY) comment='Average days sales outstanding',
		AR.INVOICE_COUNT as COUNT(AR.OPENAMOUNT) comment='Number of AR invoices'
	)
	comment='SAP BDC Finance 360 semantic model covering journal entries, cost centers, profit centers, and accounts receivable aging.';
