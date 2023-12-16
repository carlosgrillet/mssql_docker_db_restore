#!/bin/bash

echo "Creating backup directory..."
mkdir -p /var/opt/mssql/init

echo "Restoring database $(echo $MSSQL_DB_NAME)..."
cat <<EOF > /var/opt/mssql/init/setup.sql
USE master;

RESTORE DATABASE $(echo $MSSQL_DB_NAME)
FROM DISK = '/var/opt/mssql/backup/$(echo $MSSQL_DB_NAME).bak'
WITH
    MOVE '$(echo $MSSQL_DB_NAME)' TO '/var/opt/mssql/data/$(echo $MSSQL_DB_NAME).mdf',
    MOVE '$(echo $MSSQL_DB_NAME)_log' TO '/var/opt/mssql/data/$(echo $MSSQL_DB_NAME)_log.ldf',
    STATS = 5;

ALTER DATABASE $(echo $MSSQL_DB_NAME) SET ONLINE;

ALTER DATABASE $(echo $MSSQL_DB_NAME) SET MULTI_USER;
EOF

echo "Running setup.sql..."
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P $(echo $MSSQL_SA_PASSWORD) -i /var/opt/mssql/init/setup.sql
