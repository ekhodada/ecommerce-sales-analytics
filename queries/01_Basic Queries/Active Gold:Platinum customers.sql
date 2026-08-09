-- All active customers in the 'Gold' or 'Platinum' segment
SELECT
    customer_id,
    first_name || ' ' || last_name   AS full_name,
    email,
    city,
    state,
    customer_segment,
    registration_date
FROM dim_customers
WHERE is_active = TRUE
  AND customer_segment IN ('Gold', 'Platinum')
ORDER BY registration_date DESC;
