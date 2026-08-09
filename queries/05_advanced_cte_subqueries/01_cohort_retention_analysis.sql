-- ── 1. Cohort Analysis — Customer retention by signup month ──
--    Shows what % of each signup cohort made a repeat purchase
--    in the following months.
WITH cohorts AS (
    -- Assign each customer to a cohort based on their first order month
    SELECT
        customer_id,
        DATE_TRUNC('month', MIN(order_date))::DATE AS cohort_month
    FROM fact_orders
    WHERE order_status <> 'Cancelled'
    GROUP BY customer_id
),
orders_with_cohort AS (
    SELECT
        o.customer_id,
        c.cohort_month,
        DATE_TRUNC('month', o.order_date)::DATE AS order_month,
        -- months since cohort start (0 = acquisition month)
        (DATE_PART('year',  DATE_TRUNC('month', o.order_date))
         - DATE_PART('year',  c.cohort_month)) * 12
        + DATE_PART('month', DATE_TRUNC('month', o.order_date))
        - DATE_PART('month', c.cohort_month)   AS months_since_cohort
    FROM fact_orders    o
    JOIN cohorts        c ON o.customer_id = c.customer_id
    WHERE o.order_status <> 'Cancelled'
),
cohort_sizes AS (
    SELECT cohort_month, COUNT(DISTINCT customer_id) AS cohort_size
    FROM   cohorts
    GROUP  BY cohort_month
)
SELECT
    owc.cohort_month,
    cs.cohort_size,
    owc.months_since_cohort,
    COUNT(DISTINCT owc.customer_id)                       AS active_customers,
    ROUND(
        COUNT(DISTINCT owc.customer_id)::NUMERIC
        / cs.cohort_size * 100, 1
    )                                                     AS retention_pct
FROM orders_with_cohort owc
JOIN cohort_sizes       cs ON owc.cohort_month = cs.cohort_month
GROUP BY owc.cohort_month, cs.cohort_size, owc.months_since_cohort
ORDER BY owc.cohort_month, owc.months_since_cohort;
