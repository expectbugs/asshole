# Changelog

All notable changes to Project Asshole will be documented in this file.

## [1.0.0] - 2025-08-29

### Phase 1 Complete - Core Foundation

#### Added
- Native n8n installation on Gentoo Linux (no Docker)
- PostgreSQL 17 backend configuration
- OpenRC service management (`/etc/init.d/n8n`)
- n8n MCP server for Claude Code integration
- Automated backup/restore scripts
- Test workflow in database
- Owner account setup (amarzello@gmail.com)
- Project documentation structure

#### Configuration
- n8n running on port 5678 (localhost only)
- PostgreSQL database: `n8n_db` with user `n8n`
- Data directory: `/var/lib/n8n`
- Log directory: `/var/log/n8n`
- Service auto-starts on boot

#### Scripts Created
- `backup-n8n.sh` - Automated timestamped backups
- `restore-n8n.sh` - Restore from backup archives
- `verify-n8n-setup.sh` - System verification tool
- Various test and setup utilities

#### Security
- Local access only (no external exposure)
- Restricted file permissions on .env
- PostgreSQL local connections only
- No basic auth (relies on network isolation)

#### Known Issues
- n8n deprecation warning: Should set `N8N_RUNNERS_ENABLED=true`
- MCP integration requires Claude Code client configuration
- API access requires authentication setup

#### Infrastructure
- Gentoo Linux 6.12.34
- PostgreSQL 17
- Node.js (system install)
- n8n version 1.108.2
- n8n-mcp version 2.10.6

### Repository Setup
- Initial git repository created
- Project organized with scripts/ and docs/ directories
- Sensitive files removed
- .gitignore configured

---

## Upcoming

### [Phase 2] - AI Memory System
- Qdrant vector database setup
- Persistent conversation memory
- LangChain integration
- Cross-conversation learning

### [Phase 3] - Communication Hub
- Twilio integration
- Signal CLI setup
- KDE Connect configuration
- Autonomous call handling

### [Phase 4] - Life Integration
- Tesla API integration
- TeslaMate setup
- Firefly III connection
- Price monitoring automation