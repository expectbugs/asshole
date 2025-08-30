#!/bin/bash
# n8n Backup Script for Gentoo Linux
# Creates timestamped backups of n8n configuration and database

set -e

# Configuration
BACKUP_DIR="/home/user/n8n/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="n8n_backup_${TIMESTAMP}"
N8N_DATA_DIR="/var/lib/n8n"
N8N_LOG_DIR="/var/log/n8n"
DB_NAME="n8n_db"
DB_USER="n8n"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Create backup directory if it doesn't exist
mkdir -p "${BACKUP_DIR}/${BACKUP_NAME}"

echo -e "${GREEN}Starting n8n backup...${NC}"
echo "Backup name: ${BACKUP_NAME}"

# 1. Backup n8n configuration files
echo -e "${YELLOW}Backing up n8n configuration...${NC}"
if [ -f "${N8N_DATA_DIR}/.env" ]; then
    sudo cp "${N8N_DATA_DIR}/.env" "${BACKUP_DIR}/${BACKUP_NAME}/.env"
    sudo chown $(whoami):$(whoami) "${BACKUP_DIR}/${BACKUP_NAME}/.env"
    chmod 644 "${BACKUP_DIR}/${BACKUP_NAME}/.env"
    echo "  ✓ .env file backed up"
fi

if [ -d "${N8N_DATA_DIR}/.n8n" ]; then
    sudo cp -r "${N8N_DATA_DIR}/.n8n" "${BACKUP_DIR}/${BACKUP_NAME}/"
    sudo chown -R $(whoami):$(whoami) "${BACKUP_DIR}/${BACKUP_NAME}/.n8n"
    chmod -R 755 "${BACKUP_DIR}/${BACKUP_NAME}/.n8n"
    echo "  ✓ .n8n directory backed up"
fi

# 2. Backup OpenRC service file
echo -e "${YELLOW}Backing up service configuration...${NC}"
if [ -f "/etc/init.d/n8n" ]; then
    sudo cp "/etc/init.d/n8n" "${BACKUP_DIR}/${BACKUP_NAME}/n8n.init"
    sudo chown $(whoami):$(whoami) "${BACKUP_DIR}/${BACKUP_NAME}/n8n.init"
    echo "  ✓ OpenRC init script backed up"
fi

if [ -f "/etc/conf.d/n8n" ]; then
    sudo cp "/etc/conf.d/n8n" "${BACKUP_DIR}/${BACKUP_NAME}/n8n.conf"
    sudo chown $(whoami):$(whoami) "${BACKUP_DIR}/${BACKUP_NAME}/n8n.conf"
    echo "  ✓ Service configuration backed up"
fi

# 3. Backup PostgreSQL database
echo -e "${YELLOW}Backing up PostgreSQL database...${NC}"
sudo -u postgres pg_dump ${DB_NAME} > "${BACKUP_DIR}/${BACKUP_NAME}/n8n_database.sql"
echo "  ✓ Database backed up to n8n_database.sql"

# 4. Backup MCP configuration
echo -e "${YELLOW}Backing up MCP configuration...${NC}"
if [ -d "/home/user/n8n/.claude" ]; then
    cp -r "/home/user/n8n/.claude" "${BACKUP_DIR}/${BACKUP_NAME}/"
    echo "  ✓ MCP configuration backed up"
fi

# 5. Create backup metadata
echo -e "${YELLOW}Creating backup metadata...${NC}"
cat > "${BACKUP_DIR}/${BACKUP_NAME}/backup_info.txt" << EOF
n8n Backup Information
======================
Backup Date: $(date)
Backup Name: ${BACKUP_NAME}
n8n Version: $(n8n --version 2>/dev/null || echo "Unknown")
PostgreSQL Version: $(sudo -u postgres psql --version | head -1)
System: Gentoo Linux on $(uname -r)
Database Size: $(sudo -u postgres psql -d ${DB_NAME} -t -c "SELECT pg_size_pretty(pg_database_size('${DB_NAME}'));" 2>/dev/null || echo "Unknown")

Files Included:
- n8n configuration (.env)
- n8n data directory (.n8n)
- OpenRC service files
- PostgreSQL database dump
- MCP configuration

To restore from this backup, use: ./restore-n8n.sh ${BACKUP_NAME}
EOF

# 6. Compress the backup
echo -e "${YELLOW}Compressing backup...${NC}"
cd "${BACKUP_DIR}"
tar -czf "${BACKUP_NAME}.tar.gz" "${BACKUP_NAME}/"
rm -rf "${BACKUP_NAME}/"
echo "  ✓ Backup compressed to ${BACKUP_NAME}.tar.gz"

# 7. Show backup size and location
BACKUP_SIZE=$(du -h "${BACKUP_DIR}/${BACKUP_NAME}.tar.gz" | cut -f1)
echo -e "${GREEN}Backup completed successfully!${NC}"
echo "Location: ${BACKUP_DIR}/${BACKUP_NAME}.tar.gz"
echo "Size: ${BACKUP_SIZE}"

# 8. Clean up old backups (keep last 10)
echo -e "${YELLOW}Cleaning up old backups...${NC}"
cd "${BACKUP_DIR}"
ls -t n8n_backup_*.tar.gz 2>/dev/null | tail -n +11 | xargs -r rm -f
echo "  ✓ Old backups cleaned (keeping last 10)"

echo -e "${GREEN}Backup process complete!${NC}"