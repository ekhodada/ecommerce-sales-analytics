-- ── 3. Year-over-year comparison (LEAD + LAG) ────────────────
WITH annual AS (
    SELECT
        d.year,
        ROUND(SUM(oi.line_total), 2) AS revenue
    FROM fact_orders      o
    JOIN dim_date         d  ON o.order_date  = d.date_id
    JOIN fact_order_items oi ON o.order_id   = oi.order_id
    WHERE o.order_status <> 'Cancelled'
    GROUP BY d.year
)
SELECT
    year,
    revenue                                           AS current_year_revenue,
    LAG(revenue)  OVER (ORDER BY year)                AS prior_year_revenue,
    LEAD(revenue) OVER (ORDER BY year)                AS next_year_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY year))
        / NULLIF(LAG(revenue) OVER (ORDER BY year), 0) * 100, 2
    )                                                 AS yoy_growth_pct
FROM annual
ORDER BY year;
