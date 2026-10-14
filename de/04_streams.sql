--!jinja
--create stream 
CREATE STREAM IF NOT EXISTS {{db_name}}.{{schema_name}}.ORDERS_STG_STREAM ON TABLE {{db_name}}.{{schema_name}}.ORDERS_STG;
CREATE STREAM IF NOT EXISTS {{db_name}}.{{schema_name}}.CUSTOMER_ORDERS_STREAM ON TABLE {{db_name}}.{{schema_name}}.CUSTOMER_ORDERS;
