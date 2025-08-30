#!/bin/bash
# PostgreSQL Configuration Backup Script for n8n
# Created: 2025-08-28

BACKUP_DIR="/home/user/n8n/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

echo "=== PostgreSQL Configuration Backup Script ==="
echo "Timestamp: $TIMESTAMP"

# Backup PostgreSQL configuration files
echo "Backing up PostgreSQL configuration files..."
sudo cp /etc/postgresql-17/pg_hba.conf "$BACKUP_DIR/pg_hba.conf.$TIMESTAMP"
sudo cp /etc/postgresql-17/postgresql.conf "$BACKUP_DIR/postgresql.conf.$TIMESTAMP"

# Backup database schema (structure only)
echo "Backing up n8n_db schema..."
PGPASSWORD='n8n_secure_pass_2024' pg_dump -h localhost -U n8n -d n8n_db --schema-only > "$BACKUP_DIR/n8n_db_schema.$TIMESTAMP.sql"

# Set proper permissions
chmod 600 "$BACKUP_DIR"/*

echo "Backup completed in: $BACKUP_DIR"
echo "Files created:"
ls -la "$BACKUP_DIR"/*.$TIMESTAMP* 2>/dev/null | awk '{print "  - " $NF}'