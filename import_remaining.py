import os

import mysql.connector
import pandas as pd
from pathlib import Path

# Project paths
project_path = Path(__file__).parent
data_path = project_path / "data" / "processed"

# MySQL connection
connection = mysql.connector.connect(
    host="localhost",
    user="root",
    password=os.environ["MYSQL_PASSWORD"],
    database="ecommerce_analytics"
)

cursor = connection.cursor()

# Datasets to import
datasets = {
    "order_items": "order_items.csv",
    "payments": "payments.csv",
    "reviews": "reviews.csv",
    "products": "products.csv",
    "sellers": "sellers.csv",
    "category_translation": "category_translation.csv",
    "geolocation_lookup": "geolocation_lookup.csv"
}

for table, filename in datasets.items():

    print(f"\nImporting {table}...")

    file_path = data_path / filename

    if not file_path.exists():
        print(f"FILE NOT FOUND: {filename}")
        continue

    # Read CSV
    df = pd.read_csv(file_path, dtype=str)
    df = df.astype(object).where(pd.notna(df), None)

    # Convert Boolean values only for geolocation
    if table == "geolocation_lookup":
        df["valid_brazil_coordinates"] = (
            df["valid_brazil_coordinates"]
            .astype(str)
            .str.strip()
            .str.lower()
            .map({
                "true": 1,
                "false": 0,
                "1": 1,
                "0": 0
            })
        )

    columns = list(df.columns)

    # Check whether target table already contains data
    cursor.execute(f"SELECT COUNT(*) FROM `{table}`")
    existing_count = cursor.fetchone()[0]

    if existing_count > 0:
        print(
            f"SKIPPED: {table} already contains "
            f"{existing_count} rows."
        )
        continue

    # Build SQL insert statement
    column_names = ", ".join(
        f"`{col}`" for col in columns
    )
    placeholders = ", ".join(
        ["%s"] * len(columns)
    )

    sql = f"""
        INSERT INTO `{table}` ({column_names})
        VALUES ({placeholders})
    """

    rows = [
        tuple(row)
        for row in df.itertuples(index=False, name=None)
    ]

    try:
        # Import in batches
        for i in range(0, len(rows), 1000):
            cursor.executemany(
                sql,
                rows[i:i + 1000]
            )

            print(
                f"Processed {min(i + 1000, len(rows))}"
                f" / {len(rows)}"
            )

        # Commit only after the entire table succeeds
        connection.commit()

        cursor.execute(
            f"SELECT COUNT(*) FROM `{table}`"
        )
        imported_count = cursor.fetchone()[0]

        print(
            f"SUCCESS: {table} — "
            f"{imported_count} rows"
        )

    except Exception as error:
        connection.rollback()
        print(f"ERROR importing {table}: {error}")

cursor.close()
connection.close()

print("\nImport process completed.")
