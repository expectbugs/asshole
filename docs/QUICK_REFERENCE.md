# n8n Quick Reference

## Essential Commands

### Service Management
```bash
# Start n8n
sudo rc-service n8n start

# Stop n8n
sudo rc-service n8n stop

# Restart n8n
sudo rc-service n8n restart

# Check status
rc-service n8n status
```

### Access Points
- **Web Interface**: http://localhost:5678
- **Owner Email**: amarzello@gmail.com

### Backup & Restore
```bash
# Create backup
./backup-n8n.sh

# List backups
ls -lh backups/

# Restore from backup
./restore-n8n.sh n8n_backup_YYYYMMDD_HHMMSS
```

### Troubleshooting
```bash
# View logs
sudo tail -f /var/log/n8n/n8n.log

# Check if n8n is running
ps aux | grep n8n

# Test web interface
curl -I http://localhost:5678

# Database status
sudo -u postgres psql -d n8n_db -c "\dt"
```

### File Locations
- **Config**: `/var/lib/n8n/.env`
- **Data**: `/var/lib/n8n/.n8n/`
- **Logs**: `/var/log/n8n/`
- **Service**: `/etc/init.d/n8n`
- **MCP Config**: `/home/user/n8n/.claude/mcp_servers.json`

### Database Access
```bash
# Connect to database
sudo -u postgres psql -d n8n_db

# Count workflows
sudo -u postgres psql -d n8n_db -c "SELECT COUNT(*) FROM workflow_entity;"
```

## MCP Integration

To use with Claude Code:
1. MCP server is installed: `n8n-mcp`
2. Configuration is at `.claude/mcp_servers.json`
3. Server connects to n8n at http://localhost:5678

---
*Keep this reference handy for daily n8n operations*