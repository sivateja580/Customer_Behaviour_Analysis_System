import pandas as pd
from pathlib import Path

RAW_DIR = Path("data/raw")
PROCESSED_DIR = Path("data/processed")

print("\n=== PROCESSED DATA VALIDATION ===")

files = {
    "customers": (
        "customers.csv",
        "customers_cleaned.csv",
        ["has_purchased"]
    ),
    "orders": (
        "orders.csv",
        "orders_cleaned.csv",
        [
            "order_year",
            "order_month",
            "order_month_name",
            "order_quarter",
            "order_day_of_week",
            "order_hour",
            "is_weekend"
        ]
    ),
    "order_items": (
        "order_items.csv",
        "order_items_cleaned.csv",
        ["discount_amount"]
    ),
    "products": (
        "products.csv",
        "products_cleaned.csv",
        []
    ),
    "payments": (
        "payments.csv",
        "payments_cleaned.csv",
        []
    ),
    "shipments": (
        "shipments.csv",
        "shipments_cleaned.csv",
        [
            "delivery_delay_days",
            "is_delayed"
        ]
    ),
    "returns": (
        "returns.csv",
        "returns_cleaned.csv",
        []
    ),
    "reviews": (
        "customer_reviews.csv",
        "customer_reviews_cleaned.csv",
        []
    ),
    "marketing": (
        "marketing_campaigns.csv",
        "marketing_campaigns_cleaned.csv",
        []
    )
}

all_passed = True

for name, (raw_file, processed_file, new_columns) in files.items():

    raw_df = pd.read_csv(RAW_DIR / raw_file)
    processed_df = pd.read_csv(PROCESSED_DIR / processed_file)

    row_count_same = len(raw_df) == len(processed_df)

    missing_columns = [
        column
        for column in new_columns
        if column not in processed_df.columns
    ]

    columns_passed = len(missing_columns) == 0

    status = "PASS" if row_count_same and columns_passed else "CHECK"

    if status == "CHECK":
        all_passed = False

    print(
        f"{name:<15} "
        f"Rows: {len(raw_df):>8,} -> {len(processed_df):>8,} | "
        f"New columns: {len(new_columns):>2} | "
        f"{status}"
    )

    if missing_columns:
        print(
            f"   Missing columns: {missing_columns}"
        )

print("\n=== VALIDATION RESULT ===")

if all_passed:
    print("All processed datasets passed validation.")
else:
    print("Some datasets need investigation.")