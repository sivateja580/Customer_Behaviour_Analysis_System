import pandas as pd
import mysql.connector
from pathlib import Path


# ============================================================
# MySQL Connection
# ============================================================

connection = mysql.connector.connect(
    host="localhost",
    user="root",
    password="Teja@9908554851",
    database="customer_behaviour_db"
)

print("Successfully connected to MySQL!")
print("Database: customer_behaviour_db")


# ============================================================
# Helper Function
# ============================================================

def load_table(csv_file, table_name, columns, insert_query):

    file_path = Path("data/processed") / csv_file

    df = pd.read_csv(file_path)

    print(f"\n{table_name}")
    print(f"CSV rows: {len(df):,}")

    # --------------------------------------------------------
    # Handle CSV column name differences
    # --------------------------------------------------------

    if table_name == "products":
        df = df.rename(columns={
            "product_launch_date": "launch_date"
        })

    if table_name == "customers":
        df = df.rename(columns={
            "customer_signup_date": "signup_date"
        })

    if table_name == "marketing_campaigns":
        df = df.rename(columns={
            "campaign_start_date": "start_date",
            "campaign_end_date": "end_date",
            "campaign_cost": "cost",
            "revenue_generated": "revenue"
        })

    # --------------------------------------------------------
    # Select required columns
    # --------------------------------------------------------

    df = df[columns]

    # Convert pandas NaN / NaT to Python None
    df = df.where(pd.notnull(df), None)

    # Convert DataFrame rows into tuples
    data = [
        tuple(row)
        for row in df.itertuples(index=False, name=None)
    ]

    # --------------------------------------------------------
    # Insert data
    # --------------------------------------------------------

    cursor = connection.cursor()

    insert_query = insert_query.replace(
        "INSERT INTO",
        "INSERT IGNORE INTO"
    )

    cursor.executemany(insert_query, data)

    connection.commit()

    print(f"Inserted rows: {cursor.rowcount:,}")

    cursor.close()

# ============================================================
# 1. PRODUCTS
# ============================================================

load_table(
    "products_cleaned.csv",
    "products",
    [
        "product_id",
        "product_name",
        "category",
        "subcategory",
        "brand",
        "price",
        "cost_price",
        "discount_range",
        "rating_average",
        "rating_count",
        "stock_quantity",
        "launch_date",
        "product_type",
        "return_rate_baseline"
    ],
    """
    INSERT INTO products (
        product_id,
        product_name,
        category,
        subcategory,
        brand,
        price,
        cost_price,
        discount_range,
        rating_average,
        rating_count,
        stock_quantity,
        launch_date,
        product_type,
        return_rate_baseline
    )
    VALUES (
        %s, %s, %s, %s, %s, %s, %s,
        %s, %s, %s, %s, %s, %s, %s
    )
    """
)


# ============================================================
# 2. MARKETING CAMPAIGNS
# ============================================================

load_table(
    "marketing_campaigns_cleaned.csv",
    "marketing_campaigns",
    [
        "campaign_id",
        "campaign_name",
        "channel",
        "start_date",
        "end_date",
        "campaign_type",
        "target_segment",
        "discount_percentage",
        "impressions",
        "clicks",
        "conversions",
        "cost",
        "revenue",
        "roi"
    ],
    """
    INSERT INTO marketing_campaigns (
        campaign_id,
        campaign_name,
        channel,
        start_date,
        end_date,
        campaign_type,
        target_segment,
        discount_percentage,
        impressions,
        clicks,
        conversions,
        cost,
        revenue,
        roi
    )
    VALUES (
        %s, %s, %s, %s, %s, %s, %s,
        %s, %s, %s, %s, %s, %s, %s
    )
    """
)


# ============================================================
# 3. ORDERS
# ============================================================

load_table(
    "orders_cleaned.csv",
    "orders",
    [
        "order_id",
        "customer_id",
        "order_date",
        "order_time",
        "order_status",
        "shipping_method",
        "delivery_city",
        "delivery_state",
        "coupon_code",
        "discount_percentage",
        "marketing_channel",
        "subtotal",
        "shipping_fee",
        "tax_amount",
        "final_amount",
        "campaign_id"
    ],
    """
    INSERT INTO orders (
        order_id,
        customer_id,
        order_date,
        order_time,
        order_status,
        shipping_method,
        delivery_city,
        delivery_state,
        coupon_code,
        discount_percentage,
        marketing_channel,
        subtotal,
        shipping_fee,
        tax_amount,
        final_amount,
        campaign_id
    )
    VALUES (
        %s, %s, %s, %s, %s, %s, %s, %s,
        %s, %s, %s, %s, %s, %s, %s, %s
    )
    """
)


# ============================================================
# 4. ORDER ITEMS
# ============================================================

load_table(
    "order_items_cleaned.csv",
    "order_items",
    [
        "order_item_id",
        "order_id",
        "product_id",
        "quantity",
        "unit_price",
        "discount_percentage",
        "item_revenue",
        "item_cost",
        "profit",
        "discount_amount"
    ],
    """
    INSERT INTO order_items (
        order_item_id,
        order_id,
        product_id,
        quantity,
        unit_price,
        discount_percentage,
        item_revenue,
        item_cost,
        profit,
        discount_amount
    )
    VALUES (
        %s, %s, %s, %s, %s,
        %s, %s, %s, %s, %s
    )
    """
)


# ============================================================
# 5. PAYMENTS
# ============================================================

load_table(
    "payments_cleaned.csv",
    "payments",
    [
        "payment_id",
        "order_id",
        "payment_date",
        "payment_method",
        "payment_status",
        "amount_paid",
        "transaction_fee",
        "refund_amount"
    ],
    """
    INSERT INTO payments (
        payment_id,
        order_id,
        payment_date,
        payment_method,
        payment_status,
        amount_paid,
        transaction_fee,
        refund_amount
    )
    VALUES (
        %s, %s, %s, %s, %s, %s, %s, %s
    )
    """
)


# ============================================================
# 6. SHIPMENTS
# ============================================================

load_table(
    "shipments_cleaned.csv",
    "shipments",
    [
        "shipment_id",
        "order_id",
        "warehouse_city",
        "delivery_city",
        "shipping_method",
        "dispatch_date",
        "expected_delivery_date",
        "actual_delivery_date",
        "delivery_days",
        "delivery_status",
        "delayed_flag",
        "delivery_delay_days",
        "is_delayed"
    ],
    """
    INSERT INTO shipments (
        shipment_id,
        order_id,
        warehouse_city,
        delivery_city,
        shipping_method,
        dispatch_date,
        expected_delivery_date,
        actual_delivery_date,
        delivery_days,
        delivery_status,
        delayed_flag,
        delivery_delay_days,
        is_delayed
    )
    VALUES (
        %s, %s, %s, %s, %s, %s, %s,
        %s, %s, %s, %s, %s, %s
    )
    """
)


# ============================================================
# 7. RETURNS
# ============================================================

load_table(
    "returns_cleaned.csv",
    "returns",
    [
        "return_id",
        "order_id",
        "customer_id",
        "product_id",
        "return_date",
        "return_reason",
        "refund_amount",
        "return_status"
    ],
    """
    INSERT INTO returns (
        return_id,
        order_id,
        customer_id,
        product_id,
        return_date,
        return_reason,
        refund_amount,
        return_status
    )
    VALUES (
        %s, %s, %s, %s, %s, %s, %s, %s
    )
    """
)


# ============================================================
# 8. CUSTOMER REVIEWS
# ============================================================

load_table(
    "customer_reviews_cleaned.csv",
    "customer_reviews",
    [
        "review_id",
        "order_id",
        "customer_id",
        "product_id",
        "review_date",
        "rating",
        "review_sentiment",
        "verified_purchase"
    ],
    """
    INSERT INTO customer_reviews (
        review_id,
        order_id,
        customer_id,
        product_id,
        review_date,
        rating,
        review_sentiment,
        verified_purchase
    )
    VALUES (
        %s, %s, %s, %s, %s, %s, %s, %s
    )
    """
)


# ============================================================
# Close Connection
# ============================================================

connection.close()

print("\n==========================================")
print("All remaining tables loaded successfully!")
print("Customers table was skipped.")
print("==========================================")