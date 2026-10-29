-- ============================================================
-- Customer Behaviour Analysis System
-- Business Analysis
-- Database: customer_behaviour_db
-- ============================================================

USE customer_behaviour_db;


-- ============================================================
-- 1. OVERALL BUSINESS KPIs
-- ============================================================

SELECT
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.customer_id) AS purchasing_customers,
    ROUND(SUM(o.final_amount), 2) AS total_revenue,
    ROUND(
        SUM(o.final_amount) / COUNT(DISTINCT o.order_id),
        2
    ) AS average_order_value
FROM orders o;


-- ============================================================
-- 2. TOTAL QUANTITY SOLD
-- ============================================================

SELECT
    SUM(quantity) AS total_quantity_sold
FROM order_items;


-- ============================================================
-- 3. TOTAL PROFIT
-- ============================================================

SELECT
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(
        SUM(profit) / NULLIF(SUM(item_revenue), 0) * 100,
        2
    ) AS profit_margin_percentage
FROM order_items;


-- ============================================================
-- 4. ORDER STATUS BREAKDOWN
-- ============================================================

SELECT
    order_status,
    COUNT(*) AS order_count,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM orders),
        2
    ) AS percentage_of_orders
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;


-- ============================================================
-- 5. CUSTOMER PURCHASE STATUS
-- ============================================================

SELECT
    customer_status,
    COUNT(*) AS customer_count,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM customers),
        2
    ) AS percentage_of_customers
FROM customers
GROUP BY customer_status
ORDER BY customer_count DESC;


-- ============================================================
-- END OF SECTION 1
-- ============================================================

-- ============================================================
-- 2. MONTHLY REVENUE & SALES TRENDS
-- ============================================================

-- 2.1 Monthly Revenue and Orders

SELECT
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    DATE_FORMAT(order_date, '%Y-%m') AS year_month,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS purchasing_customers,
    ROUND(SUM(final_amount), 2) AS total_revenue,
    ROUND(
        SUM(final_amount) /
        NULLIF(COUNT(DISTINCT order_id), 0),
        2
    ) AS average_order_value
FROM orders
GROUP BY
    YEAR(order_date),
    MONTH(order_date),
    DATE_FORMAT(order_date, '%Y-%m')
ORDER BY
    order_year,
    order_month;


-- 2.2 Revenue by Year

SELECT
    YEAR(order_date) AS order_year,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(final_amount), 2) AS total_revenue,
    ROUND(
        SUM(final_amount) /
        NULLIF(COUNT(DISTINCT order_id), 0),
        2
    ) AS average_order_value
FROM orders
GROUP BY YEAR(order_date)
ORDER BY order_year;


-- 2.3 Monthly Profit

SELECT
    YEAR(o.order_date) AS order_year,
    MONTH(o.order_date) AS order_month,
    DATE_FORMAT(o.order_date, '%Y-%m') AS year_month,
    ROUND(SUM(oi.item_revenue), 2) AS item_revenue,
    ROUND(SUM(oi.profit), 2) AS total_profit,
    ROUND(
        SUM(oi.profit) /
        NULLIF(SUM(oi.item_revenue), 0) * 100,
        2
    ) AS profit_margin_percentage
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY
    YEAR(o.order_date),
    MONTH(o.order_date),
    DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY
    order_year,
    order_month;


-- 2.4 Day-of-Week Order Pattern

SELECT
    DAYNAME(order_date) AS day_of_week,
    COUNT(*) AS total_orders,
    ROUND(SUM(final_amount), 2) AS total_revenue
FROM orders
GROUP BY
    DAYOFWEEK(order_date),
    DAYNAME(order_date)
ORDER BY DAYOFWEEK(order_date);


-- 2.5 Weekend vs Weekday Sales

SELECT
    CASE
        WHEN DAYOFWEEK(order_date) IN (1, 7)
            THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    COUNT(*) AS total_orders,
    ROUND(SUM(final_amount), 2) AS total_revenue,
    ROUND(
        SUM(final_amount) / COUNT(*),
        2
    ) AS average_order_value
FROM orders
GROUP BY
    CASE
        WHEN DAYOFWEEK(order_date) IN (1, 7)
            THEN 'Weekend'
        ELSE 'Weekday'
    END;


    -- ============================================================
-- 3. CUSTOMER BEHAVIOUR ANALYSIS
-- ============================================================

-- 3.1 Customer Purchase Frequency

SELECT
    o.customer_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(o.final_amount), 2) AS total_spend,
    ROUND(
        SUM(o.final_amount) /
        NULLIF(COUNT(DISTINCT o.order_id), 0),
        2
    ) AS average_order_value
FROM orders o
GROUP BY o.customer_id
ORDER BY total_spend DESC;


-- 3.2 Top 20 Customers by Spending

SELECT
    o.customer_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(o.final_amount), 2) AS total_spend,
    ROUND(
        SUM(o.final_amount) /
        NULLIF(COUNT(DISTINCT o.order_id), 0),
        2
    ) AS average_order_value
FROM orders o
GROUP BY o.customer_id
ORDER BY total_spend DESC
LIMIT 20;


-- 3.3 Top 20 Customers by Order Frequency

SELECT
    o.customer_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(o.final_amount), 2) AS total_spend,
    ROUND(
        SUM(o.final_amount) /
        NULLIF(COUNT(DISTINCT o.order_id), 0),
        2
    ) AS average_order_value
FROM orders o
GROUP BY o.customer_id
ORDER BY total_orders DESC, total_spend DESC
LIMIT 20;


-- 3.4 Customer Spending Distribution

SELECT
    CASE
        WHEN total_spend < 5000 THEN 'Low Spend'
        WHEN total_spend < 20000 THEN 'Medium Spend'
        WHEN total_spend < 50000 THEN 'High Spend'
        ELSE 'Very High Spend'
    END AS spending_group,
    COUNT(*) AS customer_count,
    ROUND(SUM(total_spend), 2) AS total_customer_spend,
    ROUND(AVG(total_spend), 2) AS average_customer_spend
FROM (
    SELECT
        customer_id,
        SUM(final_amount) AS total_spend
    FROM orders
    GROUP BY customer_id
) customer_summary
GROUP BY
    CASE
        WHEN total_spend < 5000 THEN 'Low Spend'
        WHEN total_spend < 20000 THEN 'Medium Spend'
        WHEN total_spend < 50000 THEN 'High Spend'
        ELSE 'Very High Spend'
    END
ORDER BY total_customer_spend DESC;


-- 3.5 Repeat Customer Analysis

SELECT
    COUNT(*) AS total_purchasing_customers,
    SUM(CASE WHEN total_orders = 1 THEN 1 ELSE 0 END)
        AS one_time_customers,
    SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END)
        AS repeat_customers,
    ROUND(
        SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS repeat_customer_rate
FROM (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS total_orders
    FROM orders
    GROUP BY customer_id
) customer_orders;


-- 3.6 Customer Order Frequency Distribution

SELECT
    CASE
        WHEN total_orders = 1 THEN '1 Order'
        WHEN total_orders BETWEEN 2 AND 3 THEN '2-3 Orders'
        WHEN total_orders BETWEEN 4 AND 6 THEN '4-6 Orders'
        ELSE '7+ Orders'
    END AS frequency_group,
    COUNT(*) AS customer_count
FROM (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS total_orders
    FROM orders
    GROUP BY customer_id
) customer_orders
GROUP BY
    CASE
        WHEN total_orders = 1 THEN '1 Order'
        WHEN total_orders BETWEEN 2 AND 3 THEN '2-3 Orders'
        WHEN total_orders BETWEEN 4 AND 6 THEN '4-6 Orders'
        ELSE '7+ Orders'
    END
ORDER BY customer_count DESC;


-- 3.7 Customer Acquisition Channel

SELECT
    c.acquisition_channel,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(DISTINCT o.customer_id) AS purchasing_customers,
    ROUND(SUM(o.final_amount), 2) AS total_revenue,
    ROUND(
        SUM(o.final_amount) /
        NULLIF(COUNT(DISTINCT o.order_id), 0),
        2
    ) AS average_order_value
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.acquisition_channel
ORDER BY total_revenue DESC;


-- 3.8 Customer Loyalty Tier Performance

SELECT
    c.loyalty_tier,
    COUNT(DISTINCT c.customer_id) AS customers,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(o.final_amount), 2) AS revenue,
    ROUND(
        SUM(o.final_amount) /
        NULLIF(COUNT(DISTINCT o.order_id), 0),
        2
    ) AS average_order_value
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.loyalty_tier
ORDER BY revenue DESC;

-- ============================================================
-- 4. PRODUCT & CATEGORY PERFORMANCE
-- ============================================================


-- 4.1 Top 20 Products by Revenue

SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.subcategory,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    SUM(oi.quantity) AS quantity_sold,
    ROUND(SUM(oi.item_revenue), 2) AS total_revenue,
    ROUND(SUM(oi.profit), 2) AS total_profit
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY
    p.product_id,
    p.product_name,
    p.category,
    p.subcategory
ORDER BY total_revenue DESC
LIMIT 20;


-- 4.2 Top 20 Products by Profit

SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(oi.quantity) AS quantity_sold,
    ROUND(SUM(oi.item_revenue), 2) AS total_revenue,
    ROUND(SUM(oi.profit), 2) AS total_profit,
    ROUND(
        SUM(oi.profit) /
        NULLIF(SUM(oi.item_revenue), 0) * 100,
        2
    ) AS profit_margin_percentage
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY
    p.product_id,
    p.product_name,
    p.category
ORDER BY total_profit DESC
LIMIT 20;


-- 4.3 Top 20 Loss-Making Products

SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(oi.quantity) AS quantity_sold,
    ROUND(SUM(oi.item_revenue), 2) AS total_revenue,
    ROUND(SUM(oi.profit), 2) AS total_profit,
    ROUND(
        SUM(oi.profit) /
        NULLIF(SUM(oi.item_revenue), 0) * 100,
        2
    ) AS profit_margin_percentage
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY
    p.product_id,
    p.product_name,
    p.category
HAVING total_profit < 0
ORDER BY total_profit ASC
LIMIT 20;


-- 4.4 Category Performance

SELECT
    p.category,
    COUNT(DISTINCT p.product_id) AS product_count,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    SUM(oi.quantity) AS quantity_sold,
    ROUND(SUM(oi.item_revenue), 2) AS total_revenue,
    ROUND(SUM(oi.profit), 2) AS total_profit,
    ROUND(
        SUM(oi.profit) /
        NULLIF(SUM(oi.item_revenue), 0) * 100,
        2
    ) AS profit_margin_percentage
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;


-- 4.5 Subcategory Performance

SELECT
    p.category,
    p.subcategory,
    COUNT(DISTINCT p.product_id) AS product_count,
    SUM(oi.quantity) AS quantity_sold,
    ROUND(SUM(oi.item_revenue), 2) AS total_revenue,
    ROUND(SUM(oi.profit), 2) AS total_profit
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY
    p.category,
    p.subcategory
ORDER BY total_revenue DESC;


-- 4.6 Brand Performance

SELECT
    p.brand,
    COUNT(DISTINCT p.product_id) AS product_count,
    SUM(oi.quantity) AS quantity_sold,
    ROUND(SUM(oi.item_revenue), 2) AS total_revenue,
    ROUND(SUM(oi.profit), 2) AS total_profit
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.brand
ORDER BY total_revenue DESC
LIMIT 20;


-- 4.7 Product Return Rate

SELECT
    p.product_id,
    p.product_name,
    p.category,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(DISTINCT r.return_id) AS total_returns,
    ROUND(
        COUNT(DISTINCT r.return_id) * 100.0 /
        NULLIF(COUNT(DISTINCT oi.order_id), 0),
        2
    ) AS return_rate_percentage
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
LEFT JOIN returns r
    ON p.product_id = r.product_id
GROUP BY
    p.product_id,
    p.product_name,
    p.category
HAVING total_orders > 0
ORDER BY return_rate_percentage DESC
LIMIT 20;


-- ============================================================
-- END OF SECTION 4
-- ============================================================

-- ============================================================
-- 5. REGIONAL & CUSTOMER DEMOGRAPHICS ANALYSIS
-- ============================================================


-- 5.1 Revenue by State

SELECT
    o.delivery_state AS state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.customer_id) AS purchasing_customers,
    ROUND(SUM(o.final_amount), 2) AS total_revenue,
    ROUND(
        SUM(o.final_amount) /
        NULLIF(COUNT(DISTINCT o.order_id), 0),
        2
    ) AS average_order_value
FROM orders o
GROUP BY o.delivery_state
ORDER BY total_revenue DESC;


-- 5.2 Revenue by City

SELECT
    o.delivery_state AS state,
    o.delivery_city AS city,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.customer_id) AS purchasing_customers,
    ROUND(SUM(o.final_amount), 2) AS total_revenue
FROM orders o
GROUP BY
    o.delivery_state,
    o.delivery_city
ORDER BY total_revenue DESC
LIMIT 30;


-- 5.3 Customer Gender Analysis

SELECT
    c.gender,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(o.final_amount), 2) AS total_revenue,
    ROUND(
        SUM(o.final_amount) /
        NULLIF(COUNT(DISTINCT o.order_id), 0),
        2
    ) AS average_order_value
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.gender
ORDER BY total_revenue DESC;


-- 5.4 Customer Age Group Analysis

SELECT
    c.age_group,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(o.final_amount), 2) AS total_revenue,
    ROUND(
        SUM(o.final_amount) /
        NULLIF(COUNT(DISTINCT o.order_id), 0),
        2
    ) AS average_order_value
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.age_group
ORDER BY total_revenue DESC;


-- 5.5 Customer Segment Analysis

SELECT
    c.customer_segment,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(o.final_amount), 2) AS total_revenue,
    ROUND(
        SUM(o.final_amount) /
        NULLIF(COUNT(DISTINCT o.order_id), 0),
        2
    ) AS average_order_value
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_segment
ORDER BY total_revenue DESC;


-- 5.6 Preferred Device Analysis

SELECT
    c.preferred_device,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(o.final_amount), 2) AS total_revenue,
    ROUND(
        SUM(o.final_amount) /
        NULLIF(COUNT(DISTINCT o.order_id), 0),
        2
    ) AS average_order_value
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.preferred_device
ORDER BY total_revenue DESC;


-- 5.7 Payment Method Analysis

SELECT
    p.payment_method,
    COUNT(DISTINCT p.order_id) AS total_orders,
    ROUND(SUM(p.amount_paid), 2) AS total_amount_paid,
    ROUND(AVG(p.amount_paid), 2) AS average_payment_amount
FROM payments p
GROUP BY p.payment_method
ORDER BY total_amount_paid DESC;


-- ============================================================
-- END OF SECTION 5
-- ============================================================

-- ============================================================
-- 6. RETURNS, REVIEWS & CUSTOMER EXPERIENCE
-- ============================================================


-- 6.1 Return Overview

SELECT
    COUNT(*) AS total_returns,
    COUNT(DISTINCT order_id) AS orders_with_returns,
    COUNT(DISTINCT customer_id) AS customers_with_returns,
    ROUND(SUM(refund_amount), 2) AS total_refund_amount
FROM returns;


-- 6.2 Return Reason Analysis

SELECT
    return_reason,
    COUNT(*) AS return_count,
    ROUND(SUM(refund_amount), 2) AS total_refund_amount,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM returns),
        2
    ) AS return_percentage
FROM returns
GROUP BY return_reason
ORDER BY return_count DESC;


-- 6.3 Return Status Analysis

SELECT
    return_status,
    COUNT(*) AS return_count,
    ROUND(SUM(refund_amount), 2) AS total_refund_amount
FROM returns
GROUP BY return_status
ORDER BY return_count DESC;


-- 6.4 Return Rate by Product Category

SELECT
    p.category,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(DISTINCT r.return_id) AS total_returns,
    ROUND(
        COUNT(DISTINCT r.return_id) * 100.0 /
        NULLIF(COUNT(DISTINCT oi.order_id), 0),
        2
    ) AS return_rate_percentage,
    ROUND(SUM(r.refund_amount), 2) AS total_refund_amount
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
LEFT JOIN returns r
    ON p.product_id = r.product_id
GROUP BY p.category
ORDER BY return_rate_percentage DESC;


-- 6.5 Review Rating Distribution

SELECT
    rating,
    COUNT(*) AS review_count,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM customer_reviews),
        2
    ) AS percentage_of_reviews
FROM customer_reviews
GROUP BY rating
ORDER BY rating DESC;


-- 6.6 Review Sentiment Analysis

SELECT
    review_sentiment,
    COUNT(*) AS review_count,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM customer_reviews),
        2
    ) AS percentage_of_reviews,
    ROUND(AVG(rating), 2) AS average_rating
FROM customer_reviews
GROUP BY review_sentiment
ORDER BY review_count DESC;


-- 6.7 Product Rating Performance

SELECT
    p.product_id,
    p.product_name,
    p.category,
    COUNT(cr.review_id) AS review_count,
    ROUND(AVG(cr.rating), 2) AS average_rating
FROM products p
JOIN customer_reviews cr
    ON p.product_id = cr.product_id
GROUP BY
    p.product_id,
    p.product_name,
    p.category
HAVING COUNT(cr.review_id) >= 10
ORDER BY average_rating DESC
LIMIT 20;


-- 6.8 Lowest-Rated Products

SELECT
    p.product_id,
    p.product_name,
    p.category,
    COUNT(cr.review_id) AS review_count,
    ROUND(AVG(cr.rating), 2) AS average_rating
FROM products p
JOIN customer_reviews cr
    ON p.product_id = cr.product_id
GROUP BY
    p.product_id,
    p.product_name,
    p.category
HAVING COUNT(cr.review_id) >= 10
ORDER BY average_rating ASC
LIMIT 20;


-- 6.9 Rating and Return Relationship

SELECT
    CASE
        WHEN cr.rating >= 4 THEN 'High Rating'
        WHEN cr.rating = 3 THEN 'Neutral Rating'
        ELSE 'Low Rating'
    END AS rating_group,
    COUNT(DISTINCT cr.product_id) AS products_reviewed,
    COUNT(cr.review_id) AS total_reviews,
    COUNT(DISTINCT r.return_id) AS total_returns,
    ROUND(AVG(cr.rating), 2) AS average_rating
FROM customer_reviews cr
LEFT JOIN returns r
    ON cr.product_id = r.product_id
GROUP BY
    CASE
        WHEN cr.rating >= 4 THEN 'High Rating'
        WHEN cr.rating = 3 THEN 'Neutral Rating'
        ELSE 'Low Rating'
    END
ORDER BY average_rating DESC;


-- ============================================================
-- END OF SECTION 6
-- ============================================================

-- ============================================================
-- 7. MARKETING CAMPAIGN PERFORMANCE
-- ============================================================


-- 7.1 Overall Campaign Performance

SELECT
    COUNT(*) AS total_campaigns,
    ROUND(SUM(impressions), 0) AS total_impressions,
    ROUND(SUM(clicks), 0) AS total_clicks,
    ROUND(SUM(conversions), 0) AS total_conversions,
    ROUND(SUM(cost), 2) AS total_campaign_cost,
    ROUND(SUM(revenue), 2) AS total_campaign_revenue,
    ROUND(AVG(roi), 2) AS average_roi
FROM marketing_campaigns;


-- 7.2 Campaign Performance by Channel

SELECT
    channel,
    COUNT(*) AS campaign_count,
    SUM(impressions) AS impressions,
    SUM(clicks) AS clicks,
    SUM(conversions) AS conversions,
    ROUND(SUM(cost), 2) AS total_cost,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(AVG(roi), 2) AS average_roi
FROM marketing_campaigns
GROUP BY channel
ORDER BY total_revenue DESC;


-- 7.3 Campaign Performance by Campaign Type

SELECT
    campaign_type,
    COUNT(*) AS campaign_count,
    SUM(conversions) AS conversions,
    ROUND(SUM(cost), 2) AS total_cost,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(AVG(roi), 2) AS average_roi
FROM marketing_campaigns
GROUP BY campaign_type
ORDER BY total_revenue DESC;


-- 7.4 Top 20 Campaigns by ROI

SELECT
    campaign_id,
    campaign_name,
    channel,
    campaign_type,
    target_segment,
    discount_percentage,
    conversions,
    ROUND(cost, 2) AS campaign_cost,
    ROUND(revenue, 2) AS revenue,
    ROUND(roi, 2) AS roi
FROM marketing_campaigns
ORDER BY roi DESC
LIMIT 20;


-- 7.5 Lowest ROI Campaigns

SELECT
    campaign_id,
    campaign_name,
    channel,
    campaign_type,
    target_segment,
    discount_percentage,
    conversions,
    ROUND(cost, 2) AS campaign_cost,
    ROUND(revenue, 2) AS revenue,
    ROUND(roi, 2) AS roi
FROM marketing_campaigns
ORDER BY roi ASC
LIMIT 20;


-- 7.6 Campaign Conversion Rate

SELECT
    campaign_id,
    campaign_name,
    channel,
    impressions,
    clicks,
    conversions,
    ROUND(
        clicks * 100.0 /
        NULLIF(impressions, 0),
        2
    ) AS click_through_rate,
    ROUND(
        conversions * 100.0 /
        NULLIF(clicks, 0),
        2
    ) AS conversion_rate
FROM marketing_campaigns
ORDER BY conversion_rate DESC
LIMIT 20;


-- 7.7 Campaign Performance by Target Segment

SELECT
    target_segment,
    COUNT(*) AS campaign_count,
    SUM(conversions) AS conversions,
    ROUND(SUM(cost), 2) AS total_cost,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(AVG(roi), 2) AS average_roi
FROM marketing_campaigns
GROUP BY target_segment
ORDER BY total_revenue DESC;


-- ============================================================
-- END OF SECTION 7
-- ============================================================

-- ============================================================
-- 8. SHIPPING & DELIVERY PERFORMANCE
-- ============================================================


-- 8.1 Overall Delivery Performance

SELECT
    COUNT(*) AS total_shipments,
    COUNT(CASE
        WHEN delivery_status = 'Delivered'
        THEN 1
    END) AS delivered_shipments,
    COUNT(CASE
        WHEN is_delayed = TRUE
        THEN 1
    END) AS delayed_shipments,
    ROUND(AVG(delivery_days), 2) AS average_delivery_days,
    ROUND(AVG(delivery_delay_days), 2) AS average_delay_days
FROM shipments;


-- 8.2 Delivery Status Analysis

SELECT
    delivery_status,
    COUNT(*) AS shipment_count,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM shipments),
        2
    ) AS percentage_of_shipments
FROM shipments
GROUP BY delivery_status
ORDER BY shipment_count DESC;


-- 8.3 Shipping Method Performance

SELECT
    shipping_method,
    COUNT(*) AS total_shipments,
    ROUND(AVG(delivery_days), 2) AS average_delivery_days,
    COUNT(CASE
        WHEN is_delayed = TRUE
        THEN 1
    END) AS delayed_shipments,
    ROUND(
        COUNT(CASE
            WHEN is_delayed = TRUE
            THEN 1
        END) * 100.0 / COUNT(*),
        2
    ) AS delay_rate_percentage
FROM shipments
GROUP BY shipping_method
ORDER BY delay_rate_percentage ASC;


-- 8.4 Warehouse Performance

SELECT
    warehouse_city,
    COUNT(*) AS total_shipments,
    ROUND(AVG(delivery_days), 2) AS average_delivery_days,
    COUNT(CASE
        WHEN is_delayed = TRUE
        THEN 1
    END) AS delayed_shipments,
    ROUND(
        COUNT(CASE
            WHEN is_delayed = TRUE
            THEN 1
        END) * 100.0 / COUNT(*),
        2
    ) AS delay_rate_percentage
FROM shipments
GROUP BY warehouse_city
ORDER BY delay_rate_percentage ASC;


-- 8.5 Delivery State Performance

SELECT
    delivery_city,
    COUNT(*) AS total_shipments,
    ROUND(AVG(delivery_days), 2) AS average_delivery_days,
    COUNT(CASE
        WHEN is_delayed = TRUE
        THEN 1
    END) AS delayed_shipments,
    ROUND(
        COUNT(CASE
            WHEN is_delayed = TRUE
            THEN 1
        END) * 100.0 / COUNT(*),
        2
    ) AS delay_rate_percentage
FROM shipments
GROUP BY delivery_city
HAVING COUNT(*) >= 20
ORDER BY delay_rate_percentage DESC
LIMIT 30;


-- 8.6 Delayed Shipments by Month

SELECT
    YEAR(dispatch_date) AS dispatch_year,
    MONTH(dispatch_date) AS dispatch_month,
    DATE_FORMAT(dispatch_date, '%Y-%m') AS year_month,
    COUNT(*) AS total_shipments,
    COUNT(CASE
        WHEN is_delayed = TRUE
        THEN 1
    END) AS delayed_shipments,
    ROUND(
        COUNT(CASE
            WHEN is_delayed = TRUE
            THEN 1
        END) * 100.0 / COUNT(*),
        2
    ) AS delay_rate_percentage
FROM shipments
GROUP BY
    YEAR(dispatch_date),
    MONTH(dispatch_date),
    DATE_FORMAT(dispatch_date, '%Y-%m')
ORDER BY
    dispatch_year,
    dispatch_month;


-- ============================================================
-- END OF SECTION 8
-- ============================================================

-- ============================================================
-- 9. PAYMENT ANALYSIS
-- ============================================================


-- 9.1 Payment Method Performance

SELECT
    payment_method,
    COUNT(*) AS payment_count,
    COUNT(CASE
        WHEN payment_status = 'Success'
        THEN 1
    END) AS successful_payments,
    COUNT(CASE
        WHEN payment_status = 'Failed'
        THEN 1
    END) AS failed_payments,
    COUNT(CASE
        WHEN payment_status = 'Refunded'
        THEN 1
    END) AS refunded_payments,
    ROUND(SUM(amount_paid), 2) AS total_amount_paid,
    ROUND(AVG(amount_paid), 2) AS average_payment_amount
FROM payments
GROUP BY payment_method
ORDER BY total_amount_paid DESC;


-- 9.2 Payment Status Analysis

SELECT
    payment_status,
    COUNT(*) AS payment_count,
    ROUND(SUM(amount_paid), 2) AS total_amount_paid,
    ROUND(SUM(refund_amount), 2) AS total_refund_amount,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM payments),
        2
    ) AS percentage_of_payments
FROM payments
GROUP BY payment_status
ORDER BY payment_count DESC;


-- 9.3 Payment Success Rate by Method

SELECT
    payment_method,
    COUNT(*) AS total_payments,
    COUNT(CASE
        WHEN payment_status = 'Success'
        THEN 1
    END) AS successful_payments,
    ROUND(
        COUNT(CASE
            WHEN payment_status = 'Success'
            THEN 1
        END) * 100.0 / COUNT(*),
        2
    ) AS success_rate_percentage
FROM payments
GROUP BY payment_method
ORDER BY success_rate_percentage DESC;


-- 9.4 Transaction Fees by Payment Method

SELECT
    payment_method,
    COUNT(*) AS payment_count,
    ROUND(SUM(transaction_fee), 2) AS total_transaction_fees,
    ROUND(AVG(transaction_fee), 2) AS average_transaction_fee
FROM payments
GROUP BY payment_method
ORDER BY total_transaction_fees DESC;


-- 9.5 Monthly Payment Performance

SELECT
    YEAR(payment_date) AS payment_year,
    MONTH(payment_date) AS payment_month,
    DATE_FORMAT(payment_date, '%Y-%m') AS year_month,
    COUNT(*) AS payment_count,
    ROUND(SUM(amount_paid), 2) AS total_amount_paid,
    ROUND(SUM(refund_amount), 2) AS total_refund_amount
FROM payments
GROUP BY
    YEAR(payment_date),
    MONTH(payment_date),
    DATE_FORMAT(payment_date, '%Y-%m')
ORDER BY
    payment_year,
    payment_month;


-- ============================================================
-- END OF SECTION 9
-- ============================================================

-- ============================================================
-- 10. RFM CUSTOMER SEGMENTATION
-- ============================================================


-- 10.1 RFM Base Metrics
-- Using Delivered orders as completed purchases

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


-- 10.2 RFM Scores

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


-- 10.3 Customer Segment Classification

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


-- 10.4 RFM Segment Summary

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


-- 10.5 At-Risk Customer Identification

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
-- END OF SECTION 10
-- ============================================================
