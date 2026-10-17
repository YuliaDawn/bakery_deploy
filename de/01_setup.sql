--!jinja
CREATE WAREHOUSE IF NOT EXISTS {{wh_name}}
    WAREHOUSE_SIZE='XSMALL';
CREATE DATABASE IF NOT EXISTS {{db_name}};
CREATE SCHEMA IF NOT EXISTS {{db_name}}.{{schema_name}};    

CREATE SCHEMA IF NOT EXISTS {{db_name}}.{{app_schema_name}};