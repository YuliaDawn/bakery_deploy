--!jinja
-- create a file FORMAT
CREATE OR REPLACE FILE FORMAT {{db_name}}.{{schema_name}}.ORDERS_CSV_FORMAT
    TYPE ='CSV'
    FIELD_DELIMITER=','
    SKIP_HEADER=1
    FIELD_OPTIONALLY_ENCLOSED_BY='"'
    NULL_IF =('NULL', 'null', '');

-- create a stage
CREATE STAGE IF NOT EXISTS {{db_name}}.{{schema_name}}.ORDERS_STAGE;