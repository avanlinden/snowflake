USE ROLE PUBLIC;
USE DATABASE SYNAPSE_DATA_WAREHOUSE;
USE SCHEMA SYNAPSE;
-- Data up to October 18th for now

-- Total number of downloads in synapse
WITH DEDUP_FILEHANDLE AS (
    SELECT DISTINCT
        USER_ID,
        FILE_HANDLE_ID AS FD_FILE_HANDLE_ID,
        RECORD_DATE
    FROM
        SYNAPSE_DATA_WAREHOUSE.SYNAPSE.FILEDOWNLOAD
)

SELECT count(*)
FROM
    DEDUP_FILEHANDLE;

-- Download count per month in Synapse

WITH DEDUP_FILEHANDLE AS (
    SELECT DISTINCT
        USER_ID,
        FILE_HANDLE_ID AS FD_FILE_HANDLE_ID,
        RECORD_DATE
    FROM
        SYNAPSE_DATA_WAREHOUSE.SYNAPSE.FILEDOWNLOAD
)

SELECT
    date_trunc('MONTH', RECORD_DATE) AS MONTH,
    count(*) AS NUMBER_OF_DOWNLOADS
FROM
    DEDUP_FILEHANDLE
GROUP BY
    MONTH
ORDER BY
    MONTH DESC;
-- * Number of files within each portal in snowflake
USE SCHEMA SAGE.PORTAL_RAW;
SELECT
    TABLE_NAME,
    ROW_COUNT
FROM
    INFORMATION_SCHEMA.TABLES
WHERE
    TABLE_SCHEMA = 'PORTAL_RAW'
ORDER BY
    ROW_COUNT DESC;

-- When do file download records begin?
SELECT DISTINCT RECORD_DATE
FROM
    SYNAPSE_DATA_WAREHOUSE.SYNAPSE_RAW.FILEDOWNLOAD
ORDER BY
    RECORD_DATE ASC;

-- * Metrics for AD portal
USE SCHEMA SAGE.PORTAL_DOWNLOADS;
-- Total download count for AD portal
SELECT count(*)
FROM
    AD_DOWNLOADS;
-- distribution of AD portal downloads per month
SELECT
    date_trunc('MONTH', RECORD_DATE) AS MONTH,
    count(*) AS NUMBER_OF_DOWNLOADS
FROM
    AD_DOWNLOADS
GROUP BY
    MONTH
ORDER BY
    MONTH DESC;

SELECT count(DISTINCT USER_ID)
FROM
    AD_DOWNLOADS;

-- * GENIE
-- All download counts over time
SELECT count(*)
FROM
    GENIE_DOWNLOADS;

-- Distribution of downloads over months
SELECT
    date_trunc('MONTH', RECORD_DATE) AS MONTH,
    count(*) AS NUMBER_OF_DOWNLOADS
FROM
    GENIE_DOWNLOADS
GROUP BY
    MONTH
ORDER BY
    MONTH DESC;

-- Number of unique users downloading the data
SELECT count(DISTINCT USER_ID)
FROM
    GENIE_DOWNLOADS;
-- * ELITE
SELECT count(*)
FROM
    ELITE_DOWNLOADS;
SELECT
    date_trunc('MONTH', RECORD_DATE) AS MONTH,
    count(*) AS NUMBER_OF_DOWNLOADS
FROM
    ELITE_DOWNLOADS
GROUP BY
    MONTH
ORDER BY
    MONTH DESC;

SELECT count(DISTINCT USER_ID)
FROM
    ELITE_DOWNLOADS;

-- * NF
-- Total download
SELECT count(*)
FROM
    NF_DOWNLOADS;
SELECT
    date_trunc('MONTH', RECORD_DATE) AS MONTH,
    count(*) AS NUMBER_OF_DOWNLOADS
FROM
    NF_DOWNLOADS
GROUP BY
    MONTH
ORDER BY
    MONTH DESC;
SELECT count(DISTINCT USER_ID)
FROM
    NF_DOWNLOADS;

-- psychencode
SELECT count(*)
FROM
    PSYCHENCODE_DOWNLOADS;

SELECT
    date_trunc('MONTH', RECORD_DATE) AS MONTH,
    count(*) AS NUMBER_OF_DOWNLOADS
FROM
    PSYCHENCODE_DOWNLOADS
GROUP BY
    MONTH
ORDER BY
    MONTH DESC;
SELECT count(DISTINCT USER_ID)
FROM
    PSYCHENCODE_DOWNLOADS;
-- HTAN
SELECT count(*)
FROM
    HTAN_DOWNLOADS;

SELECT
    date_trunc('MONTH', RECORD_DATE) AS MONTH,
    count(*) AS NUMBER_OF_DOWNLOADS
FROM
    HTAN_DOWNLOADS
GROUP BY
    MONTH
ORDER BY
    MONTH DESC;

SELECT count(DISTINCT USER_ID)
FROM
    HTAN_DOWNLOADS;
