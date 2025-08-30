# Project Asshole - Personal AI Assistant

A comprehensive, privacy-first personal AI assistant using n8n as the core orchestration platform.

## Overview

This project implements a self-hosted AI assistant system with:
- Natural language workflow automation via n8n
- Perfect memory retention using vector databases
- Autonomous phone and communication management
- Tesla vehicle integration
- Life automation capabilities

## System Architecture

- **Core Platform**: n8n (native install, no Docker)
- **Database**: PostgreSQL 17 for n8n backend + conversation memory
- **Vector DB**: Qdrant for AI memory persistence (Phase 2)
- **LLM**: Local Ollama + Claude API for complex tasks
- **Voice**: Local Whisper STT + conversation memory
- **Mobile**: KDE Connect for Android integration

## Current Status

✅ **Phase 1 Complete**: Core n8n foundation operational
- n8n running natively on Gentoo Linux
- PostgreSQL backend configured
- MCP server installed for Claude Code integration
- Backup/restore scripts functional
- OpenRC service management

## Quick Start

```bash
# Start n8n service
sudo rc-service n8n start

# Access web interface
firefox http://localhost:5678

# Create backup
./scripts/backup-n8n.sh

# Check status
rc-service n8n status
```

## Directory Structure

```
.
├── scripts/          # Utility and management scripts
├── docs/            # Documentation and references
├── backups/         # Automated backup storage
├── .claude/         # MCP configuration
└── CLAUDE.md        # Project specifications
```

## Documentation

- [Quick Reference](docs/QUICK_REFERENCE.md) - Essential commands and paths
- [Verification Summary](docs/VERIFICATION_SUMMARY.md) - Phase 1 completion details
- [Project Specifications](CLAUDE.md) - Full project requirements

## Requirements

- Gentoo Linux
- PostgreSQL 17+
- Node.js LTS
- 32GB RAM recommended
- Local network access only (security by design)

## Security

- All data stays local
- No cloud dependencies for core functions
- PostgreSQL local connections only
- Service accessible on localhost only
- Encrypted credential storage

## Roadmap

- [x] Phase 1: Core n8n Foundation
- [ ] Phase 2: AI Memory System (Qdrant)
- [ ] Phase 3: Communication Hub (Twilio/Signal)
- [ ] Phase 4: Life Integration (Tesla/Finance)

## License

Private project - All rights reserved

---

*For detailed project specifications, see [CLAUDE.md](CLAUDE.md)*