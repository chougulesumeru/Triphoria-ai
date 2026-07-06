#!/bin/bash

set -e 

BACKUP_FILE=$1

if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: ./scripts/restore.sh <backup file>"
    exit 1
fi

docker exec -i hotel_db psql -U appuser -d postgres -c "DROP DATABASE IF EXISTS hotel_app_restore;"
docker exec -i hotel_db psql -U appuser -d postgres -c "CREATE DATABASE hotel_app_restore;"

cat "$BACKUP_FILE" | docker exec -i hotel_db pg_restore -U appuser -d hotel_app_restore

echo "Restored into database: hotel_app_restore"
echo "Verify with: docker exec -it hotel_db psql -U appuser -d hotel_app_restore -c '\dt'"