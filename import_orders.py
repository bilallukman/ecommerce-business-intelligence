import os

import mysql.connector
import pandas as pd
from pathlib import Path

# CSV file location
file_path = Path(
    r"C:\Users\LOQ\OneDrive\Documents\ecommerce-business-intelligence\data\processed\orders.csv"
)

# Read CSV
df = pd.read_csv(file_path, dtype=str)
df = df.where(pd.notna(df), None)

# Connect to MySQL
connection = mysql.connector.connect(
    host="localhost",
    user="root",
    password=os.environ["MYSQL_PASSWORD"],
    database="ecommerce_analytics"
)

cursor = connection.cursor()

# Clear staging table before importing
cursor.execute("TRUNCATE TABLE staging_orders")

# Insert data in batches
columns = [
    "order_id",
    "customer_id",
    "order_status",
    "order_purchase_timestamp",
    "order_approved_at",
    "order_delivered_carrier_date",
    "order_delivered_customer_date",
    "order_estimated_delivery_date"
]

sql = """
INSERT INTO staging_orders (
    order_id, customer_id, order_status,
    order_purchase_timestamp, order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date
) VALUES (%s,%s,%s,%s,%s,%s,%s,%s)
"""

rows = [tuple(row) for row in df[columns].values]

for i in range(0, len(rows), 1000):
    cursor.executemany(sql, rows[i:i+1000])
    connection.commit()
    print(f"Imported {min(i+1000, len(rows))} / {len(rows)}")

cursor.execute("SELECT COUNT(*) FROM staging_orders")
print("Total imported:", cursor.fetchone()[0])

cursor.close()
connection.close()
