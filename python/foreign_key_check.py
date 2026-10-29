import pandas as pd

print("\n=== FOREIGN KEY INTEGRITY CHECK ===")

customers = pd.read_csv("data/raw/customers.csv")
orders = pd.read_csv("data/raw/orders.csv")
order_items = pd.read_csv("data/raw/order_items.csv")
products = pd.read_csv("data/raw/products.csv")
payments = pd.read_csv("data/raw/payments.csv")
shipments = pd.read_csv("data/raw/shipments.csv")
returns = pd.read_csv("data/raw/returns.csv")
reviews = pd.read_csv("data/raw/customer_reviews.csv")
campaigns = pd.read_csv("data/raw/marketing_campaigns.csv")


def check_fk(child_df, child_col, parent_df, parent_col, relationship):
    invalid = (~child_df[child_col].isin(parent_df[parent_col])).sum()
    print(f"{relationship:<55} invalid: {invalid}")


check_fk(
    orders,
    "customer_id",
    customers,
    "customer_id",
    "orders.customer_id -> customers.customer_id"
)

check_fk(
    order_items,
    "order_id",
    orders,
    "order_id",
    "order_items.order_id -> orders.order_id"
)

check_fk(
    order_items,
    "product_id",
    products,
    "product_id",
    "order_items.product_id -> products.product_id"
)

check_fk(
    payments,
    "order_id",
    orders,
    "order_id",
    "payments.order_id -> orders.order_id"
)

check_fk(
    shipments,
    "order_id",
    orders,
    "order_id",
    "shipments.order_id -> orders.order_id"
)

check_fk(
    returns,
    "order_id",
    orders,
    "order_id",
    "returns.order_id -> orders.order_id"
)

check_fk(
    returns,
    "customer_id",
    customers,
    "customer_id",
    "returns.customer_id -> customers.customer_id"
)

check_fk(
    returns,
    "product_id",
    products,
    "product_id",
    "returns.product_id -> products.product_id"
)

check_fk(
    reviews,
    "order_id",
    orders,
    "order_id",
    "reviews.order_id -> orders.order_id"
)

check_fk(
    reviews,
    "customer_id",
    customers,
    "customer_id",
    "reviews.customer_id -> customers.customer_id"
)

check_fk(
    reviews,
    "product_id",
    products,
    "product_id",
    "reviews.product_id -> products.product_id"
)

# campaign_id is nullable, so only non-null values should be checked
valid_campaign_ids = orders["campaign_id"].dropna()

invalid_campaigns = (
    ~valid_campaign_ids.isin(campaigns["campaign_id"])
).sum()

print(
    f"{'orders.campaign_id -> marketing_campaigns.campaign_id':<55}"
    f" invalid: {invalid_campaigns}"
)