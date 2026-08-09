# E-Commerce Sales Analytics — Data Analyst Portfolio
 
> **Stack:** PostgreSQL · Python · Chart.js  
> **Domain:** E-Commerce / Retail · Jan 2022 – Dec 2024

---

## Overview

End-to-end analytics project built on a production-grade e-commerce database.  

- **600 customers · 4,834 orders · $5.8M revenue · 48.2% margin**
- 5 product categories · 7 sales reps · 5 regions · 3 fiscal years

---

## Database Schema

Star schema (3 fact tables, 5 dimension tables):

```
dim_date ──────────┐
dim_customers ─────┤
dim_products ──────┼──► fact_order_items ◄──┐
dim_regions ───────┤                         ├── fact_orders ──► dim_employees
dim_employees ─────┘    fact_returns ────────┘               └──► dim_regions
```

---

## Project Structure

```
.
├── .gitignore
├── schema/
│   └── 01_create_tables.sql           # Full DDL: tab
└── queries/
    ├── 01_Basic Queries/              # Filtering, sorting, CASE, date functions
    ├── 02_joins/                      # INNER, LEFT, FULL OUTER, anti-joins
    ├── 03_kpi_aggregations/           # Revenue, margin, CLV, segment KPIs
    ├── 04_window_functions/           # LAG/LEAD, RANK, running totals, NTILE
    ├── 05_advanced_cte_subqueries/    # Cohort retention, RFM segmentation
    └── 06_data_quality_checks/        # Completeness, uniqueness, anomaly detection
Dashboard/
    └── index.html                     # Interactive Chart.js dashboard (no server needed)
```

Each query folder contains a `.sql` file with inline comments and a matching `.csv` result file.

---

## Skills Demonstrated

| Category | Techniques |
|---|---|
| **Filtering & Sorting** | WHERE, BETWEEN, IN, LIKE, CASE WHEN |
| **Aggregation** | GROUP BY, HAVING, conditional aggregation |
| **Joins** | INNER, LEFT, FULL OUTER, anti-join (LEFT JOIN … IS NULL) |
| **Window Functions** | LAG/LEAD, RANK/DENSE_RANK, SUM OVER, NTILE, ROWS BETWEEN |
| **CTEs & Subqueries** | Multi-level CTEs, correlated subqueries, EXISTS |
| **Date & Time** | DATE_TRUNC, EXTRACT, fiscal quarters, date arithmetic |
| **Data Quality** | NULL checks, duplicate detection, referential integrity, outlier flags |
| **Business Analysis** | RFM segmentation, cohort retention, MoM/YoY growth, moving averages |

---

## Sample Queries

### MoM Revenue Growth (window function)
```sql
WITH monthly AS (
    SELECT DATE_TRUNC('month', order_date) AS month,
           SUM(line_total) AS revenue
    FROM fact_orders o
    JOIN fact_order_items oi ON o.order_id = oi.order_id
    WHERE order_status <> 'Cancelled'
    GROUP BY 1
)
SELECT month, revenue,
       LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue,
       ROUND((revenue - LAG(revenue) OVER (ORDER BY month))
             / LAG(revenue) OVER (ORDER BY month) * 100, 2) AS mom_growth_pct
FROM monthly;
```

### RFM Customer Segmentation (CTE + NTILE)
```sql
WITH rfm AS (
    SELECT customer_id,
           DATE '2024-12-31' - MAX(order_date) AS recency,
           COUNT(order_id)                      AS frequency,
           SUM(line_total)                      AS monetary
    FROM fact_orders o
    JOIN fact_order_items oi ON o.order_id = oi.order_id
    GROUP BY customer_id
)
SELECT *,
       NTILE(5) OVER (ORDER BY recency   ASC)  AS r_score,
       NTILE(5) OVER (ORDER BY frequency DESC) AS f_score,
       NTILE(5) OVER (ORDER BY monetary  DESC) AS m_score
FROM rfm;
```

---

## Key Business Findings

- **Revenue grew 3.7×** from 2022 ($998K) to 2024 ($3.04M) — Q4 2024 alone hit $1.1M
- **Electronics** dominates at 55% of total revenue ($3.19M) but only 43% margin
- **Furniture** has the best margin efficiency at 52%, driven by Standing Desk and Office Chair
- **Southwest region** leads in revenue ($1.2M); Southeast has the highest refund rate
- **Returning customers** overtook new customers by Apr 2022, showing strong early retention
- **7 late-order escalations** flagged in data quality checks needing ops review

---

## Dashboard

Open `Dashboard/index.html` directly in any browser — no server required.  
Features: year filter (2022 / 2023 / 2024), dark mode toggle, 9 interactive charts.

![Dashboard Overview](screenshots/dashboard_overview.png)
![Revenue Charts](screenshots/dashboard_revenue.png)
![Dark Mode](screenshots/dashboard_dark.png)

---

## Quick Start

### 1. Create the database
```sql
CREATE DATABASE retail_analytics;
```

### 2. Run the schema
```bash
psql -U postgres -d retail_analytics -f schema/01_create_tables.sql
```

### 3. Run any query
Open a `.sql` file from the `queries/` folder in DBeaver, DataGrip, or pgAdmin and execute against `retail_analytics`.

---

## Contact
[LinkedIn](https://www.linkedin.com/in/elnaz-khodadadi-547868a6/) · [GitHub](#)
