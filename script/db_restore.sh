#!/bin/bash

backup_folder="/var/opt/mssql/backup/"

# verify if there is a backup file
if [ -f "$(ls -A "$backup_folder")" ]; then
  echo "ERROR: No backup file found!"
  exit 1
fi

for file_path in "$backup_folder"/*; do
  if [ -f "$file_path" ]; then
    file=$(basename "$file_path")
    MSSQL_DB_NAME="${file%.*}"

    echo "Creating backup directory..."
    mkdir -p /var/opt/mssql/init

    echo "Geting mdf and ldf files..."
    MDF=$(/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P $(echo $MSSQL_SA_PASSWORD) \
      -Q 'RESTORE FILELISTONLY FROM DISK = "/var/opt/mssql/backup/'$(echo $MSSQL_DB_NAME)'.bak"' \
      | tr -s ' ' | cut -d ' ' -f 1-2 | grep '.mdf')
     
    LDF=$(/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P $(echo $MSSQL_SA_PASSWORD) \
      -Q 'RESTORE FILELISTONLY FROM DISK = "/var/opt/mssql/backup/'$(echo $MSSQL_DB_NAME)'.bak"' \
      | tr -s ' ' | cut -d ' ' -f 1-2 | grep '.ldf')

    MDF_NAME=$(echo $MDF | awk 'NR==1{print $1}')
    MDF_FILE=$(echo $MDF | awk 'NR==1{print $2}' | grep -oP '(?<=\\)[^\\]+$')
    LDF_NAME=$(echo $LDF | awk 'NR==1{print $1}')
    LDF_FILE=$(echo $LDF | awk 'NR==1{print $2}' | grep -oP '(?<=\\)[^\\]+$')

    # verify if the database already exists
    if [ -e "/var/opt/mssql/data/$(echo $MDF_FILE)" ]; then
      echo "ERROR: Database $MDF_FILE is repeated!"
      continue
    fi

    echo "Restoring database $(echo $MSSQL_DB_NAME)..."
    cat <<EOF > /var/opt/mssql/init/setup.sql
    USE master;

    RESTORE DATABASE $(echo $MSSQL_DB_NAME)
    FROM DISK = '/var/opt/mssql/backup/$(echo $MSSQL_DB_NAME).bak'
    WITH
        MOVE '$MDF_NAME' TO '/var/opt/mssql/data/$MDF_FILE',
        MOVE '$LDF_NAME' TO '/var/opt/mssql/data/$LDF_FILE';

    ALTER DATABASE $(echo $MSSQL_DB_NAME) SET ONLINE;
    ALTER DATABASE $(echo $MSSQL_DB_NAME) SET MULTI_USER;
EOF


    echo "Running setup.sql..."
    /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P $(echo $MSSQL_SA_PASSWORD) -i /var/opt/mssql/init/setup.sql

    fi
done

