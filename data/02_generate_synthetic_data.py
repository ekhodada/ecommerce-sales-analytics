"""
FILE: 02_generate_synthetic_data.py
PURPOSE: Generate realistic synthetic data and load it into the retail_analytics
         PostgreSQL database. Uses the Faker library for realistic names/addresses.

Requirements:
    pip install psycopg2-binary faker pandas

Usage:
    python data/02_generate_synthetic_data.py
"""

import os
import random
import getpass
import psycopg2
from faker import Faker
from datetime import date, timedelta, datetime

# ── Configuration — prompts for password if not in env ────────
_password = os.environ.get("PGPASSWORD") or getpass.getpass("PostgreSQL password: ")
DB_CONFIG = {
    "host":     "localhost",
    "port":     5432,
    "dbname":   "retail_analytics",
    "user":     "postgres",
    "password": _password,
}

random.seed(42)
fake = Faker("en_US")
Faker.seed(42)

START_DATE = date(2022, 1, 1)
END_DATE   = date(2024, 12, 31)

# ── Helpers ───────────────────────────────────────────────────

def random_date(start: date, end: date) -> date:
    delta = (end - start).days
    return start + timedelta(days=random.randint(0, delta))


def date_range(start: date, end: date):
    current = start
    while current <= end:
        yield current
        current += timedelta(days=1)


# ── Data definitions ──────────────────────────────────────────

REGIONS = [
    ("Northeast", "USA", "Patricia Moore"),
    ("Southeast", "USA", "James Wilson"),
    ("Midwest",   "USA", "Sandra Chen"),
    ("Southwest", "USA", "Robert Garcia"),
    ("West",      "USA", "Michelle Tran"),
]

PRODUCTS = [
    # (name, category, subcategory, brand, unit_price, cost_price)
    # Electronics
    ("Laptop Pro 15",         "Electronics", "Computers",    "TechPeak",   1299.99, 780.00),
    ("Wireless Mouse X300",   "Electronics", "Accessories",  "LogiMax",      29.99,  12.00),
    ("Mechanical Keyboard",   "Electronics", "Accessories",  "KeyMaster",    89.99,  38.00),
    ("4K Monitor 27-inch",    "Electronics", "Displays",     "VisionEdge",  449.99, 210.00),
    ("USB-C Hub 7-port",      "Electronics", "Accessories",  "HubLink",      49.99,  18.00),
    ("Noise Cancelling Headphones","Electronics","Audio",    "SoundWave",   199.99,  85.00),
    ("Webcam HD 1080p",       "Electronics", "Accessories",  "ClearView",    79.99,  30.00),
    ("Portable SSD 1TB",      "Electronics", "Storage",      "DataVault",   109.99,  55.00),
    # Office Supplies
    ("Premium Notebook A4",   "Office Supplies","Stationery","WriteRight",    9.99,   3.50),
    ("Ballpoint Pen Set 12",  "Office Supplies","Stationery","InkFlow",       7.99,   2.00),
    ("Desk Organizer Pro",    "Office Supplies","Furniture",  "OfficePlus",   34.99,  14.00),
    ("Whiteboard 48x36",      "Office Supplies","Furniture",  "BoardMaster",  89.99,  40.00),
    ("Stapler Heavy Duty",    "Office Supplies","Tools",      "BindIt",       24.99,   9.00),
    ("Paper Ream A4 500 sheets","Office Supplies","Paper",   "CopyPro",       8.99,   3.00),
    # Furniture
    ("Ergonomic Office Chair","Furniture",    "Seating",      "ComfortSeat", 349.99, 160.00),
    ("Standing Desk Electric","Furniture",    "Desks",        "RiseDesk",    699.99, 320.00),
    ("Bookshelf 5-Tier",      "Furniture",    "Storage",      "ShelfWorks",  129.99,  55.00),
    ("Filing Cabinet 3-Drawer","Furniture",   "Storage",      "StoragePro",  189.99,  85.00),
    # Clothing
    ("Business Casual Shirt", "Clothing",     "Tops",         "StyleWear",    49.99,  18.00),
    ("Formal Trousers",       "Clothing",     "Bottoms",      "FitLine",      69.99,  25.00),
    ("Blazer Classic Fit",    "Clothing",     "Outerwear",    "BoardroomCo", 119.99,  45.00),
    ("Polo Shirt Pack 3",     "Clothing",     "Tops",         "EverWear",     39.99,  14.00),
    # Food & Beverages
    ("Premium Coffee Beans 1kg","Food & Beverages","Coffee", "BrewSelect",   24.99,   9.00),
    ("Green Tea Assorted 50ct","Food & Beverages","Tea",     "TeaGarden",    14.99,   5.00),
    ("Energy Bar Pack 12",    "Food & Beverages","Snacks",   "FuelUp",       19.99,   7.00),
]

EMPLOYEES = [
    ("Alice",   "Nguyen",   "Sales",     "Senior Sales Rep"),
    ("Brian",   "Patel",    "Sales",     "Sales Rep"),
    ("Carmen",  "Lopez",    "Sales",     "Sales Manager"),
    ("David",   "Kim",      "Sales",     "Sales Rep"),
    ("Emily",   "Johnson",  "Sales",     "Sales Rep"),
    ("Frank",   "O'Brien",  "Operations","Operations Analyst"),
    ("Grace",   "Williams", "Marketing", "Marketing Analyst"),
    ("Henry",   "Zhang",    "Sales",     "Senior Sales Rep"),
    ("Irene",   "Davis",    "Sales",     "Sales Rep"),
    ("Jake",    "Robinson", "Operations","Data Analyst"),
]

PAYMENT_METHODS  = ["Credit Card", "Debit Card", "PayPal", "Bank Transfer", "Gift Card"]
SHIPPING_METHODS = ["Standard", "Express", "Overnight", "Store Pickup"]
ORDER_STATUSES   = ["Delivered", "Delivered", "Delivered", "Shipped", "Processing", "Cancelled"]
RETURN_REASONS   = [
    "Defective product", "Wrong item shipped", "Changed mind",
    "Item not as described", "Duplicate order", "Better price found",
]
SEGMENTS         = ["Bronze", "Silver", "Gold", "Platinum"]
SEGMENT_WEIGHTS  = [0.40, 0.30, 0.20, 0.10]


# ── Loaders ───────────────────────────────────────────────────

def load_dim_date(cur):
    print("Loading dim_date …")
    rows = []
    for d in date_range(START_DATE, END_DATE):
        rows.append((
            d,
            d.year,
            (d.month - 1) // 3 + 1,
            d.month,
            d.strftime("%B"),
            int(d.strftime("%W")),
            d.isoweekday(),        # 1=Mon … 7=Sun
            d.strftime("%A"),
            d.isoweekday() >= 6,   # is_weekend
            False,                 # is_holiday (extend as needed)
        ))
    cur.executemany("""
        INSERT INTO dim_date
            (date_id, year, quarter, month, month_name, week_of_year, day_of_week, day_name, is_weekend, is_holiday)
        VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
        ON CONFLICT DO NOTHING
    """, rows)
    print(f"  Inserted {len(rows)} date rows.")


def load_dim_regions(cur):
    print("Loading dim_regions …")
    for name, country, manager in REGIONS:
        cur.execute("""
            INSERT INTO dim_regions (region_name, country, manager_name)
            VALUES (%s, %s, %s) RETURNING region_id
        """, (name, country, manager))
    print(f"  Inserted {len(REGIONS)} regions.")


def load_dim_products(cur):
    print("Loading dim_products …")
    for p in PRODUCTS:
        stock = random.randint(10, 500)
        cur.execute("""
            INSERT INTO dim_products
                (product_name, category, subcategory, brand, unit_price, cost_price, stock_quantity)
            VALUES (%s,%s,%s,%s,%s,%s,%s)
        """, (*p, stock))
    print(f"  Inserted {len(PRODUCTS)} products.")


def load_dim_employees(cur):
    print("Loading dim_employees …")
    cur.execute("SELECT region_id FROM dim_regions ORDER BY region_id")
    region_ids = [r[0] for r in cur.fetchall()]
    for i, (fn, ln, dept, role) in enumerate(EMPLOYEES):
        rid = region_ids[i % len(region_ids)]
        hire = random_date(date(2018, 1, 1), date(2022, 6, 30))
        cur.execute("""
            INSERT INTO dim_employees (first_name, last_name, email, department, role, region_id, hire_date)
            VALUES (%s,%s,%s,%s,%s,%s,%s)
        """, (fn, ln, f"{fn.lower()}.{ln.lower().replace(' ','_')}@retailco.com",
              dept, role, rid, hire))
    print(f"  Inserted {len(EMPLOYEES)} employees.")


def load_dim_customers(cur, n=600):
    print(f"Loading {n} customers …")
    cur.execute("SELECT region_id FROM dim_regions ORDER BY region_id")
    region_ids = [r[0] for r in cur.fetchall()]
    for _ in range(n):
        fn  = fake.first_name()
        ln  = fake.last_name()
        rid = random.choice(region_ids)
        reg_date = random_date(date(2020, 1, 1), END_DATE)
        seg = random.choices(SEGMENTS, weights=SEGMENT_WEIGHTS)[0]
        cur.execute("""
            INSERT INTO dim_customers
                (first_name, last_name, email, phone, city, state, zip_code,
                 region_id, registration_date, customer_segment, is_active)
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
        """, (
            fn, ln,
            fake.unique.email(),
            fake.phone_number()[:20],
            fake.city(), fake.state(), fake.zipcode()[:10],
            rid, reg_date, seg,
            random.random() > 0.05,   # 95% active
        ))
    print(f"  Inserted {n} customers.")


def load_facts(cur, n_orders=5000):
    print(f"Loading {n_orders} orders + items + returns …")
    cur.execute("SELECT customer_id, registration_date FROM dim_customers")
    customers = cur.fetchall()

    cur.execute("SELECT employee_id FROM dim_employees WHERE department='Sales'")
    emp_ids = [r[0] for r in cur.fetchall()]

    cur.execute("SELECT region_id FROM dim_regions")
    region_ids = [r[0] for r in cur.fetchall()]

    cur.execute("SELECT product_id, unit_price FROM dim_products")
    products = cur.fetchall()

    return_candidates = []

    for _ in range(n_orders):
        cust_id, reg_date = random.choice(customers)
        # Order must be after customer registration
        order_date = random_date(max(reg_date, START_DATE), END_DATE)
        status     = random.choices(ORDER_STATUSES, weights=[40,40,30,15,10,5])[0]

        ship_date     = None
        delivery_date = None
        if status in ("Shipped", "Delivered"):
            ship_date = order_date + timedelta(days=random.randint(1, 5))
        if status == "Delivered" and ship_date:
            delivery_date = ship_date + timedelta(days=random.randint(1, 7))

        cur.execute("""
            INSERT INTO fact_orders
                (customer_id, employee_id, region_id, order_date, ship_date,
                 delivery_date, order_status, payment_method, shipping_method, discount_pct)
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s) RETURNING order_id
        """, (
            cust_id,
            random.choice(emp_ids),
            random.choice(region_ids),
            order_date, ship_date, delivery_date,
            status,
            random.choice(PAYMENT_METHODS),
            random.choice(SHIPPING_METHODS),
            random.choice([0, 0, 0, 5, 10, 15, 20]),
        ))
        order_id = cur.fetchone()[0]

        # 1–5 line items per order
        n_items   = random.randint(1, 5)
        chosen_products = random.sample(products, min(n_items, len(products)))
        for prod_id, list_price in chosen_products:
            qty      = random.randint(1, 4)
            price    = float(list_price)
            discount = round(price * random.choice([0, 0, 0.05, 0.10, 0.15]), 2) * qty
            cur.execute("""
                INSERT INTO fact_order_items (order_id, product_id, quantity, unit_price, discount_amount)
                VALUES (%s,%s,%s,%s,%s)
            """, (order_id, prod_id, qty, price, discount))

            if status == "Delivered" and random.random() < 0.06:
                return_candidates.append((order_id, prod_id, delivery_date, qty))

    # Returns (≈ 6% of delivered lines)
    for order_id, prod_id, del_date, qty in return_candidates:
        ret_date = del_date + timedelta(days=random.randint(1, 30))
        if ret_date > END_DATE:
            continue
        cur.execute("SELECT unit_price FROM fact_order_items WHERE order_id=%s AND product_id=%s LIMIT 1",
                    (order_id, prod_id))
        row = cur.fetchone()
        if not row:
            continue
        ret_qty    = random.randint(1, qty)
        refund_amt = round(float(row[0]) * ret_qty * random.uniform(0.8, 1.0), 2)
        cur.execute("""
            INSERT INTO fact_returns (order_id, product_id, return_date, return_reason, quantity_returned, refund_amount)
            VALUES (%s,%s,%s,%s,%s,%s)
        """, (order_id, prod_id, ret_date, random.choice(RETURN_REASONS), ret_qty, refund_amt))

    print("  Done loading orders, items, and returns.")


# ── Main ──────────────────────────────────────────────────────

def main():
    conn = psycopg2.connect(**DB_CONFIG)
    conn.autocommit = False
    cur = conn.cursor()
    try:
        load_dim_date(cur)
        load_dim_regions(cur)
        load_dim_products(cur)
        load_dim_employees(cur)
        load_dim_customers(cur, n=600)
        load_facts(cur, n_orders=5000)
        conn.commit()
        print("\n✓ All data loaded successfully.")
    except Exception as exc:
        conn.rollback()
        print(f"\n✗ Error: {exc}")
        raise
    finally:
        cur.close()
        conn.close()


if __name__ == "__main__":
    main()
