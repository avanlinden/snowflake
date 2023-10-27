USE ROLE SYSADMIN;
USE DATABASE SYNAPSE_DATA_WAREHOUSE;
USE SCHEMA SYNAPSE;

-- Create certified quiz question latest
CREATE OR REPLACE TABLE SYNAPSE_DATA_WAREHOUSE.SYNAPSE.CERTIFIEDQUIZQUESTION_LATEST AS
WITH CQQ_RANKED AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY RESPONSE_ID, QUESTION_INDEX
            ORDER BY IS_CORRECT DESC, INSTANCE DESC
        ) AS ROW_NUM
    FROM SYNAPSE_DATA_WAREHOUSE.SYNAPSE_RAW.CERTIFIEDQUIZQUESTION
)

SELECT * EXCLUDE ROW_NUM
FROM CQQ_RANKED
WHERE ROW_NUM = 1
ORDER BY RESPONSE_ID DESC, QUESTION_INDEX ASC;

-- Create certified quiz latest
CREATE OR REPLACE TABLE SYNAPSE_DATA_WAREHOUSE.SYNAPSE.CERTIFIEDQUIZ_LATEST AS
WITH CQQ_RANKED AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY USER_ID
            ORDER BY INSTANCE DESC, RESPONSE_ID DESC
        ) AS ROW_NUM
    FROM SYNAPSE_DATA_WAREHOUSE.SYNAPSE_RAW.CERTIFIEDQUIZ
)

SELECT * EXCLUDE ROW_NUM
FROM CQQ_RANKED
WHERE ROW_NUM = 1;
-- verify that the de-duplication occured
SELECT
    COUNT(*) AS NUMBER_OF_CERTIFIED_QUIZ,
    COUNT(DISTINCT USER_ID) AS NUMBER_OF_UNIQUE_USERS
FROM SYNAPSE_DATA_WAREHOUSE.SYNAPSE.CERTIFIEDQUIZ_LATEST;

// Use a window function to get the latest user profile snapshot and create a table
CREATE OR REPLACE TABLE SYNAPSE_DATA_WAREHOUSE.SYNAPSE.USERPROFILE_LATEST AS WITH
RANKED_NODES AS (
    SELECT
        *,
        "row_number"()
            OVER (
                PARTITION BY ID
                ORDER BY CHANGE_TIMESTAMP DESC, SNAPSHOT_TIMESTAMP DESC
            )
            AS N
    FROM
        SYNAPSE_DATA_WAREHOUSE.SYNAPSE_RAW.USERPROFILESNAPSHOT
    WHERE
        (SNAPSHOT_DATE >= CURRENT_TIMESTAMP - INTERVAL '30 DAYS')
)

SELECT * EXCLUDE N
FROM RANKED_NODES
WHERE N = 1;

-- use role masking_admin;
-- USE SCHEMA synapse_data_warehouse.synapse;
-- ALTER TABLE IF EXISTS userprofile_latest
-- MODIFY COLUMN email
-- SET MASKING POLICY email_mask;
USE ROLE SYSADMIN;
CREATE OR REPLACE TABLE SYNAPSE_DATA_WAREHOUSE.SYNAPSE.TEAMMEMBER_LATEST AS WITH
RANKED_NODES AS (
    SELECT
        *,
        "row_number"()
            OVER (
                PARTITION BY MEMBER_ID
                ORDER BY CHANGE_TIMESTAMP DESC, SNAPSHOT_TIMESTAMP DESC
            )
            AS N
    FROM
        SYNAPSE_DATA_WAREHOUSE.SYNAPSE_RAW.TEAMMEMBERSNAPSHOTS
    WHERE
        (SNAPSHOT_DATE >= CURRENT_TIMESTAMP - INTERVAL '30 DAYS')
)

SELECT * EXCLUDE N
FROM RANKED_NODES
WHERE N = 1;
ALTER TABLE SYNAPSE_DATA_WAREHOUSE.SYNAPSE.TEAMMEMBER_LATEST ADD PRIMARY KEY (
    MEMBER_ID
);

CREATE OR REPLACE TABLE SYNAPSE_DATA_WAREHOUSE.SYNAPSE.TEAM_LATEST AS WITH
RANKED_NODES AS (
    SELECT
        *,
        "row_number"()
            OVER (
                PARTITION BY ID
                ORDER BY CHANGE_TIMESTAMP DESC, SNAPSHOT_TIMESTAMP DESC
            )
            AS N
    FROM SYNAPSE_DATA_WAREHOUSE.SYNAPSE_RAW.TEAMSNAPSHOTS
    WHERE
        (SNAPSHOT_DATE >= CURRENT_TIMESTAMP - INTERVAL '30 DAYS')
)

SELECT *
FROM RANKED_NODES
WHERE N = 1;
ALTER TABLE SYNAPSE_DATA_WAREHOUSE.SYNAPSE.TEAM_LATEST ADD PRIMARY KEY (ID);

SELECT
    COUNT(*) AS NUMBER_OF_TEAMS,
    COUNT(DISTINCT ID) AS NUMBER_OF_UNIQUE_TEAMS
FROM SYNAPSE_DATA_WAREHOUSE.SYNAPSE.TEAM_LATEST;
-- filesnapshots
CREATE OR REPLACE TABLE SYNAPSE_DATA_WAREHOUSE.SYNAPSE.FILE_LATEST AS WITH
RANKED_NODES AS (
    SELECT
        *,
        "row_number"()
            OVER (
                PARTITION BY ID
                ORDER BY CHANGE_TIMESTAMP DESC, SNAPSHOT_TIMESTAMP DESC
            )
            AS N
    FROM SYNAPSE_DATA_WAREHOUSE.SYNAPSE_RAW.FILESNAPSHOTS
    WHERE
        (SNAPSHOT_DATE >= CURRENT_TIMESTAMP - INTERVAL '60 DAYS')
        AND NOT IS_PREVIEW
        AND CHANGE_TYPE != 'DELETE'
)

SELECT * EXCLUDE N
FROM RANKED_NODES
WHERE N = 1;

-- node snapshot latest
CREATE OR REPLACE TABLE SYNAPSE_DATA_WAREHOUSE.SYNAPSE.NODE_LATEST AS WITH
RANKED_NODES AS (
    SELECT
        *,
        "row_number"()
            OVER (
                PARTITION BY ID
                ORDER BY CHANGE_TIMESTAMP DESC, SNAPSHOT_TIMESTAMP DESC
            )
            AS N
    FROM SYNAPSE_DATA_WAREHOUSE.SYNAPSE_RAW.NODESNAPSHOTS
    WHERE
        (SNAPSHOT_DATE >= CURRENT_TIMESTAMP - INTERVAL '30 DAYS')
        AND CHANGE_TYPE != 'DELETE'
)

SELECT * EXCLUDE N
FROM RANKED_NODES
WHERE N = 1;
-- verify node snapshot have been de-duplicated
SELECT
    COUNT(*) AS NUMBER_OF_NODES,
    COUNT(DISTINCT ID) AS NUMBER_OF_UNIQUE_NODES
FROM SYNAPSE_DATA_WAREHOUSE.SYNAPSE.NODE_LATEST;

-- Created certified question information and loaded the table manually
CREATE TABLE IF NOT EXISTS SYNAPSE_DATA_WAREHOUSE.SYNAPSE.CERTIFIED_QUESTION_INFORMATION (
    QUESTION_INDEX NUMBER,
    QUESTION_GROUP_NUMBER NUMBER,
    VERSION STRING, --noqa: RF04
    FRE_Q FLOAT,
    FRE_HELP FLOAT,
    DIFFERENCE_FRE FLOAT,
    FKGL_Q NUMBER,
    FKGL_HELP FLOAT,
    DIFFERENCE_FKGL FLOAT,
    NOTES STRING,
    TYPE STRING, --noqa: RF04
    QUESTION_TEXT STRING
);

-- Create View of user profile and cert join
CREATE OR REPLACE VIEW SYNAPSE_DATA_WAREHOUSE.SYNAPSE.USER_CERTIFIED AS
WITH CERT AS (
    SELECT
        USER_ID,
        PASSED
    FROM SYNAPSE_DATA_WAREHOUSE.SYNAPSE.CERTIFIEDQUIZ_LATEST
),

USER_CERT_JOINED AS (
    SELECT
        USER.*,
        CERT.*
    FROM SYNAPSE_DATA_WAREHOUSE.SYNAPSE.USERPROFILE_LATEST AS USER  --noqa: RF04
    LEFT JOIN CERT
        ON USER.ID = CERT.USER_ID
)

SELECT
    ID,
    USER_NAME,
    FIRST_NAME,
    LAST_NAME,
    EMAIL,
    LOCATION,
    COMPANY,
    POSITION,
    PASSED
FROM USER_CERT_JOINED;
-- zero copy clone of processed access records
CREATE OR REPLACE TABLE SYNAPSE_DATA_WAREHOUSE.SYNAPSE.PROCESSEDACCESS
CLONE SYNAPSE_DATA_WAREHOUSE.SYNAPSE_RAW.PROCESSEDACCESS;

-- zero copy clone of file download records
CREATE OR REPLACE TABLE SYNAPSE_DATA_WAREHOUSE.SYNAPSE.FILEDOWNLOAD
CLONE SYNAPSE_DATA_WAREHOUSE.SYNAPSE_RAW.FILEDOWNLOAD;

CREATE OR REPLACE TABLE SYNAPSE_DATA_WAREHOUSE.SYNAPSE.FILEUPLOAD
CLONE SYNAPSE_DATA_WAREHOUSE.SYNAPSE_RAW.FILEUPLOAD;
