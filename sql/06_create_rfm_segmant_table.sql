
USE customer_behaviour_db;

DROP TABLE IF EXISTS customer_rfm_segments;

CREATE TABLE customer_rfm_segments AS
WITH rfm_base AS (
    SELECT
        customer_id,
        MAX(order_date) AS last_purchase_date,
        COUNT(DISTINCT order_id) AS frequency,
        ROUND(SUM(final_amount), 2) AS monetary
    FROM orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
),
rfm_scores AS (
    SELECT
        customer_id,
        last_purchase_date,
        frequency,
        monetary,
        DATEDIFF(
            (SELECT MAX(order_date)
             FROM orders
             WHERE order_status = 'Delivered'),
            last_purchase_date
        ) AS recency,
        NTILE(5) OVER (
            ORDER BY DATEDIFF(
                (SELECT MAX(order_date)
                 FROM orders
                 WHERE order_status = 'Delivered'),
                last_purchase_date
            ) DESC
        ) AS recency_score,
        NTILE(5) OVER (
            ORDER BY frequency
        ) AS frequency_score,
        NTILE(5) OVER (
            ORDER BY monetary
        ) AS monetary_score
    FROM rfm_base
),
segmented_customers AS (
    SELECT
        *,
        CASE
            WHEN recency_score >= 4
                 AND frequency_score >= 4
                 AND monetary_score >= 4
                THEN 'Champions'
            WHEN recency_score >= 3
                 AND frequency_score >= 3
                THEN 'Loyal Customers'
            WHEN recency_score >= 4
                 AND frequency_score <= 2
                THEN 'New Customers'
            WHEN recency_score <= 2
                 AND frequency_score >= 3
                 AND monetary_score >= 3
                THEN 'At Risk'
            WHEN recency_score <= 2
                 AND frequency_score <= 2
                THEN 'Lost Customers'
            ELSE 'Potential Loyalists'
        END AS customer_segment
    FROM rfm_scores
)
SELECT
    customer_id,
    last_purchase_date,
    recency,
    frequency,
    monetary,
    recency_score,
    frequency_score,
    monetary_score,
    customer_segment
FROM segmented_customers;
