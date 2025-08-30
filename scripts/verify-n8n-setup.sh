#!/bin/bash
# n8n Setup Verification Script
# Created: $(date +%Y-%m-%d)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== n8n Setup Verification ===${NC}"
echo ""

ERRORS=0
WARNINGS=0

# Function to check status
check_ok() {
    echo -e "  ${GREEN}✓${NC} $1"
}

check_fail() {
    echo -e "  ${RED}✗${NC} $1"
    ((ERRORS++))
}

check_warn() {
    echo -e "  ${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

# 1. Check n8n installation
echo -e "${BLUE}1. n8n Installation:${NC}"
if command -v n8n &> /dev/null; then
    VERSION=$(n8n --version)
    check_ok "n8n installed (version: ${VERSION})"
else
    check_fail "n8n not found in PATH"
fi

# 2. Check n8n service
echo -e "\n${BLUE}2. n8n Service:${NC}"
if sudo rc-service n8n status 2>/dev/null | grep -q "running"; then
    check_ok "n8n service is running"
else
    check_fail "n8n service is not running"
fi

# 3. Check n8n user
echo -e "\n${BLUE}3. System User:${NC}"
if id n8n &> /dev/null; then
    check_ok "n8n user exists"
    if [ -d "/var/lib/n8n" ]; then
        check_ok "n8n home directory exists"
    else
        check_fail "n8n home directory missing"
    fi
else
    check_fail "n8n user not found"
fi

# 4. Check PostgreSQL
echo -e "\n${BLUE}4. PostgreSQL Database:${NC}"
if sudo -u postgres psql -lqt 2>/dev/null | cut -d \| -f 1 | grep -qw n8n_db; then
    check_ok "n8n_db database exists"
    
    # Check connection
    if sudo -u postgres psql -d n8n_db -c "SELECT 1;" &> /dev/null; then
        check_ok "Database connection successful"
    else
        check_fail "Cannot connect to database"
    fi
else
    check_fail "n8n_db database not found"
fi

# 5. Check file permissions
echo -e "\n${BLUE}5. File Permissions:${NC}"
if [ -f "/var/lib/n8n/.env" ]; then
    PERM=$(stat -c %a /var/lib/n8n/.env)
    if [ "$PERM" = "600" ]; then
        check_ok ".env file permissions correct (600)"
    else
        check_warn ".env file permissions: ${PERM} (should be 600)"
    fi
else
    check_fail ".env file not found"
fi

# 6. Check logs
echo -e "\n${BLUE}6. Logging:${NC}"
if [ -d "/var/log/n8n" ]; then
    check_ok "Log directory exists"
    if [ -f "/etc/logrotate.d/n8n" ]; then
        check_ok "Logrotate configured"
    else
        check_warn "Logrotate not configured"
    fi
else
    check_fail "Log directory not found"
fi

# 7. Check MCP installation
echo -e "\n${BLUE}7. MCP Integration:${NC}"
if [ -d "/usr/lib64/node_modules/n8n-mcp" ]; then
    check_ok "n8n-mcp installed"
else
    check_warn "n8n-mcp not found (optional)"
fi

# 8. Check n8n web interface
echo -e "\n${BLUE}8. Web Interface:${NC}"
if curl -s -o /dev/null -w "%{http_code}" http://localhost:5678 | grep -q "200\|302"; then
    check_ok "n8n web interface accessible at http://localhost:5678"
else
    check_warn "n8n web interface not responding (may need initialization)"
fi

# 9. Check backup scripts
echo -e "\n${BLUE}9. Backup Scripts:${NC}"
if [ -x "/home/user/n8n/backup-n8n.sh" ]; then
    check_ok "Backup script exists and is executable"
else
    check_warn "Backup script not found or not executable"
fi

if [ -x "/home/user/n8n/restore-n8n.sh" ]; then
    check_ok "Restore script exists and is executable"
else
    check_warn "Restore script not found or not executable"
fi

# 10. Check network security
echo -e "\n${BLUE}10. Security:${NC}"
# Check PostgreSQL listening
PG_LISTEN=$(sudo -u postgres psql -t -c "SHOW listen_addresses;" 2>/dev/null | tr -d ' ')
if [ "$PG_LISTEN" = "localhost" ]; then
    check_ok "PostgreSQL listening only on localhost"
else
    check_warn "PostgreSQL listening on: ${PG_LISTEN}"
fi

# Check n8n configuration
if [ -f "/var/lib/n8n/.env" ]; then
    if grep -q "N8N_HOST=localhost" /var/lib/n8n/.env 2>/dev/null; then
        check_ok "n8n configured for localhost only"
    else
        check_warn "Check n8n host configuration"
    fi
fi

# Summary
echo -e "\n${BLUE}=== Summary ===${NC}"
if [ $ERRORS -eq 0 ]; then
    if [ $WARNINGS -eq 0 ]; then
        echo -e "${GREEN}All checks passed successfully!${NC}"
    else
        echo -e "${GREEN}Setup complete with ${WARNINGS} warning(s).${NC}"
    fi
    echo -e "\n${BLUE}Next steps:${NC}"
    echo "1. Access n8n at: http://localhost:5678"
    echo "2. Complete initial setup wizard"
    echo "3. Configure MCP integration for Claude Code"
    echo "4. Test workflow creation"
else
    echo -e "${RED}Found ${ERRORS} error(s) and ${WARNINGS} warning(s).${NC}"
    echo -e "${YELLOW}Please review and fix the errors above.${NC}"
fi

exit $ERRORS