import { Database, Table2, Layers, ArrowRight, ExternalLink } from 'lucide-react';

const FINANCE_DATA_PRODUCTS = [
  {
    name: 'Journal Entry Header',
    technicalName: 'sap-bdc-s4-fi-JournalEntryHeader-v1',
    database: 'SAP_BDC_DEMO_JOURNAL_ENTRY_HEADER',
    schema: 'BDCCONNECT',
    table: 'JOURNALENTRY',
    description: 'SAP FI journal entry document headers with company code, fiscal year, document type, and posting dates.',
    entities: ['CompanyCode', 'FiscalYear', 'AccountingDocument', 'DocumentType', 'PostingDate'],
    rowCount: '~2,000',
    category: 'Financial Accounting',
  },
  {
    name: 'Journal Entry Line Items',
    technicalName: 'sap-bdc-s4-fi-OperationalAcctgDocItem-v1',
    database: 'SAP_BDC_DEMO_ENTRY_VIEW_JOURNAL_ENTRY',
    schema: 'BDCCONNECT',
    table: 'OPERATIONALACCTGDOCITEM',
    description: 'Detailed journal entry line items with GL account, cost center, profit center, amounts, and debit/credit classification.',
    entities: ['GLAccount', 'CostCenter', 'ProfitCenter', 'Amount', 'DebitCreditCode', 'Segment'],
    rowCount: '~8,000',
    category: 'Financial Accounting',
  },
  {
    name: 'Supplier Invoice',
    technicalName: 'sap-bdc-s4-fi-SupplierInvoice-v1',
    database: 'SAP_BDC_DEMO_SUPPLIER_INVOICE',
    schema: 'BDCCONNECT',
    table: 'SUPPLIERINVOICE',
    description: 'Accounts payable supplier invoices with vendor, gross amount, currency, status, and payment details.',
    entities: ['SupplierInvoice', 'InvoicingParty', 'GrossAmount', 'Currency', 'Status'],
    rowCount: '~500',
    category: 'Accounts Payable',
  },
  {
    name: 'Expense by Cost Center',
    technicalName: 'sap-bdc-s4-fi-ExpenseByCostCenter-v1',
    database: 'SAP_FINANCE_360',
    schema: 'ANALYTICS',
    table: 'DT_EXPENSE_BY_COSTCENTER',
    description: 'Dynamic table aggregating expenses by cost center, department, profit center, and fiscal period.',
    entities: ['CostCenter', 'Department', 'ProfitCenter', 'ExpenseAmount', 'FiscalPeriod'],
    rowCount: '~2,500',
    category: 'Cost Accounting',
  },
  {
    name: 'Revenue by Profit Center',
    technicalName: 'sap-bdc-s4-fi-RevenueByProfitCenter-v1',
    database: 'SAP_FINANCE_360',
    schema: 'ANALYTICS',
    table: 'DT_REVENUE_BY_PROFITCENTER',
    description: 'Dynamic table aggregating revenue by profit center, segment, company code, and fiscal period.',
    entities: ['ProfitCenter', 'Segment', 'RevenueAmount', 'CompanyCode', 'FiscalPeriod'],
    rowCount: '~1,100',
    category: 'Profitability Analysis',
  },
  {
    name: 'AR Aging',
    technicalName: 'sap-bdc-s4-fi-ARaging-v1',
    database: 'SAP_FINANCE_360',
    schema: 'ANALYTICS',
    table: 'DT_AR_AGING',
    description: 'Accounts receivable aging analysis with customer, open amounts, days past due, clearing status, and payment terms.',
    entities: ['Customer', 'OpenAmount', 'DaysPastDue', 'AgingBucket', 'ClearingStatus', 'PaymentTerms'],
    rowCount: '~3,900',
    category: 'Accounts Receivable',
  },
  {
    name: 'AP Aging',
    technicalName: 'sap-bdc-s4-fi-APaging-v1',
    database: 'SAP_FINANCE_360',
    schema: 'ANALYTICS',
    table: 'DT_AP_AGING',
    description: 'Accounts payable aging with vendor, outstanding amounts, days outstanding, and aging bucket classification.',
    entities: ['Vendor', 'InvoiceGrossAmount', 'DaysOutstanding', 'AgingBucket', 'Status'],
    rowCount: '~420',
    category: 'Accounts Payable',
  },
  {
    name: 'GL Balance',
    technicalName: 'sap-bdc-s4-fi-GLBalance-v1',
    database: 'SAP_FINANCE_360',
    schema: 'ANALYTICS',
    table: 'DT_GL_BALANCE',
    description: 'General ledger account balances with opening balance, period movements, and closing balance by account and period.',
    entities: ['GLAccount', 'OpeningBalance', 'PeriodMovement', 'ClosingBalance', 'FiscalPeriod'],
    rowCount: '~1,800',
    category: 'General Ledger',
  },
  {
    name: 'P&L Summary',
    technicalName: 'sap-bdc-s4-fi-PnLSummary-v1',
    database: 'SAP_FINANCE_360',
    schema: 'ANALYTICS',
    table: 'DT_PNL_SUMMARY',
    description: 'Profit & Loss summary with revenue, COGS, operating expenses, and net income by company code and period.',
    entities: ['Revenue', 'COGS', 'OperatingExpenses', 'NetIncome', 'CompanyCode'],
    rowCount: '~80',
    category: 'Financial Reporting',
  },
  {
    name: 'Journal Entry 360',
    technicalName: 'sap-bdc-s4-fi-JournalEntry360-v1',
    database: 'SAP_FINANCE_360',
    schema: 'ANALYTICS',
    table: 'DT_JOURNAL_ENTRY_360',
    description: 'Enriched journal entry view joining headers with line items, adding department and segment mappings for analytics.',
    entities: ['GLAccount', 'CostCenter', 'ProfitCenter', 'Department', 'Segment', 'Amount'],
    rowCount: '~10,300',
    category: 'Financial Accounting',
  },
];

const CATEGORY_COLORS: Record<string, string> = {
  'Financial Accounting': '#06b6d4',
  'Accounts Payable': '#8b5cf6',
  'Accounts Receivable': '#f59e0b',
  'Cost Accounting': '#10b981',
  'Profitability Analysis': '#3b82f6',
  'General Ledger': '#ec4899',
  'Financial Reporting': '#ef4444',
};

export default function BdcProducts() {
  return (
    <div className="space-y-6">
      {/* Summary Cards */}
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
        <div className="rounded-xl border border-sf-primary/30 bg-gradient-to-br from-cyan-50 to-sky-50 p-5">
          <div className="flex items-center gap-3">
            <Database className="h-8 w-8 text-sf-primary" />
            <div>
              <p className="text-2xl font-extrabold text-gray-900">{FINANCE_DATA_PRODUCTS.length}</p>
              <p className="text-xs text-gray-500">Data Products</p>
            </div>
          </div>
        </div>
        <div className="rounded-xl border border-emerald-300/50 bg-gradient-to-br from-emerald-50 to-green-50 p-5">
          <div className="flex items-center gap-3">
            <Table2 className="h-8 w-8 text-emerald-600" />
            <div>
              <p className="text-2xl font-extrabold text-gray-900">
                {new Set(FINANCE_DATA_PRODUCTS.map(p => p.database)).size}
              </p>
              <p className="text-xs text-gray-500">Source Databases</p>
            </div>
          </div>
        </div>
        <div className="rounded-xl border border-purple-300/50 bg-gradient-to-br from-purple-50 to-indigo-50 p-5">
          <div className="flex items-center gap-3">
            <Layers className="h-8 w-8 text-purple-600" />
            <div>
              <p className="text-2xl font-extrabold text-gray-900">
                {new Set(FINANCE_DATA_PRODUCTS.map(p => p.category)).size}
              </p>
              <p className="text-xs text-gray-500">Categories</p>
            </div>
          </div>
        </div>
      </div>

      {/* Architecture Diagram */}
      <div className="rounded-xl border border-gray-200 bg-white p-6 shadow-md">
        <h3 className="text-lg font-bold text-gray-900 mb-4">Data Architecture</h3>
        <div className="flex items-center justify-between gap-4 overflow-x-auto pb-2">
          <div className="flex flex-col items-center gap-1 min-w-[140px]">
            <div className="rounded-lg bg-gradient-to-br from-orange-100 to-orange-50 border border-orange-200 p-3 text-center w-full">
              <p className="text-xs font-bold text-orange-800">SAP S/4HANA</p>
              <p className="text-[10px] text-orange-600">Source System</p>
            </div>
          </div>
          <ArrowRight className="h-5 w-5 text-gray-400 shrink-0" />
          <div className="flex flex-col items-center gap-1 min-w-[140px]">
            <div className="rounded-lg bg-gradient-to-br from-blue-100 to-blue-50 border border-blue-200 p-3 text-center w-full">
              <p className="text-xs font-bold text-blue-800">SAP BDC Connect</p>
              <p className="text-[10px] text-blue-600">Replication Layer</p>
            </div>
          </div>
          <ArrowRight className="h-5 w-5 text-gray-400 shrink-0" />
          <div className="flex flex-col items-center gap-1 min-w-[140px]">
            <div className="rounded-lg bg-gradient-to-br from-cyan-100 to-cyan-50 border border-cyan-200 p-3 text-center w-full">
              <p className="text-xs font-bold text-cyan-800">Snowflake</p>
              <p className="text-[10px] text-cyan-600">Raw Tables (L1)</p>
            </div>
          </div>
          <ArrowRight className="h-5 w-5 text-gray-400 shrink-0" />
          <div className="flex flex-col items-center gap-1 min-w-[140px]">
            <div className="rounded-lg bg-gradient-to-br from-emerald-100 to-emerald-50 border border-emerald-200 p-3 text-center w-full">
              <p className="text-xs font-bold text-emerald-800">Dynamic Tables</p>
              <p className="text-[10px] text-emerald-600">Analytics (L2)</p>
            </div>
          </div>
          <ArrowRight className="h-5 w-5 text-gray-400 shrink-0" />
          <div className="flex flex-col items-center gap-1 min-w-[140px]">
            <div className="rounded-lg bg-gradient-to-br from-sf-dark to-sf-deeper border border-sf-primary p-3 text-center w-full">
              <p className="text-xs font-bold text-white">Finance 360 App</p>
              <p className="text-[10px] text-sf-pale">This Dashboard</p>
            </div>
          </div>
        </div>
      </div>

      {/* Data Products List */}
      <div className="space-y-3">
        {FINANCE_DATA_PRODUCTS.map((product) => (
          <div
            key={product.technicalName}
            className="rounded-xl border border-gray-200 bg-white p-5 shadow-sm hover:shadow-md transition-shadow"
          >
            <div className="flex items-start justify-between gap-4">
              <div className="flex-1">
                <div className="flex items-center gap-2">
                  <h4 className="text-sm font-bold text-gray-900">{product.name}</h4>
                  <span
                    className="rounded-full px-2 py-0.5 text-[10px] font-semibold"
                    style={{
                      backgroundColor: (CATEGORY_COLORS[product.category] || '#6b7280') + '15',
                      color: CATEGORY_COLORS[product.category] || '#6b7280',
                    }}
                  >
                    {product.category}
                  </span>
                </div>
                <p className="mt-1 text-xs text-gray-600">{product.description}</p>
                <div className="mt-2 flex flex-wrap gap-1.5">
                  {product.entities.map((entity) => (
                    <span key={entity} className="rounded bg-gray-100 px-1.5 py-0.5 text-[10px] text-gray-600 font-mono">
                      {entity}
                    </span>
                  ))}
                </div>
              </div>
              <div className="text-right shrink-0">
                <p className="text-xs font-mono text-gray-400">{product.rowCount} rows</p>
              </div>
            </div>
            <div className="mt-3 flex items-center gap-2 rounded-lg bg-gray-50 px-3 py-2 text-[10px] font-mono text-gray-500">
              <ExternalLink className="h-3 w-3 shrink-0" />
              <span className="truncate">{product.database}.{product.schema}.{product.table}</span>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
