#!/bin/bash 

set -e 

TIMESTAMP=$(date + %Y%m%D_%H%M%S)
BACKUP_DIR="./backups"
mkdir -p "$BACKUP_DIR"

docker exec hotel_db pg_dump -U appuser -d hotel_app -F c \
    > "$BACKUP_DIR/hotel_app_$TIMESTAMP.dump"


echo "Backup created: $BACKUP_DIR/hotel_app_$TIMESTAMP.dump"