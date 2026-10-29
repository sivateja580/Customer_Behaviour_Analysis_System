import pandas as pd
import numpy as np

print("\n=== NUMERICAL / BUSINESS LOGIC VALIDATION ===")

orders = pd.read_csv("data/raw/orders.csv")
items = pd.read_csv("data/raw/order_items.csv")

# --------------------------------------------------
# 1. Validate order final amount
# --------------------------------------------------

orders["calculated_final_amount"] = (
    orders["subtotal"]
    + orders["shipping_fee"]
    + orders["tax_amount"]
)

orders["amount_difference"] = (
    orders["final_amount"]
    - orders["calculated_final_amount"]
)

order_errors = (
    orders["amount_difference"].abs() > 0.01
).sum()

print("\n1. Orders - final_amount calculation")
print(f"Rows checked: {len(orders):,}")
print(f"Calculation mismatches: {order_errors:,}")

# --------------------------------------------------
# 2. Validate item revenue
# --------------------------------------------------

items["calculated_item_revenue"] = (
    items["quantity"]
    * items["unit_price"]
    * (1 - items["discount_percentage"] / 100)
)

items["revenue_difference"] = (
    items["item_revenue"]
    - items["calculated_item_revenue"]
)

revenue_errors = (
    items["revenue_difference"].abs() > 0.01
).sum()

print("\n2. Order Items - item_revenue calculation")
print(f"Rows checked: {len(items):,}")
print(f"Calculation mismatches: {revenue_errors:,}")

# --------------------------------------------------
# 3. Validate profit
# --------------------------------------------------

items["calculated_profit"] = (
    items["item_revenue"] - items["item_cost"]
)

items["profit_difference"] = (
    items["profit"] - items["calculated_profit"]
)

profit_errors = (
    items["profit_difference"].abs() > 0.01
).sum()

print("\n3. Order Items - profit calculation")
print(f"Rows checked: {len(items):,}")
print(f"Calculation mismatches: {profit_errors:,}")

# --------------------------------------------------
# 4. Check negative values
# --------------------------------------------------

print("\n4. Negative value checks")

numeric_columns = [
    "subtotal",
    "shipping_fee",
    "tax_amount",
    "final_amount"
]

for column in numeric_columns:
    negative_count = (orders[column] < 0).sum()
    print(f"orders.{column}: {negative_count:,} negative values")

numeric_item_columns = [
    "quantity",
    "unit_price",
    "item_revenue",
    "item_cost"
]

for column in numeric_item_columns:
    negative_count = (items[column] < 0).sum()
    print(f"order_items.{column}: {negative_count:,} negative values")

print("\n=== VALIDATION COMPLETE ===")