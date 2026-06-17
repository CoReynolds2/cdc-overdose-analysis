# Drug-Induced Mortality Trends Analysis (2018–2024)
### CDC WONDER Public Health Dataset | SQL · Excel · Tableau

---

## Project Overview

This project analyzes drug-induced mortality trends across the United States from 2018 to 2024, using publicly available data from the CDC WONDER Multiple Cause of Death database. The analysis focuses on working-age adults (15–64) and examines national trends, demographic patterns, and geographic variation in overdose mortality rates.

The project demonstrates an end-to-end public health data workflow: data acquisition from a federal surveillance system, cleaning and transformation in Excel, structured querying in SQL, and visualization in Tableau Public.

---

## Key Findings

- **55% surge in deaths** from 2018 to 2021 (66,420 → 103,340), driven by the proliferation of illicit fentanyl
- **COVID-19 accelerated the crisis**: a single-year jump of +30% between 2019 and 2020 (69,172 → 89,894 deaths)
- **Adults 35–44 carried the highest burden** across all seven years with 162,383 cumulative deaths
- **Peak crude rate of ~34 per 100,000** reached in 2021 among working-age adults nationally
- **Early signs of decline in 2023–2024**, though 2024 mortality remains 11% above pre-pandemic 2018 levels
- **Delaware, West Virginia, and Connecticut** consistently ranked among the highest crude rates per 100,000 population

---

## Data Source

| Field | Details |
|---|---|
| **Database** | CDC WONDER — Multiple Cause of Death (2018–2024) |
| **Cause Classification** | Drug-Induced Causes (UCD Drug/Alcohol Induced Causes filter) |
| **Geography** | All 50 U.S. States + District of Columbia |
| **Age Groups** | 15–24, 25–34, 35–44, 45–54, 55–64 years |
| **Measures** | Deaths, Population, Crude Rate per 100,000 (with 95% CI) |
| **Access** | [wonder.cdc.gov](https://wonder.cdc.gov/mcd.html) — publicly available, no login required |

> **Note on suppression:** CDC WONDER suppresses counts fewer than 10 to protect privacy. Suppressed rows were excluded from aggregations; findings reflect available reported data only.

---

## Repository Contents

```
cdc-overdose-analysis/
│
├── data/
│   └── CDC_Drug_Overdose_Raw.xlsx        # Raw export from CDC WONDER
│
├── analysis/
│   └── CDC_Drug_Overdose_Analysis.xlsx   # Cleaned data + summary tables + charts
│       ├── Sheet 1: Clean Data           # Filtered, formatted dataset (2,400+ rows)
│       ├── Sheet 2: National Trends      # Year-over-year totals with YoY change
│       ├── Sheet 3: Deaths by Age Group  # Age group breakdown across all years
│       └── Sheet 4: State Rankings       # All states ranked with burden tier
│
├── sql/
│   └── cdc_overdose_analysis.sql         # 7 analytical SQL queries
│
└── README.md
```

---

## SQL Queries

Seven analytical queries are included in `sql/cdc_overdose_analysis.sql`, covering:

| Query | Description | Key Techniques |
|---|---|---|
| 1 | National totals by year with YoY change | `LAG()`, window functions |
| 2 | Deaths by age group with annual share | `SUM() OVER (PARTITION BY)` |
| 3 | State rankings with burden tier classification | `RANK()`, `CASE WHEN` |
| 4 | Top 10 states by total deaths | `RANK()`, `LIMIT` |
| 5 | COVID-19 era impact — pre/during/post comparison | `CASE WHEN` period grouping |
| 6 | Hardest-hit age group per state | CTE + `RANK() OVER (PARTITION BY state)` |
| 7 | Year-over-year state trends (2023 vs. 2024) | Self-join, trend classification |

---

## Excel Analysis

The workbook `CDC_Drug_Overdose_Analysis.xlsx` includes:

- **Clean Data tab:** 2,400+ rows filtered to working-age adults (15–64), with auto-filter and freeze panes
- **National Trends tab:** Annual death totals, crude rates, YoY change with color-coded indicators, line chart, and key findings summary
- **Deaths by Age Group tab:** Pivot-style table showing each age group's deaths across all 7 years with clustered bar chart
- **State Rankings tab:** All 51 geographies ranked by cumulative deaths and classified by burden tier (Critical / High / Moderate / Low)

---

## Tableau Visualization

> 📊 **[View Interactive Dashboard on Tableau Public](https://public.tableau.com/app/profile/corey.reynolds/viz/U_S_Drug-InducedMortalityDashboard20182024/U_S_Drug-InducedMortalityDashboard20182024)**

The Tableau dashboard includes:
- National trend line chart (2018–2024)
- U.S. choropleth map by crude rate
- Age group breakdown bar chart
- Year filter for dynamic exploration

---

## Tools Used

| Tool | Purpose |
|---|---|
| **CDC WONDER** | Data acquisition from federal mortality surveillance system |
| **Microsoft Excel** | Data cleaning, transformation, pivot analysis, charting |
| **SQL** | Analytical querying — aggregations, window functions, CTEs |
| **Tableau Public** | Interactive data visualization and dashboard |

---

## Methodology Notes

- Analysis restricted to **working-age adults (15–64)** where drug-induced mortality burden is most pronounced and policy-relevant
- **Crude rates** (deaths per 100,000) used for cross-state comparisons to account for population size differences
- Rows with suppressed death counts (< 10) were excluded per CDC WONDER data use guidelines
- Year range (2018–2024) selected to capture pre-pandemic baseline, COVID-era surge, and early recovery period

---

## About

**Corey Reynolds**
MS Candidate — Healthcare Informatics, Grand Canyon University (Expected August 2026)
BS — Human Environmental Sciences (Nutrition & Public Health), University of Alabama

This project is part of a portfolio demonstrating applied skills in public health data analysis, SQL querying, and healthcare informatics.

🔗 [GitHub: CoReynolds2](https://github.com/CoReynolds2)

---

*Data sourced from CDC WONDER, a public health surveillance platform maintained by the Centers for Disease Control and Prevention. All data is publicly available and de-identified per CDC data use guidelines.*
