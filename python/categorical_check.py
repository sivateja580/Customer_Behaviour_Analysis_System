import pandas as pd

print("\n=== CATEGORICAL VALUE CHECK ===")

checks = {
    "customers.csv": [
        "gender",
        "age_group",
        "customer_segment",
        "preferred_device",
        "preferred_payment_method",
        "customer_status",
        "loyalty_tier"
    ],
    "orders.csv": [
        "order_status",
        "shipping_method"
    ],
    "payments.csv": [
        "payment_method",
        "payment_status"
    ],
    "shipments.csv": [
        "shipping_method",
        "delivery_status"
    ],
    "returns.csv": [
        "return_reason",
        "return_status"
    ],
    "customer_reviews.csv": [
        "review_sentiment",
        "verified_purchase"
    ],
    "products.csv": [
        "product_type"
    ]
}

for filename, columns in checks.items():

    df = pd.read_csv(f"data/raw/{filename}")

    print(f"\n--- {filename} ---")

    for column in columns:
        print(f"\n{column}:")
        print(df[column].value_counts(dropna=False).to_string())