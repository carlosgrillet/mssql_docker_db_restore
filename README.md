# Docker MS SQL DB restoring

## Config

### Proyect tree
```
.
├── README.md
├── docker-compose.yaml
├── backup
│   ├── <your_backup_file>.bak
└── script
    └── db_restore.sh
```

> `<your_backup_file>` is the backup file that contains the database
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
      - MSSQL_SA_PASSWORD=<your-secure-password>
    volumes:
      - ./backup:/var/opt/mssql/backup
      - ./script/db_restore.sh:/db_restore.sh
      - local_sqldata:/var/lib/sqldata/data
volumes:
  local_sqldata:
```

## Usage

> run docker compose with `docker compose up -d`

> restore database in the container with `docker exec dbtest /bin/bash db_restore.sh`

> Tip: you can put multiple .bak files in the `backup` directory
