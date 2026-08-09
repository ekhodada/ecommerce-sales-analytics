-- ── 2. RFM Segmentation (Recency, Frequency, Monetary) ───────
WITH rfm_raw AS (
    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name             AS customer_name,
        c.customer_segment,
        DATE '2024-12-31' - MAX(o.order_date)          AS recency_days,
        COUNT(DISTINCT o.order_id)                     AS frequency,
        ROUND(SUM(oi.line_total), 2)                   AS monetary
    FROM dim_customers       c
    JOIN fact_orders         o  ON c.customer_id = o.customer_id
    JOIN fact_order_items    oi ON o.order_id    = oi.order_id
    WHERE o.order_status <> 'Cancelled'
    GROUP BY c.customer_id, c.first_name, c.last_name, c.customer_segment
),
rfm_scored AS (
    SELECT
        *,
        NTILE(5) OVER (ORDER BY recency_days ASC)  AS r_score,  -- lower recency = better
        NTILE(5) OVER (ORDER BY frequency    DESC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary     DESC) AS m_score
    FROM rfm_raw
)
SELECT
    customer_id,
    customer_name,
    customer_segment,
    recency_days,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    r_score + f_score + m_score                    AS rfm_total,
    CASE
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
        WHEN r_score >= 3 AND f_score >= 3                  THEN 'Loyal Customers'
        WHEN r_score >= 4 AND f_score <= 2                  THEN 'New Customers'
        WHEN r_score <= 2 AND f_score >= 3                  THEN 'At Risk'
        WHEN r_score <= 2 AND f_score <= 2                  THEN 'Lost'
        ELSE 'Potential Loyalists'
    END                                            AS rfm_segment
FROM rfm_scored
ORDER BY rfm_total DESC;
