--!jinja
-- define transformative stored-proc
CREATE OR REPLACE PROCEDURE {{db_name}}.{{schema_name}}.load_file()
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
BEGIN
    COPY INTO {{db_name}}.{{schema_name}}.ORDERS_STG
     FROM(
        SELECT $1, $2, $3, $4, $5, metadata$filename, current_timestamp()
        FROM @{{db_name}}.{{schema_name}}.ORDERS_STAGE
     )
    FILE_FORMAT=(FORMAT_NAME= '{{db_name}}.{{schema_name}}.ORDERS_CSV_FORMAT')
    ON_ERROR='ABORT_STATEMENT'
    PURGE =TRUE;
RETURN 'transformation done';
END;
$$;



--define transformative stored-proc
CREATE OR REPLACE PROCEDURE {{db_name}}.{{schema_name}}.transform_warehouse()
    RETURNS VARCHAR
    LANGUAGE SQL
AS
$$
BEGIN
    --merge into the target table
    MERGE INTO {{db_name}}.{{schema_name}}.CUSTOMER_ORDERS tgt
    --the source stream
    USING {{db_name}}.{{schema_name}}.ORDERS_STG_STREAM AS src
    --the columns that ensure uniqueness
    ON src.customer=tgt.customer
    AND src.delivery_date=tgt.delivery_date
    AND src.baked_good_type=tgt.baked_good_type
    --update the warehousing table with the values from the source table
    WHEN MATCHED THEN
        update set tgt.quantity=src.quantity,
                tgt.source_file_name=src.source_file_name,
                tgt.load_ts=current_timestamp()
    --insert new values from the source table into the warehousing table
    WHEN NOT MATCHED THEN
        INSERT (
                customer,
                order_date,
                delivery_date,
                baked_good_type,
                quantity,
                source_file_name,
                load_ts)
        VALUES (src.customer,
                src.order_date,
                src.delivery_date,
                src.baked_good_type,
                src.quantity,
                src.source_file_name,
                current_timestamp());
        RETURN 'transformation done';
    END;
    $$;


    --define stored procedure
    CREATE OR REPLACE PROCEDURE {{db_name}}.{{schema_name}}.Transform_Daily_Summary()
    RETURNS VARCHAR
    LANGUAGE SQL
    AS
    $$
    BEGIN
        --merge into the target table
        MERGE INTO {{db_name}}.{{schema_name}}.SUMMARY_ORDERS tgt
        
        -- the source table
        USING (
            SELECT delivery_date, baked_good_type, sum(quantity) as total_quantity
            FROM {{db_name}}.{{schema_name}}.CUSTOMER_ORDERS
            WHERE (delivery_date, baked_good_type)IN (
                SELECT DISTINCT delivery_date, baked_good_type
                FROM {{db_name}}.{{schema_name}}.CUSTOMER_ORDERS_STREAM
            )
            GROUP BY ALL
        )
        AS src
        
        --the columns that ensure uniqueness
        ON src.delivery_date=tgt.delivery_date
            AND src.baked_good_type=tgt.baked_good_type
        
        --update the warehousing table with the values from the source table
        WHEN MATCHED THEN
            UPDATE SET tgt.total_quantity=src.total_quantity
        
        --insert new values from the source table into the warehousing table
        WHEN NOT MATCHED THEN
            INSERT (delivery_date,
                    baked_good_type,
                    total_quantity
                    )
            VALUES (src.delivery_date,
                    src.baked_good_type,
                    src.total_quantity
                    );
    RETURN 'transformation done';
    END;
    $$;