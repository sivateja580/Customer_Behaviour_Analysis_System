-- ============================================================
-- Customer Behaviour Analysis System
-- Customer Segmentation using RFM Analysis
-- Database: customer_behaviour_db
-- ============================================================

USE customer_behaviour_db;


-- ============================================================
-- 1. RFM BASE METRICS
-- ============================================================

WITH rfm_base AS (
    SELECT
        customer_id,
        MAX(order_date) AS last_purchase_date,
        COUNT(DISTINCT order_id) AS frequency,
        ROUND(SUM(final_amount), 2) AS monetary
    FROM orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
)

SELECT
    customer_id,
    DATEDIFF(
        (SELECT MAX(order_date) FROM orders),
        last_purchase_date
    ) AS recency,
    frequency,
    monetary
FROM rfm_base
ORDER BY monetary DESC;


-- ============================================================
-- 2. RFM SCORING
-- ============================================================

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

        DATEDIFF(
            (SELECT MAX(order_date) FROM orders),
            last_purchase_date
        ) AS recency,

        frequency,
        monetary,

        NTILE(5) OVER (
            ORDER BY DATEDIFF(
                (SELECT MAX(order_date) FROM orders),
                last_purchase_date
            ) DESC
        ) AS recency_score,

        NTILE(5) OVER (
            ORDER BY frequency ASC
        ) AS frequency_score,

        NTILE(5) OVER (
            ORDER BY monetary ASC
        ) AS monetary_score

    FROM rfm_base
)

SELECT
    customer_id,
    recency,
    frequency,
    monetary,
    recency_score,
    frequency_score,
    monetary_score,
    CONCAT(
        recency_score,
        frequency_score,
        monetary_score
    ) AS rfm_score
FROM rfm_scores
ORDER BY monetary DESC;


-- ============================================================
-- 3. CUSTOMER SEGMENTATION
-- ============================================================

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

        DATEDIFF(
            (SELECT MAX(order_date) FROM orders),
            last_purchase_date
        ) AS recency,

        frequency,
        monetary,

        NTILE(5) OVER (
            ORDER BY DATEDIFF(
                (SELECT MAX(order_date) FROM orders),
                last_purchase_date
            ) DESC
        ) AS recency_score,

        NTILE(5) OVER (
            ORDER BY frequency ASC
        ) AS frequency_score,

        NTILE(5) OVER (
            ORDER BY monetary ASC
        ) AS monetary_score

    FROM rfm_base
)

SELECT
    customer_id,
    recency,
    frequency,
    monetary,
    recency_score,
    frequency_score,
    monetary_score,

    CASE
        WHEN recency_score >= 4
             AND frequency_score >= 4
             AND monetary_score >= 4
            THEN 'Champions'

        WHEN recency_score >= 3
             AND frequency_score >= 4
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
ORDER BY monetary DESC;


-- ============================================================
-- 4. RFM SEGMENT SUMMARY
-- ============================================================

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

        DATEDIFF(
            (SELECT MAX(order_date) FROM orders),
            last_purchase_date
        ) AS recency,

        frequency,
        monetary,

        NTILE(5) OVER (
            ORDER BY DATEDIFF(
                (SELECT MAX(order_date) FROM orders),
                last_purchase_date
            ) DESC
        ) AS recency_score,

        NTILE(5) OVER (
            ORDER BY frequency ASC
        ) AS frequency_score,

        NTILE(5) OVER (
            ORDER BY monetary ASC
        ) AS monetary_score

    FROM rfm_base
),

segmented_customers AS (
    SELECT
        customer_id,
        recency,
        frequency,
        monetary,

        CASE
            WHEN recency_score >= 4
                 AND frequency_score >= 4
                 AND monetary_score >= 4
                THEN 'Champions'

            WHEN recency_score >= 3
                 AND frequency_score >= 4
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
    customer_segment,
    COUNT(*) AS customer_count,
    ROUND(SUM(monetary), 2) AS total_revenue,
    ROUND(AVG(monetary), 2) AS average_customer_value,
    ROUND(AVG(frequency), 2) AS average_purchase_frequency,
    ROUND(AVG(recency), 2) AS average_recency_days
FROM segmented_customers
GROUP BY customer_segment
ORDER BY total_revenue DESC;


-- ============================================================
-- 5. AT-RISK CUSTOMER LIST
-- ============================================================

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

        DATEDIFF(
            (SELECT MAX(order_date) FROM orders),
            last_purchase_date
        ) AS recency,

        frequency,
        monetary,

        NTILE(5) OVER (
            ORDER BY DATEDIFF(
                (SELECT MAX(order_date) FROM orders),
                last_purchase_date
            ) DESC
        ) AS recency_score,

        NTILE(5) OVER (
            ORDER BY frequency ASC
        ) AS frequency_score,

        NTILE(5) OVER (
            ORDER BY monetary ASC
        ) AS monetary_score

    FROM rfm_base
)

SELECT
    customer_id,
    recency,
    frequency,
    monetary,
    recency_score,
    frequency_score,
    monetary_score
FROM rfm_scores
WHERE recency_score <= 2
  AND frequency_score >= 3
  AND monetary_score >= 3
ORDER BY monetary DESC;


-- ============================================================
-- END OF CUSTOMER SEGMENTATION ANALYSIS
-- ============================================================