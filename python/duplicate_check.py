import pandas as pd

tables = {
    "customers.csv": "customer_id",
    "orders.csv": "order_id",
    "order_items.csv": "order_item_id",
    "products.csv": "product_id",
    "payments.csv": "payment_id",
    "shipments.csv": "shipment_id",
    "returns.csv": "return_id",
    "customer_reviews.csv": "review_id",
    "marketing_campaigns.csv": "campaign_id"
}

print("\n=== PRIMARY KEY DUPLICATE CHECK ===")

for filename, key in tables.items():
    path = f"data/raw/{filename}"
    df = pd.read_csv(path)

    duplicates = df[key].duplicated().sum()

    print(f"{filename:<30} {key:<25} duplicates: {duplicates}")