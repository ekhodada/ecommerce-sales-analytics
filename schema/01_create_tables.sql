-- ============================================================
-- FILE: 01_create_tables.sql
-- PURPOSE: Full schema for the Retail Sales Analytics database
-- Database: PostgreSQL 14+
-- ============================================================

-- ── Extensions ───────────────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ── Clean slate (for re-runs during development) ─────────────
DROP TABLE IF EXISTS data_quality_log   CASCADE;
DROP TABLE IF EXISTS fact_returns        CASCADE;
DROP TABLE IF EXISTS fact_order_items    CASCADE;
DROP TABLE IF EXISTS fact_orders         CASCADE;
DROP TABLE IF EXISTS dim_date            CASCADE;
DROP TABLE IF EXISTS dim_employees       CASCADE;
DROP TABLE IF EXISTS dim_products        CASCADE;
DROP TABLE IF EXISTS dim_customers       CASCADE;
DROP TABLE IF EXISTS dim_regions         CASCADE;

-- ── Dimension: Regions ───────────────────────────────────────
CREATE TABLE dim_regions (
    region_id     SERIAL        PRIMARY KEY,
    region_name   VARCHAR(50)   NOT NULL,
    country       VARCHAR(50)   NOT NULL DEFAULT 'USA',
    manager_name  VARCHAR(100),
    created_at    TIMESTAMP     NOT NULL DEFAULT NOW()
);

-- ── Dimension: Customers ─────────────────────────────────────
CREATE TABLE dim_customers (
    customer_id        SERIAL       PRIMARY KEY,
    first_name         VARCHAR(50)  NOT NULL,
    last_name          VARCHAR(50)  NOT NULL,
    email              VARCHAR(120) NOT NULL UNIQUE,
    phone              VARCHAR(20),
    city               VARCHAR(60),
    state              VARCHAR(50),
    zip_code           VARCHAR(10),
    region_id          INTEGER      REFERENCES dim_regions(region_id),
    registration_date  DATE         NOT NULL,
    customer_segment   VARCHAR(20)  NOT NULL CHECK (customer_segment IN ('Bronze','Silver','Gold','Platinum')),
    is_active          BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at         TIMESTAMP    NOT NULL DEFAULT NOW(),
    updated_at         TIMESTAMP    NOT NULL DEFAULT NOW()
);

-- ── Dimension: Products ──────────────────────────────────────
CREATE TABLE dim_products (
    product_id     SERIAL          PRIMARY KEY,
    product_name   VARCHAR(120)    NOT NULL,
    category       VARCHAR(60)     NOT NULL,
    subcategory    VARCHAR(60),
    brand          VARCHAR(60),
    unit_price     NUMERIC(10,2)   NOT NULL CHECK (unit_price > 0),
    cost_price     NUMERIC(10,2)   NOT NULL CHECK (cost_price > 0),
    stock_quantity INTEGER         NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    is_active      BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at     TIMESTAMP       NOT NULL DEFAULT NOW()
);

-- ── Dimension: Employees ─────────────────────────────────────
CREATE TABLE dim_employees (
    employee_id  SERIAL       PRIMARY KEY,
    first_name   VARCHAR(50)  NOT NULL,
    last_name    VARCHAR(50)  NOT NULL,
    email        VARCHAR(120) NOT NULL UNIQUE,
    department   VARCHAR(50)  NOT NULL,
    role         VARCHAR(60)  NOT NULL,
    region_id    INTEGER      REFERENCES dim_regions(region_id),
    hire_date    DATE         NOT NULL,
    is_active    BOOLEAN      NOT NULL DEFAULT TRUE
);

-- ── Dimension: Date (pre-populated by the Python generator) ──
CREATE TABLE dim_date (
    date_id       DATE         PRIMARY KEY,
    year          SMALLINT     NOT NULL,
    quarter       SMALLINT     NOT NULL CHECK (quarter BETWEEN 1 AND 4),
    month         SMALLINT     NOT NULL CHECK (month  BETWEEN 1 AND 12),
    month_name    VARCHAR(12)  NOT NULL,
    week_of_year  SMALLINT     NOT NULL,
    day_of_week   SMALLINT     NOT NULL CHECK (day_of_week BETWEEN 1 AND 7),
    day_name      VARCHAR(12)  NOT NULL,
    is_weekend    BOOLEAN      NOT NULL,
    is_holiday    BOOLEAN      NOT NULL DEFAULT FALSE
);

-- ── Fact: Orders ─────────────────────────────────────────────
CREATE TABLE fact_orders (
    order_id        SERIAL       PRIMARY KEY,
    customer_id     INTEGER      NOT NULL REFERENCES dim_customers(customer_id),
    employee_id     INTEGER      REFERENCES dim_employees(employee_id),
    region_id       INTEGER      NOT NULL REFERENCES dim_regions(region_id),
    order_date      DATE         NOT NULL REFERENCES dim_date(date_id),
    ship_date       DATE,
    delivery_date   DATE,
    order_status    VARCHAR(20)  NOT NULL CHECK (order_status IN
                       ('Pending','Processing','Shipped','Delivered','Cancelled')),
    payment_method  VARCHAR(30)  NOT NULL,
    shipping_method VARCHAR(30)  NOT NULL,
    discount_pct    NUMERIC(5,2) NOT NULL DEFAULT 0 CHECK (discount_pct BETWEEN 0 AND 100),
    created_at      TIMESTAMP    NOT NULL DEFAULT NOW(),
    -- Derived constraint: ship date must be after order date
    CONSTRAINT chk_ship_after_order    CHECK (ship_date     IS NULL OR ship_date     >= order_date),
    CONSTRAINT chk_delivery_after_ship CHECK (delivery_date IS NULL OR delivery_date >= ship_date)
);

-- ── Fact: Order Items ────────────────────────────────────────
CREATE TABLE fact_order_items (
    item_id         SERIAL        PRIMARY KEY,
    order_id        INTEGER       NOT NULL REFERENCES fact_orders(order_id),
    product_id      INTEGER       NOT NULL REFERENCES dim_products(product_id),
    quantity        INTEGER       NOT NULL CHECK (quantity > 0),
    unit_price      NUMERIC(10,2) NOT NULL CHECK (unit_price > 0),
    discount_amount NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK (discount_amount >= 0),
    line_total      NUMERIC(10,2) GENERATED ALWAYS AS
                        (ROUND(quantity * unit_price - discount_amount, 2)) STORED
);

-- ── Fact: Returns ────────────────────────────────────────────
CREATE TABLE fact_returns (
    return_id         SERIAL       PRIMARY KEY,
    order_id          INTEGER      NOT NULL REFERENCES fact_orders(order_id),
    product_id        INTEGER      NOT NULL REFERENCES dim_products(product_id),
    return_date       DATE         NOT NULL,
    return_reason     VARCHAR(100) NOT NULL,
    quantity_returned INTEGER      NOT NULL CHECK (quantity_returned > 0),
    refund_amount     NUMERIC(10,2) NOT NULL CHECK (refund_amount >= 0)
);

-- ── Audit: Data Quality Log ──────────────────────────────────
CREATE TABLE data_quality_log (
    log_id           SERIAL       PRIMARY KEY,
    table_name       VARCHAR(100) NOT NULL,
    check_name       VARCHAR(120) NOT NULL,
    check_type       VARCHAR(50)  NOT NULL,  -- 'Completeness','Consistency','Validity','Uniqueness'
    records_checked  INTEGER      NOT NULL DEFAULT 0,
    records_failed   INTEGER      NOT NULL DEFAULT 0,
    failure_rate     NUMERIC(6,3) GENERATED ALWAYS AS
                         (CASE WHEN records_checked = 0 THEN 0
                               ELSE ROUND(records_failed::NUMERIC / records_checked * 100, 3)
                          END) STORED,
    threshold_pct    NUMERIC(5,2) NOT NULL DEFAULT 5.0,  -- acceptable failure %
    status           VARCHAR(10)  NOT NULL CHECK (status IN ('PASS','FAIL','WARNING')),
    run_date         TIMESTAMP    NOT NULL DEFAULT NOW(),
    notes            TEXT
);

-- ── Indexes for query performance ────────────────────────────
CREATE INDEX idx_orders_customer      ON fact_orders(customer_id);
CREATE INDEX idx_orders_date          ON fact_orders(order_date);
CREATE INDEX idx_orders_status        ON fact_orders(order_status);
CREATE INDEX idx_order_items_order    ON fact_order_items(order_id);
CREATE INDEX idx_order_items_product  ON fact_order_items(product_id);
CREATE INDEX idx_returns_order        ON fact_returns(order_id);
CREATE INDEX idx_customers_segment    ON dim_customers(customer_segment);
CREATE INDEX idx_customers_region     ON dim_customers(region_id);
CREATE INDEX idx_products_category    ON dim_products(category);
CREATE INDEX idx_date_year_month      ON dim_date(year, month);
