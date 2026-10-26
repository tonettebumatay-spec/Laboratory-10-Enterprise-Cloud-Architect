#!/bin/bash
BACKUP_DIR="/home/antonette/backups"
CONTAINER_NAME="wordpress_db"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="${BACKUP_DIR}/wordpress_db_${TIMESTAMP}.sql"
RETENTION_DAYS=7

mkdir -p "${BACKUP_DIR}"
echo "[$(date)] Starting backup..."

docker exec "${CONTAINER_NAME}" sh -c 'exec mysqldump --all-databases -u"$MYSQL_USER" -p"$MYSQL_PASSWORD"' > "${BACKUP_FILE}"

if [ $? -eq 0 ]; then
  echo "[$(date)] Backup successful: ${BACKUP_FILE}"
  gzip "${BACKUP_FILE}"
  find "${BACKUP_DIR}" -name "*.sql.gz" -type f -mtime +${RETENTION_DAYS} -delete
  echo "[$(date)] Old backups cleaned."
else
  echo "[$(date)] ERROR: Backup failed!" >&2
  exit 1
fi
