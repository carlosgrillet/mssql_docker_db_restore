USE master;

-- Restore the database from the .bak file
RESTORE DATABASE db_test
FROM DISK = '/var/opt/mssql/backup/db.bak'  -- Update the path accordingly
WITH
    MOVE 'db_test' TO '/var/opt/mssql/data/db_test.mdf',  -- Update the logical and physical file paths
    MOVE 'db_test_log' TO '/var/opt/mssql/data/db_test_log.ldf',  -- Update the logical and physical file paths
    STATS = 5;  -- Specify the number of progress messages to be displayed

-- Optionally, bring the database online
ALTER DATABASE db_test SET ONLINE;

-- Optionally, set the database to the MULTI_USER mode
ALTER DATABASE db_test SET MULTI_USER;

