USE ROLE sysadmin;
USE DATABASE sage;

CREATE SCHEMA IF NOT EXISTS portal_raw
    WITH MANAGED ACCESS;

USE ROLE securityadmin;

GRANT USAGE ON FUTURE SCHEMAS IN DATABASE sage
TO ROLE PUBLIC;
GRANT SELECT ON FUTURE TABLES IN DATABASE sage
TO ROLE PUBLIC;
GRANT USAGE ON DATABASE sage
TO ROLE PUBLIC;

CREATE SCHEMA IF NOT EXISTS AD
    WITH MANAGED ACCESS;

USE ROLE securityadmin;
GRANT ALL PRIVILEGES ON SCHEMA AD
TO ROLE AD;
grant ALL PRIVILEGES ON FUTURE TABLES in schema AD
TO ROLE sysadmin;
GRANT USAGE ON DATABASE sage
TO ROLE AD;
