--!jinja
ALTER TASK IF EXISTS {{db_name}}.{{schema_name}}.t_root_bakery SUSPEND;
--root task: empty root task
CREATE OR REPLACE TASK {{db_name}}.{{schema_name}}.t_root_bakery
    WAREHOUSE={{wh_name}}
    SCHEDULE ='1 HOUR'
AS
    SELECT 1;

--this task runs automatically after t_root
CREATE OR REPLACE TASK {{db_name}}.{{schema_name}}.t_loading
    WAREHOUSE ={{wh_name}}
    AFTER {{db_name}}.{{schema_name}}.t_root_bakery
AS
    call {{db_name}}.{{schema_name}}.load_file();

--this task runs automatically after t_loading
CREATE OR REPLACE TASK {{db_name}}.{{schema_name}}.t_warehouse
    WAREHOUSE = {{wh_name}}
    AFTER {{db_name}}.{{schema_name}}.t_loading
    WHEN SYSTEM$STREAM_HAS_DATA('{{db_name}}.{{schema_name}}.ORDERS_STG_STREAM')
AS
    call {{db_name}}.{{schema_name}}.transform_warehouse();

--this task runs automatically after t_warehouse
CREATE OR REPLACE TASK {{db_name}}.{{schema_name}}.t_summary
    WAREHOUSE = {{wh_name}}
    AFTER {{db_name}}.{{schema_name}}.t_warehouse
    WHEN SYSTEM$STREAM_HAS_DATA('{{db_name}}.{{schema_name}}.CUSTOMER_ORDERS_STREAM')
AS
    call {{db_name}}.{{schema_name}}.Transform_Daily_Summary();


SELECT SYSTEM$TASK_DEPENDENTS_ENABLE('{{db_name}}.{{schema_name}}.t_root_bakery');