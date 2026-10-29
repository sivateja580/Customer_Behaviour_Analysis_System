-- ============================================================
-- Customer Behaviour Analysis System
-- SQL Data Quality Checks
-- Database: customer_behaviour_db
-- ============================================================

USE customer_behaviour_db;


-- ============================================================
-- 1. ROW COUNT CHECK
-- ============================================================

SELECT 'customers' AS table_name, COUNT(*) AS row_count
FROM customers

UNION ALL

SELECT 'products', COUNT(*)
FROM products

UNION ALL

SELECT 'marketing_campaigns', COUNT(*)
FROM marketing_campaigns

UNION ALL

SELECT 'orders', COUNT(*)
FROM orders

UNION ALL

SELECT 'order_items', COUNT(*)
FROM order_items

UNION ALL

SELECT 'payments', COUNT(*)
FROM payments

UNION ALL

SELECT 'shipments', COUNT(*)
FROM shipments

UNION ALL

SELECT 'returns', COUNT(*)
FROM returns

UNION ALL

SELECT 'customer_reviews', COUNT(*)
FROM customer_reviews;


-- ============================================================
-- 2. PRIMARY KEY DUPLICATE CHECK
-- ============================================================

SELECT customer_id, COUNT(*) AS duplicate_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT product_id, COUNT(*) AS duplicate_count
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

SELECT order_id, COUNT(*) AS duplicate_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT order_item_id, COUNT(*) AS duplicate_count
FROM order_items
GROUP BY order_item_id
HAVING COUNT(*) > 1;


-- ============================================================
-- 3. NULL VALUE CHECK
-- ============================================================

SELECT
    COUNT(*) AS total_customers,
    SUM(customer_id IS NULL) AS null_customer_id,
    SUM(signup_date IS NULL) AS null_signup_date,
    SUM(age IS NULL) AS null_age,
    SUM(state IS NULL) AS null_state,
    SUM(city IS NULL) AS null_city
FROM customers;


SELECT
    COUNT(*) AS total_orders,
    SUM(order_id IS NULL) AS null_order_id,
    SUM(customer_id IS NULL) AS null_customer_id,
    SUM(order_date IS NULL) AS null_order_date,
    SUM(final_amount IS NULL) AS null_final_amount
FROM orders;


-- ============================================================
-- 4. FOREIGN KEY CHECK - ORDERS → CUSTOMERS
-- ============================================================

SELECT COUNT(*) AS invalid_customer_references
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- ============================================================
-- 5. FOREIGN KEY CHECK - ORDER ITEMS → ORDERS
-- ============================================================

SELECT COUNT(*) AS invalid_order_references
FROM order_items oi
LEFT JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;


-- ============================================================
-- 6. FOREIGN KEY CHECK - ORDER ITEMS → PRODUCTS
-- ============================================================

SELECT COUNT(*) AS invalid_product_references
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;


-- ============================================================
-- 7. FOREIGN KEY CHECK - PAYMENTS → ORDERS
-- ============================================================

SELECT COUNT(*) AS invalid_payment_order_references
FROM payments p
LEFT JOIN orders o
    ON p.order_id = o.order_id
WHERE o.order_id IS NULL;


-- ============================================================
-- 8. FOREIGN KEY CHECK - SHIPMENTS → ORDERS
-- ============================================================

SELECT COUNT(*) AS invalid_shipment_order_references
FROM shipments s
LEFT JOIN orders o
    ON s.order_id = o.order_id
WHERE o.order_id IS NULL;


-- ============================================================
-- 9. FOREIGN KEY CHECK - RETURNS
-- ============================================================

SELECT COUNT(*) AS invalid_return_order_references
FROM returns r
LEFT JOIN orders o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL;


SELECT COUNT(*) AS invalid_return_customer_references
FROM returns r
LEFT JOIN customers c
    ON r.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


SELECT COUNT(*) AS invalid_return_product_references
FROM returns r
LEFT JOIN products p
    ON r.product_id = p.product_id
WHERE p.product_id IS NULL;


-- ============================================================
-- 10. FOREIGN KEY CHECK - CUSTOMER REVIEWS
-- ============================================================

SELECT COUNT(*) AS invalid_review_order_references
FROM customer_reviews cr
LEFT JOIN orders o
    ON cr.order_id = o.order_id
WHERE o.order_id IS NULL;


SELECT COUNT(*) AS invalid_review_customer_references
FROM customer_reviews cr
LEFT JOIN customers c
    ON cr.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


SELECT COUNT(*) AS invalid_review_product_references
FROM customer_reviews cr
LEFT JOIN products p
    ON cr.product_id = p.product_id
WHERE p.product_id IS NULL;


-- ============================================================
-- 11. BUSINESS LOGIC CHECK - ORDER AMOUNT
-- ============================================================

SELECT COUNT(*) AS incorrect_order_amounts
FROM orders
WHERE ABS(
    final_amount - (subtotal + shipping_fee + tax_amount)
) > 0.01;


-- ============================================================
-- 12. BUSINESS LOGIC CHECK - ORDER ITEM REVENUE
-- ============================================================

SELECT COUNT(*) AS incorrect_item_revenue
FROM order_items
WHERE ABS(
    item_revenue -
    (quantity * unit_price * (1 - discount_percentage / 100))
) > 0.01;


-- ============================================================
-- 13. BUSINESS LOGIC CHECK - PROFIT
-- ============================================================

SELECT COUNT(*) AS incorrect_profit
FROM order_items
WHERE ABS(
    profit - (item_revenue - item_cost)
) > 0.01;


-- ============================================================
-- 14. NEGATIVE VALUE CHECK
-- ============================================================

SELECT COUNT(*) AS negative_order_amounts
FROM orders
WHERE final_amount < 0;


SELECT COUNT(*) AS negative_item_revenue
FROM order_items
WHERE item_revenue < 0;


SELECT COUNT(*) AS negative_profit
FROM order_items
WHERE profit < 0;


-- ============================================================
-- 15. ORDER DATE RANGE
-- ============================================================

SELECT
    MIN(order_date) AS earliest_order_date,
    MAX(order_date) AS latest_order_date
FROM orders;


-- ============================================================
-- 16. CUSTOMER ORDER COUNT - SOURCE FIELD REVIEW
-- ============================================================

-- The customers.total_orders field is a source-system derived
-- attribute and does not consistently match the transactional
-- orders table.
--
-- Therefore, customer order metrics for analysis should be
-- calculated directly from the orders table rather than relying
-- on customers.total_orders.

SELECT
    COUNT(*) AS customers_with_order_count_difference
FROM customers c
WHERE c.total_orders <> (
    SELECT COUNT(*)
    FROM orders o
    WHERE o.customer_id = c.customer_id
);


-- ============================================================
-- 17. NEGATIVE PROFIT - BUSINESS FINDING
-- ============================================================

-- Negative profit is not treated as a data-quality error.
-- It represents transactions where item revenue is below item cost.

SELECT
    COUNT(*) AS loss_making_order_items,
    ROUND(SUM(-profit), 2) AS total_loss_amount
FROM order_items
WHERE profit < 0;


-- ============================================================
-- DATA QUALITY CONCLUSION
-- ============================================================

-- Primary keys, foreign keys and calculation checks passed.
-- Negative profit represents a business condition.
-- customers.total_orders is not used as the transactional
-- source of truth for customer order analysis.

-- ============================================================
-- END OF DATA QUALITY CHECKS
-- ============================================================