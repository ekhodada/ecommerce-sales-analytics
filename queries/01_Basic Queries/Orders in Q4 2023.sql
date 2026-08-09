-- Orders placed in Q4 2023
SELECT
    o.order_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    o.order_date,
    o.order_status,
    o.payment_method
FROM fact_orders    o
JOIN dim_customers  c ON o.customer_id = c.customer_id
JOIN dim_date       d ON o.order_date  = d.date_id
WHERE d.year = 2023 AND d.quarter = 4
ORDER BY o.order_date;
