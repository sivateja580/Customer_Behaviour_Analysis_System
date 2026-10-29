import pandas as pd
import glob
import os

files = glob.glob(r"data\raw\*.csv")

print("\n=== MISSING VALUES ===")

for file in files:
    filename = os.path.basename(file)

    # Skip documentation/validation files for now
    if filename in ["data_dictionary.csv", "dataset_validation_report.csv"]:
        continue

    df = pd.read_csv(file)

    missing = df.isna().sum()
    missing = missing[missing > 0]

    print(f"\n--- {filename} ---")

    if missing.empty:
        print("No missing values")
    else:
        print(missing.to_string())