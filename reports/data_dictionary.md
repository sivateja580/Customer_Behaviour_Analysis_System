# Data Dictionary – Customer Behaviour Analysis System

## Project
Customer Behaviour Analysis System – RetailPulse India

## Dataset
Indian E-Commerce Sales & Customer Analytics

## Dataset Type
Synthetic Indian e-commerce dataset.

## Purpose
This dataset is used to analyze customer purchasing behaviour, sales performance,
product performance, payments, returns, shipping, reviews, and marketing campaigns.

---

## 1. Customers

File: `customers.csv`

Grain: One row per customer.

Primary Key:
- customer_id

Important fields:
- customer_signup_date
- gender
- age
- age_group
- state
- city
- customer_segment
- preferred_device
- preferred_payment_method
- acquisition_channel
- total_orders
- total_spend
- average_order_value
- last_order_date
- customer_status
- loyalty_tier

Business use:
- Customer segmentation
- Customer demographics
- RFM analysis
- Customer retention
- Customer value analysis

---

## 2. Orders

File: `orders.csv`

Grain: One row per order.

Primary Key:
- order_id

Foreign Keys:
- customer_id
- campaign_id

Important fields:
- order_date
- order_time
- order_status
- shipping_method
- delivery_city
- delivery_state
- coupon_code
- discount_percentage
- marketing_channel
- subtotal
- shipping_fee
- tax_amount
- final_amount
- campaign_id

Business use:
- Revenue analysis
- Sales trends
- Order behaviour
- Regional analysis
- Marketing attribution

---

## 3. Order Items

File: `order_items.csv`

Grain: One row per product line item within an order.

Primary Key:
- order_item_id

Foreign Keys:
- order_id
- product_id

Important fields:
- quantity
- unit_price
- discount_percentage
- item_revenue
- item_cost
- profit

Business use:
- Product performance
- Quantity analysis
- Revenue analysis
- Profitability analysis

---

## 4. Products

File: `products.csv`

Grain: One row per product.

Primary Key:
- product_id

Important fields:
- product_name
- category
- subcategory
- brand
- price
- cost_price
- discount_range
- rating_average
- rating_count
- stock_quantity
- product_launch_date
- product_type

Business use:
- Product analysis
- Category analysis
- Brand analysis
- Profitability
- Inventory analysis

---

## 5. Payments

File: `payments.csv`

Grain: One row per payment record.

Primary Key:
- payment_id

Foreign Key:
- order_id

Important fields:
- payment_date
- payment_method
- payment_status
- amount_paid
- transaction_fee
- refund_amount

Business use:
- Payment method analysis
- Payment success analysis
- Refund analysis
- Payment cost analysis

---

## 6. Shipments

File: `shipments.csv`

Grain: One row per shipment.

Primary Key:
- shipment_id

Foreign Key:
- order_id

Important fields:
- warehouse_city
- delivery_city
- shipping_method
- dispatch_date
- expected_delivery_date
- actual_delivery_date
- delivery_days
- delivery_status
- delayed_flag

Business use:
- Delivery performance
- Shipping analysis
- Delay analysis
- Warehouse performance

---

## 7. Returns

File: `returns.csv`

Grain: One row per return record.

Primary Key:
- return_id

Foreign Keys:
- order_id
- customer_id
- product_id

Important fields:
- return_date
- return_reason
- refund_amount
- return_status

Business use:
- Return rate
- Return reasons
- Product return analysis
- Refund analysis

---

## 8. Customer Reviews

File: `customer_reviews.csv`

Grain: One row per customer review.

Primary Key:
- review_id

Foreign Keys:
- order_id
- customer_id
- product_id

Important fields:
- review_date
- rating
- review_sentiment
- verified_purchase

Business use:
- Customer satisfaction
- Product ratings
- Sentiment analysis
- Verified purchase analysis

---

## 9. Marketing Campaigns

File: `marketing_campaigns.csv`

Grain: One row per marketing campaign.

Primary Key:
- campaign_id

Important fields:
- campaign_name
- channel
- campaign_start_date
- campaign_end_date
- campaign_type
- target_segment
- discount_percentage
- impressions
- clicks
- conversions
- campaign_cost
- revenue_generated
- roi

Business use:
- Campaign performance
- Marketing ROI
- Conversion analysis
- Channel performance
- Customer acquisition

---

## Key Relationships

customers
    |
    | customer_id
    ↓
orders
    |
    ├── order_id → order_items
    ├── order_id → payments
    ├── order_id → shipments
    ├── order_id → returns
    └── order_id → customer_reviews

order_items
    |
    └── product_id → products

orders
    |
    └── campaign_id → marketing_campaigns

---

## Important Data Quality Considerations

Some fields are derived from other tables and should not automatically
be treated as independent source data.

Examples:
- total_orders
- total_spend
- average_order_value
- last_order_date
- customer_status
- subtotal
- final_amount
- item_revenue
- profit
- revenue_generated
- roi

Some fields are identified as potential leakage variables for predictive
modelling and should be handled carefully.

Examples:
- products.return_rate_baseline
- shipments.actual_delivery_date
- shipments.delivery_days

---

## Analysis Areas

The project will cover:

1. Customer Behaviour
2. Sales Performance
3. Product Performance
4. Customer Segmentation
5. RFM Analysis
6. Customer Retention
7. Return Analysis
8. Payment Analysis
9. Delivery Performance
10. Customer Reviews
11. Marketing Campaign Performance
12. Business Recommendations