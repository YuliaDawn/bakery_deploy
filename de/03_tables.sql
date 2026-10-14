--!jinja
-- create staging table
CREATE TABLE IF NOT EXISTS {{db_name}}.{{schema_name}}.ORDERS_STG (
    customer varchar,
    order_date date,
    delivery_date date,
    baked_good_type varchar,
    quantity number,
    source_file_name varchar,
    load_ts timestamp
);

-- create warehousing table
CREATE TABLE IF NOT EXISTS {{db_name}}.{{schema_name}}.CUSTOMER_ORDERS (
    customer varchar,
    order_date date,
    delivery_date date,
    baked_good_type varchar,
    quantity number,
    source_file_name varchar,
    load_ts timestamp
);

-- create delivery table (summary table)
CREATE TABLE IF NOT EXISTS {{db_name}}.{{schema_name}}.SUMMARY_ORDERS(
    delivery_date date,
    baked_good_type varchar,
    total_quantity number
);
