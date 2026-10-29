import pandas as pd

print("\n=== DATE / CHRONOLOGICAL VALIDATION ===")

customers = pd.read_csv("data/raw/customers.csv")
orders = pd.read_csv("data/raw/orders.csv")
payments = pd.read_csv("data/raw/payments.csv")
shipments = pd.read_csv("data/raw/shipments.csv")
returns = pd.read_csv("data/raw/returns.csv")
reviews = pd.read_csv("data/raw/customer_reviews.csv")

# Convert date columns
customers["customer_signup_date"] = pd.to_datetime(customers["customer_signup_date"])
customers["last_order_date"] = pd.to_datetime(customers["last_order_date"])

orders["order_date"] = pd.to_datetime(orders["order_date"])
payments["payment_date"] = pd.to_datetime(payments["payment_date"])
shipments["dispatch_date"] = pd.to_datetime(shipments["dispatch_date"])
shipments["expected_delivery_date"] = pd.to_datetime(
    shipments["expected_delivery_date"]
)
shipments["actual_delivery_date"] = pd.to_datetime(
    shipments["actual_delivery_date"]
)
returns["return_date"] = pd.to_datetime(returns["return_date"])
reviews["review_date"] = pd.to_datetime(reviews["review_date"])


# --------------------------------------------------
# 1. Overall date ranges
# --------------------------------------------------

print("\n1. DATE RANGES")

print(
    "Customer signup:",
    customers["customer_signup_date"].min().date(),
    "to",
    customers["customer_signup_date"].max().date()
)

print(
    "Orders:",
    orders["order_date"].min().date(),
    "to",
    orders["order_date"].max().date()
)

print(
    "Payments:",
    payments["payment_date"].min().date(),
    "to",
    payments["payment_date"].max().date()
)

print(
    "Returns:",
    returns["return_date"].min().date(),
    "to",
    returns["return_date"].max().date()
)

print(
    "Reviews:",
    reviews["review_date"].min().date(),
    "to",
    reviews["review_date"].max().date()
)


# --------------------------------------------------
# 2. Customer signup vs order date
# --------------------------------------------------

customer_orders = orders.merge(
    customers[["customer_id", "customer_signup_date"]],
    on="customer_id",
    how="left"
)

signup_order_errors = (
    customer_orders["order_date"]
    < customer_orders["customer_signup_date"]
).sum()

print("\n2. Orders before customer signup")
print(f"Invalid records: {signup_order_errors:,}")


# --------------------------------------------------
# 3. Payment date vs order date
# --------------------------------------------------

payment_orders = payments.merge(
    orders[["order_id", "order_date"]],
    on="order_id",
    how="left"
)

payment_errors = (
    payment_orders["payment_date"]
    < payment_orders["order_date"]
).sum()

print("\n3. Payments before order date")
print(f"Invalid records: {payment_errors:,}")


# --------------------------------------------------
# 4. Shipment chronological validation
# --------------------------------------------------

shipment_dispatch_errors = (
    shipments["dispatch_date"]
    < shipments["order_id"].map(
        orders.set_index("order_id")["order_date"]
    )
).sum()

print("\n4. Shipments dispatched before order")
print(f"Invalid records: {shipment_dispatch_errors:,}")


shipment_delivery_errors = (
    shipments["actual_delivery_date"]
    < shipments["dispatch_date"]
).sum()

print("\n5. Delivery before dispatch")
print(f"Invalid records: {shipment_delivery_errors:,}")


shipment_expected_errors = (
    shipments["expected_delivery_date"]
    < shipments["dispatch_date"]
).sum()

print("\n6. Expected delivery before dispatch")
print(f"Invalid records: {shipment_expected_errors:,}")


# --------------------------------------------------
# 5. Return date vs order date
# --------------------------------------------------

return_orders = returns.merge(
    orders[["order_id", "order_date"]],
    on="order_id",
    how="left"
)

return_errors = (
    return_orders["return_date"]
    < return_orders["order_date"]
).sum()

print("\n7. Returns before order")
print(f"Invalid records: {return_errors:,}")


# --------------------------------------------------
# 6. Review date vs order date
# --------------------------------------------------

review_orders = reviews.merge(
    orders[["order_id", "order_date"]],
    on="order_id",
    how="left"
)

review_errors = (
    review_orders["review_date"]
    < review_orders["order_date"]
).sum()

print("\n8. Reviews before order")
print(f"Invalid records: {review_errors:,}")


print("\n=== DATE VALIDATION COMPLETE ===")