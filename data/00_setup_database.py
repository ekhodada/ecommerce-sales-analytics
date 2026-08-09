"""
FILE: 00_setup_database.py
PURPOSE: Create the retail_analytics database and run the schema.
         Run this once before 02_generate_synthetic_data.py.

Usage:
    python data/00_setup_database.py
"""

import os
import getpass
import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT

_password = os.environ.get("PGPASSWORD") or getpass.getpass("PostgreSQL password: ")

BASE_CONFIG = {
    "host":     "localhost",
    "port":     5432,
    "dbname":   "postgres",   # connect to default db to create new one
    "user":     "postgres",
    "password": _password,
}

SCHEMA_PATH = os.path.join(os.path.dirname(__file__), "..", "schema", "01_create_tables.sql")

def create_database():
    conn = psycopg2.connect(**BASE_CONFIG)
    conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
    cur = conn.cursor()
    cur.execute("SELECT 1 FROM pg_database WHERE datname = 'retail_analytics'")
    if cur.fetchone():
        print("Database 'retail_analytics' already exists.")
    else:
        cur.execute("CREATE DATABASE retail_analytics")
        print("✓ Database 'retail_analytics' created.")
    cur.close()
    conn.close()

def run_schema():
    with open(SCHEMA_PATH, "r") as f:
        sql = f.read()
    conn = psycopg2.connect(**{**BASE_CONFIG, "dbname": "retail_analytics"})
    conn.autocommit = False
    cur = conn.cursor()
    try:
        cur.execute(sql)
        conn.commit()
        print("✓ Schema applied successfully.")
    except Exception as e:
        conn.rollback()
        print(f"✗ Schema error: {e}")
        raise
    finally:
        cur.close()
        conn.close()

if __name__ == "__main__":
    create_database()
    run_schema()
    print("\nDone. Now run: python data/02_generate_synthetic_data.py")
