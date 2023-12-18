# Docker MS SQL DB restoring

## Config

### Proyect tree
```
.
├── backup
│   └── <your_backup_file>.bak
├── docker-compose.yaml
└── script
    ├── db_restore.sh
    └── setup.sql
```

> `<your_backup_file>` is the backup file that contains the databas
you want to restore

### docker compose file

```yaml
version: '3.8'
services:
  dbtest:
    image: mcr.microsoft.com/mssql/server:2022-latest
    container_name: dbtest
    hostname: dbtest
    ports:
      - "1433:1433"
    environment:
      - ACCEPT_EULA=Y
      - MSSQL_SA_PASSWORD=<yourPasswordHere>
      - MSSQL_DB_NAME=<dbName>
    volumes:
      - ./backup/:/var/opt/mssql/backup/
      - ./script/db_restore.sh:/db_restore.sh
```

> `MSSQL_DB_NAME` should be the same name that `your_backup_file`. Ex: 
> if the backup file is named *bkp_db_prod.bak* the db name should be
> named *bkp_db_prod*

## Usage

> run docker compose with `docker compose up -d`

> restore database in the container with `docker exec dbtest /bin/bash db_restore.sh`
