-- ============================================
-- Customer Behaviour Analysis System
-- Table: customers
-- ============================================

CREATE TABLE customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    signup_date DATE,
    gender VARCHAR(20),
    age INT,
    age_group VARCHAR(20),
    state VARCHAR(100),
    city VARCHAR(100),
    customer_segment VARCHAR(30),
    preferred_device VARCHAR(30),
    preferred_payment_method VARCHAR(50),
    acquisition_channel VARCHAR(50),
    total_orders INT,
    total_spend DECIMAL(12,2),
    average_order_value DECIMAL(12,2),
    last_order_date DATE,
    customer_status VARCHAR(30),
    loyalty_tier VARCHAR(20),
    has_purchased BOOLEAN
);

-- ============================================
-- Table: products
-- ============================================

CREATE TABLE products (
    product_id VARCHAR(20) PRIMARY KEY,
    product_name VARCHAR(255),
    category VARCHAR(100),
    subcategory VARCHAR(100),
    brand VARCHAR(100),
    price DECIMAL(12,2),
    cost_price DECIMAL(12,2),
    discount_range VARCHAR(50),
    rating_average DECIMAL(4,2),
    rating_count INT,
    stock_quantity INT,
    launch_date DATE,
    product_type VARCHAR(30),
    return_rate_baseline DECIMAL(6,4)
);

-- ============================================
-- Table: marketing_campaigns
-- ============================================

CREATE TABLE marketing_campaigns (
    campaign_id VARCHAR(20) PRIMARY KEY,
    campaign_name VARCHAR(255),
    channel VARCHAR(100),
    start_date DATE,
    end_date DATE,
    campaign_type VARCHAR(100),
    target_segment VARCHAR(100),
    discount_percentage DECIMAL(5,2),
    impressions INT,
    clicks INT,
    conversions INT,
    cost DECIMAL(12,2),
    revenue DECIMAL(12,2),
    roi DECIMAL(10,4)
);


-- ============================================
-- Table: orders
-- ============================================

CREATE TABLE orders (
    order_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    order_date DATE,
    order_time TIME,
    order_status VARCHAR(30),
    shipping_method VARCHAR(50),
    delivery_city VARCHAR(100),
    delivery_state VARCHAR(100),
    coupon_code VARCHAR(50),
    discount_percentage DECIMAL(5,2),
    marketing_channel VARCHAR(100),
    subtotal DECIMAL(12,2),
    shipping_fee DECIMAL(12,2),
    tax_amount DECIMAL(12,2),
    final_amount DECIMAL(12,2),
    campaign_id VARCHAR(20),

    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),

    CONSTRAINT fk_orders_campaign
        FOREIGN KEY (campaign_id)
        REFERENCES marketing_campaigns(campaign_id)
);


-- ============================================
-- Table: order_items
-- ============================================

CREATE TABLE order_items (
    order_item_id VARCHAR(20) PRIMARY KEY,
    order_id VARCHAR(20) NOT NULL,
    product_id VARCHAR(20) NOT NULL,
    quantity INT,
    unit_price DECIMAL(12,2),
    discount_percentage DECIMAL(5,2),
    item_revenue DECIMAL(12,2),
    item_cost DECIMAL(12,2),
    profit DECIMAL(12,2),
    discount_amount DECIMAL(12,2),

    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    CONSTRAINT fk_order_items_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);

-- ============================================
-- Table: payments
-- ============================================

CREATE TABLE payments (
    payment_id VARCHAR(20) PRIMARY KEY,
    order_id VARCHAR(20) NOT NULL,
    payment_date DATE,
    payment_method VARCHAR(50),
    payment_status VARCHAR(30),
    amount_paid DECIMAL(12,2),
    transaction_fee DECIMAL(12,2),
    refund_amount DECIMAL(12,2),

    CONSTRAINT fk_payments_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
);

-- ============================================
-- Table: shipments
-- ============================================

CREATE TABLE shipments (
    shipment_id VARCHAR(20) PRIMARY KEY,
    order_id VARCHAR(20) NOT NULL,
    warehouse_city VARCHAR(100),
    delivery_city VARCHAR(100),
    shipping_method VARCHAR(50),
    dispatch_date DATE,
    expected_delivery_date DATE,
    actual_delivery_date DATE,
    delivery_days INT,
    delivery_status VARCHAR(50),
    delayed_flag INT,
    delivery_delay_days INT,
    is_delayed BOOLEAN,

    CONSTRAINT fk_shipments_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
);

-- ============================================
-- Table: returns
-- ============================================

CREATE TABLE returns (
    return_id VARCHAR(20) PRIMARY KEY,
    order_id VARCHAR(20) NOT NULL,
    customer_id VARCHAR(20) NOT NULL,
    product_id VARCHAR(20) NOT NULL,
    return_date DATE,
    return_reason VARCHAR(100),
    refund_amount DECIMAL(12,2),
    return_status VARCHAR(30),

    CONSTRAINT fk_returns_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    CONSTRAINT fk_returns_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),

    CONSTRAINT fk_returns_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);

-- ============================================
-- Table: customer_reviews
-- ============================================

CREATE TABLE customer_reviews (
    review_id VARCHAR(20) PRIMARY KEY,
    order_id VARCHAR(20) NOT NULL,
    customer_id VARCHAR(20) NOT NULL,
    product_id VARCHAR(20) NOT NULL,
    review_date DATE,
    rating INT,
    review_sentiment VARCHAR(30),
    verified_purchase BOOLEAN,

    CONSTRAINT fk_reviews_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    CONSTRAINT fk_reviews_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),

    CONSTRAINT fk_reviews_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);