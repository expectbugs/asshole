#!/bin/bash
# n8n Restore Script for Gentoo Linux
# Restores n8n configuration and database from backup

set -e

# Check if backup name was provided
if [ -z "$1" ]; then
    echo "Usage: $0 <backup_name>"
    echo "Example: $0 n8n_backup_20250829_120000"
    echo ""
    echo "Available backups:"
    ls -1 /home/user/n8n/backups/*.tar.gz 2>/dev/null | xargs -n1 basename | sed 's/.tar.gz$//'
    exit 1
fi

# Configuration
BACKUP_NAME="$1"
BACKUP_DIR="/home/user/n8n/backups"
BACKUP_FILE="${BACKUP_DIR}/${BACKUP_NAME}.tar.gz"
TEMP_DIR="/tmp/n8n_restore_$$"
N8N_DATA_DIR="/var/lib/n8n"
DB_NAME="n8n_db"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if backup file exists
if [ ! -f "${BACKUP_FILE}" ]; then
    echo -e "${RED}Error: Backup file not found: ${BACKUP_FILE}${NC}"
    exit 1
fi

echo -e "${GREEN}Starting n8n restore from backup: ${BACKUP_NAME}${NC}"

# Ask for confirmation
echo -e "${YELLOW}WARNING: This will overwrite the current n8n configuration and database!${NC}"
read -p "Are you sure you want to continue? (yes/no): " confirmation
if [ "${confirmation}" != "yes" ]; then
    echo "Restore cancelled."
    exit 0
fi

# 1. Stop n8n service
echo -e "${YELLOW}Stopping n8n service...${NC}"
sudo rc-service n8n stop || true
echo "  ✓ n8n service stopped"

# 2. Extract backup
echo -e "${YELLOW}Extracting backup...${NC}"
mkdir -p "${TEMP_DIR}"
tar -xzf "${BACKUP_FILE}" -C "${TEMP_DIR}"
EXTRACTED_DIR="${TEMP_DIR}/${BACKUP_NAME}"
echo "  ✓ Backup extracted to temporary directory"

# 3. Display backup information
if [ -f "${EXTRACTED_DIR}/backup_info.txt" ]; then
    echo -e "${YELLOW}Backup Information:${NC}"
    cat "${EXTRACTED_DIR}/backup_info.txt"
    echo ""
fi

# 4. Restore n8n configuration files
echo -e "${YELLOW}Restoring n8n configuration...${NC}"
if [ -f "${EXTRACTED_DIR}/.env" ]; then
    sudo cp "${EXTRACTED_DIR}/.env" "${N8N_DATA_DIR}/.env"
    sudo chown n8n:n8n "${N8N_DATA_DIR}/.env"
    sudo chmod 600 "${N8N_DATA_DIR}/.env"
    echo "  ✓ .env file restored"
fi

if [ -d "${EXTRACTED_DIR}/.n8n" ]; then
    sudo rm -rf "${N8N_DATA_DIR}/.n8n.backup"
    sudo mv "${N8N_DATA_DIR}/.n8n" "${N8N_DATA_DIR}/.n8n.backup" 2>/dev/null || true
    sudo cp -r "${EXTRACTED_DIR}/.n8n" "${N8N_DATA_DIR}/"
    sudo chown -R n8n:n8n "${N8N_DATA_DIR}/.n8n"
    echo "  ✓ .n8n directory restored"
fi

# 5. Restore OpenRC service files
echo -e "${YELLOW}Restoring service configuration...${NC}"
if [ -f "${EXTRACTED_DIR}/n8n.init" ]; then
    sudo cp "${EXTRACTED_DIR}/n8n.init" "/etc/init.d/n8n"
    sudo chmod +x "/etc/init.d/n8n"
    echo "  ✓ OpenRC init script restored"
fi

if [ -f "${EXTRACTED_DIR}/n8n.conf" ]; then
    sudo cp "${EXTRACTED_DIR}/n8n.conf" "/etc/conf.d/n8n"
    echo "  ✓ Service configuration restored"
fi

# 6. Restore PostgreSQL database
echo -e "${YELLOW}Restoring PostgreSQL database...${NC}"
if [ -f "${EXTRACTED_DIR}/n8n_database.sql" ]; then
    # Create backup of current database
    sudo -u postgres pg_dump ${DB_NAME} > "${BACKUP_DIR}/pre_restore_backup_$(date +%Y%m%d_%H%M%S).sql" 2>/dev/null || true
    
    # Drop and recreate database
    sudo -u postgres psql -c "DROP DATABASE IF EXISTS ${DB_NAME};"
    sudo -u postgres psql -c "CREATE DATABASE ${DB_NAME} OWNER n8n;"
    
    # Restore database
    sudo -u postgres psql ${DB_NAME} < "${EXTRACTED_DIR}/n8n_database.sql"
    echo "  ✓ Database restored"
fi

# 7. Restore MCP configuration
echo -e "${YELLOW}Restoring MCP configuration...${NC}"
if [ -d "${EXTRACTED_DIR}/.claude" ]; then
    rm -rf "/home/user/n8n/.claude.backup"
    mv "/home/user/n8n/.claude" "/home/user/n8n/.claude.backup" 2>/dev/null || true
    cp -r "${EXTRACTED_DIR}/.claude" "/home/user/n8n/"
    echo "  ✓ MCP configuration restored"
fi

# 8. Clean up temporary files
echo -e "${YELLOW}Cleaning up...${NC}"
rm -rf "${TEMP_DIR}"
echo "  ✓ Temporary files removed"

# 9. Start n8n service
echo -e "${YELLOW}Starting n8n service...${NC}"
sudo rc-service n8n start
echo "  ✓ n8n service started"

# 10. Verify service is running
sleep 3
if sudo rc-service n8n status >/dev/null 2>&1; then
    echo -e "${GREEN}✓ n8n service is running${NC}"
else
    echo -e "${YELLOW}⚠ Please check n8n service status manually${NC}"
fi

echo -e "${GREEN}Restore completed successfully!${NC}"
echo "n8n should now be accessible at: http://localhost:5678"
echo ""
echo "Note: Previous configuration was backed up with .backup extension"