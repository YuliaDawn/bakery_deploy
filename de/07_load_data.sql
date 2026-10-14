--!jinja
USE WAREHOUSE {{wh_name}};
USE DATABASE {{db_name}};
USE SCHEMA {{schema_name}};

ALTER GIT REPOSITORY {{git_repo_name}} FETCH;

COPY FILES
    INTO @{{db_name}}.{{schema_name}}.ORDERS_STAGE
    FROM @{{git_repo_name}}/branches/{{git_branch}}/data/
    pattern = '.*[.]csv';

EXECUTE TASK {{db_name}}.{{schema_name}}.t_root_bakery;