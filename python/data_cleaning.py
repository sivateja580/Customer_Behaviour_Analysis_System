import pandas as pd
from pathlib import Path

# ============================================================
# CUSTOMER BEHAVIOUR ANALYSIS SYSTEM
# Data Cleaning & Transformation Pipeline
# ============================================================

RAW_DIR = Path("data/raw")
PROCESSED_DIR = Path("data/processed")

PROCESSED_DIR.mkdir(parents=True, exist_ok=True)

print("\n=== DATA CLEANING PIPELINE ===")
print("Loading raw datasets...\n")

# ------------------------------------------------------------
# 1. Load raw datasets
# ------------------------------------------------------------

customers = pd.read_csv(RAW_DIR / "customers.csv")
orders = pd.read_csv(RAW_DIR / "orders.csv")
order_items = pd.read_csv(RAW_DIR / "order_items.csv")
products = pd.read_csv(RAW_DIR / "products.csv")
payments = pd.read_csv(RAW_DIR / "payments.csv")
shipments = pd.read_csv(RAW_DIR / "shipments.csv")
returns = pd.read_csv(RAW_DIR / "returns.csv")
reviews = pd.read_csv(RAW_DIR / "customer_reviews.csv")
marketing = pd.read_csv(RAW_DIR / "marketing_campaigns.csv")

datasets = {
    "customers": customers,
    "orders": orders,
    "order_items": order_items,
    "products": products,
    "payments": payments,
    "shipments": shipments,
    "returns": returns,
    "reviews": reviews,
    "marketing": marketing,
}

print("Datasets loaded successfully:\n")

for name, df in datasets.items():
    print(f"{name:<15} {df.shape[0]:>8,} rows | {df.shape[1]:>2} columns")


# ------------------------------------------------------------
# 2. Convert date columns
# ------------------------------------------------------------

date_columns = {
    "customers": [
        "customer_signup_date",
        "last_order_date"
    ],

    "orders": [
        "order_date"
    ],

    "payments": [
        "payment_date"
    ],

    "shipments": [
        "dispatch_date",
        "expected_delivery_date",
        "actual_delivery_date"
    ],

    "returns": [
        "return_date"
    ],

    "reviews": [
        "review_date"
    ],

    "products": [
        "product_launch_date"
    ],

    "marketing": [
        "campaign_start_date",
        "campaign_end_date"
    ],
}

for dataset_name, columns in date_columns.items():

    df = datasets[dataset_name]

    for column in columns:
        if column in df.columns:
            df[column] = pd.to_datetime(
                df[column],
                errors="coerce"
            )


print("\nDate columns standardized.")


# ------------------------------------------------------------
# 3. Strip whitespace from text columns
# ------------------------------------------------------------

for name, df in datasets.items():

    text_columns = df.select_dtypes(
        include=["object", "string"]
    ).columns

    for column in text_columns:
        df[column] = df[column].apply(
            lambda x: x.strip() if isinstance(x, str) else x
        )

print("Text fields standardized.")


# ------------------------------------------------------------
# 4. Standardize selected text fields
# ------------------------------------------------------------

# Keep business values unchanged while ensuring consistent
# capitalization/spacing.

text_standardization = {
    "customers": [
        "gender",
        "age_group",
        "customer_segment",
        "preferred_device",
        "preferred_payment_method",
        "acquisition_channel",
        "customer_status",
        "loyalty_tier",
        "state",
        "city",
    ],

    "orders": [
        "order_status",
        "shipping_method",
        "delivery_city",
        "delivery_state",
        "marketing_channel",
    ],

    "products": [
        "category",
        "subcategory",
        "brand",
        "product_type",
    ],

    "payments": [
        "payment_method",
        "payment_status",
    ],

    "shipments": [
        "warehouse_city",
        "delivery_city",
        "shipping_method",
        "delivery_status",
    ],

    "returns": [
        "return_reason",
        "return_status",
    ],

    "reviews": [
        "review_sentiment",
    ],

    "marketing": [
        "channel",
        "campaign_type",
        "target_segment",
    ],
}

for dataset_name, columns in text_standardization.items():

    df = datasets[dataset_name]

    for column in columns:

        if column in df.columns:

            df[column] = df[column].apply(
                lambda x: x.title() if isinstance(x, str) else x
            )


print("Categorical text fields standardized.")


# ------------------------------------------------------------
# 5. Preserve business meaning of missing values
# ------------------------------------------------------------

# No blanket filling of missing values.
#
# Examples:
# coupon_code NULL -> no coupon
# campaign_id NULL -> no campaign attribution
# last_order_date NULL -> potentially never purchased
# actual_delivery_date NULL -> delivery unavailable
#
# These will be handled specifically during analysis/reporting.

print("Missing values preserved according to business meaning.")


# ------------------------------------------------------------
# 6. Create analytical features
# ------------------------------------------------------------

print("\nCreating analytical features...")


# ============================================================
# ORDERS
# ============================================================

orders["order_year"] = orders["order_date"].dt.year

orders["order_month"] = orders["order_date"].dt.month

orders["order_month_name"] = orders["order_date"].dt.month_name()

orders["order_quarter"] = (
    "Q" + orders["order_date"].dt.quarter.astype(str)
)

orders["order_day_of_week"] = (
    orders["order_date"].dt.day_name()
)

orders["order_hour"] = (
    pd.to_datetime(
        orders["order_time"],
        format="%H:%M:%S",
        errors="coerce"
    ).dt.hour
)

orders["is_weekend"] = (
    orders["order_date"].dt.dayofweek >= 5
)


# ============================================================
# ORDER ITEMS
# ============================================================

order_items["discount_amount"] = (
    order_items["quantity"]
    * order_items["unit_price"]
    * order_items["discount_percentage"]
    / 100
)


# ============================================================
# SHIPMENTS
# ============================================================

shipments["delivery_delay_days"] = (
    shipments["actual_delivery_date"]
    - shipments["expected_delivery_date"]
).dt.days

shipments["is_delayed"] = (
    shipments["delivery_delay_days"] > 0
)


# ============================================================
# CUSTOMERS
# ============================================================

customers["has_purchased"] = (
    customers["total_orders"] > 0
)


print("Analytical features created successfully.")

# ------------------------------------------------------------
# 8. Export processed datasets
# ------------------------------------------------------------

print("\n=== EXPORTING PROCESSED DATASETS ===")

output_files = {
    "customers": "customers_cleaned.csv",
    "orders": "orders_cleaned.csv",
    "order_items": "order_items_cleaned.csv",
    "products": "products_cleaned.csv",
    "payments": "payments_cleaned.csv",
    "shipments": "shipments_cleaned.csv",
    "returns": "returns_cleaned.csv",
    "reviews": "customer_reviews_cleaned.csv",
    "marketing": "marketing_campaigns_cleaned.csv",
}

for name, filename in output_files.items():

    datasets[name].to_csv(
        PROCESSED_DIR / filename,
        index=False
    )

    print(f"Created: {filename}")

print("\n=== PROCESSED DATA EXPORT COMPLETE ===")