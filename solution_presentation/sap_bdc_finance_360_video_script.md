# SAP BDC Finance 360 — Video Script

## Specs

| Parameter | Value |
|-----------|-------|
| Duration | 90 seconds |
| Format | Screen recording + motion graphics overlay |
| Resolution | 1920×1080 (16:9) |
| Music | Corporate ambient, building energy |
| Voice | Professional narrator, conversational tone |

---

## Script

### HOOK (0:00–0:10)

**[VISUAL]**: Dark screen. A single statistic fades in with impact:

> "60% of finance team time goes to gathering SAP data. Not analyzing it."

**[NARRATOR]**: "Your finance team spends more time hunting for data than making decisions with it."

---

### STAKES (0:10–0:30)

**[VISUAL]**: Quick cuts showing the pain — spreadsheets, ETL monitoring dashboards, email chains asking for reports, a calendar showing "Month-End Close: Day 12"

**[NARRATOR]**: "Traditional SAP analytics means six-month projects, two-million-dollar pipelines, and data that's already 48 hours old by the time you see it. Meanwhile, your CFO is making billion-dollar decisions on last week's numbers."

**[VISUAL]**: Cost counter ticking up — "$2M per year in pipeline maintenance"

---

### SOLUTION (0:30–1:10)

**[VISUAL]**: Transition to the Finance 360 architecture diagram (animated left-to-right flow)

**[NARRATOR]**: "SAP BDC Finance 360 eliminates the gap entirely."

**[VISUAL]**: SAP BDC logo connects to Snowflake with a "Zero ETL" label

**[NARRATOR]**: "SAP Business Data Cloud delivers your financial data directly to Snowflake — no extraction, no pipelines, no stale copies."

**[VISUAL]**: Medallion layers animate: Bronze → Silver → Gold

**[NARRATOR]**: "A governed medallion architecture organizes raw SAP tables into analytics-ready datasets — preserving every company code, fiscal period, and cost center hierarchy."

**[VISUAL]**: The Cortex Agent interface — a user types "What is total revenue by region?"

**[NARRATOR]**: "Then Cortex AI makes it conversational. Ask any finance question in plain English. Get answers in seconds, not weeks."

**[VISUAL]**: The React dashboard with data flowing across all tabs (Overview, GL, AP, AR, Cost Centers, Profit Centers)

**[NARRATOR]**: "And it all runs inside a self-contained Native App — deployable to any region, any account, in under a day."

---

### CTA (1:10–1:30)

**[VISUAL]**: ROI summary card appears:

- $2M saved (no ETL)
- 58% faster close
- 30-second answers
- Deploy in < 1 day

**[NARRATOR]**: "SAP BDC Finance 360. From six months of pipeline building to six minutes of conversation. Your SAP data has been waiting for this."

**[VISUAL]**: Snowflake logo + "Try it today" with QR code

**[NARRATOR]**: "See it live. Link in the description."

---

## Production Notes

- All dashboard footage captured from the live FINANCE_360_APP instance
- Architecture animations built from the SVG assets in `solution_presentation/images/`
- Music bed should build intensity during the SOLUTION section
- End card holds for 3 seconds with Snowflake branding
