# Personal AI Assistant Project

## Project Overview
Building a comprehensive, privacy-first personal AI assistant using n8n as the core orchestration platform. Focus on natural language control, perfect memory retention, autonomous phone management, Tesla integration, and life automation.

## System Environment
- **OS**: Gentoo Linux (primary), Android (mobile)
- **Hardware**: [RAM: 32GB] [CPU: Intel Core i7-13700KF] [Storage: 3.6TB] [GPU: NVIDIA RTX 3090]
- **Network**: [Home IP range: 192.168.1.0/24] [VPN: OpenVPN (tun0), Tailscale for remote phone connectivity]
- **Existing Services**: [Current services running: PostgreSQL-17, Qdrant, Ollama, Neo4j, OpenVPN, Tailscale, Redis]

## Architecture Decisions
- **Core Platform**: n8n (native install, no Docker)
- **Database**: PostgreSQL for n8n + conversation memory
- **Vector DB**: Qdrant for AI memory persistence  
- **LLM**: Local Ollama + Claude API for complex tasks
- **Voice**: Local Whisper STT + conversation memory
- **Mobile**: KDE Connect for Android integration

## Implementation Phases

### Phase 1: Core Foundation
- n8n native install with PostgreSQL backend
- n8n MCP integration for Claude Code workflow generation
- Ollama with 7B model (Llama 3.1 or Mistral)
- Basic security configuration
- Test workflow creation

### Phase 2: AI Memory System  
- Qdrant vector database setup
- Persistent conversation memory workflows
- LangChain n8n integration
- Memory retrieval and context management
- Cross-conversation learning

### Phase 3: Communication Hub
- Twilio integration (SMS/Voice/WhatsApp)
- Signal CLI with REST API
- KDE Connect for Android phone
- Autonomous call handling workflows
- Message routing and AI decision making

### Phase 4: Life Integration
- Tesla API via HTTP nodes
- TeslaMate vehicle data logging
- Firefly III financial tracking
- Price monitoring and purchasing automation
- Inventory management workflows

## Key Integrations Required

### External APIs
- **Twilio**: [Account SID: ___] [Auth Token: ___] [Phone Number: ___]
- **Tesla**: [Email: ___] [API Keys to be generated]
- **Banking**: [Institution: ___] [API approach: ___]
- **Claude API**: [Key: ___]

### Local Services
- **PostgreSQL**: n8n backend + memory storage
- **Qdrant**: Vector embeddings on port 6333
- **Signal CLI**: REST API on port 8080
- **KDE Connect**: D-Bus integration
- **TeslaMate**: MQTT publisher for vehicle data

## Security Requirements
- All data stays local except necessary API calls
- Encrypted storage for API keys and credentials
- VPN access only for external connections
- No cloud storage of personal data
- Signal CLI requires spare phone number: [Number: ___]

## Target Capabilities

### Conversation
- Perfect memory of all interactions
- Natural language understanding for all functions
- Voice input with transcription and memory
- Context awareness across sessions and devices

### Phone Management
- Autonomous answering with AI decision making
- Call routing based on context and preferences
- SMS conversation handling
- Appointment scheduling from voice/text

### Tesla Control
- "Start charging when electricity is cheap"
- "Wake up car and set climate to 72°F"  
- "Tell me when car reaches destination"
- Battery optimization and trip planning

### Life Automation
- Grocery list management with price monitoring
- Financial categorization and budgeting advice
- Calendar optimization and meeting scheduling  
- Inventory tracking with low-stock alerts

## Development Approach
1. Use n8n MCP for workflow generation via natural language
2. Test each component before adding complexity
3. Backup configurations before changes
4. Create verification scripts for each phase
5. Iterate and refine based on actual usage
6. Scripts should be split intelligently when they exceed 400-600 lines of code

## Performance Targets
- Sub-second response for simple queries
- Memory retrieval under 2 seconds
- Voice transcription under 3 seconds
- Tesla commands execute within 5 seconds
- System should handle 24/7 operation

## Notes
- Prefer Gentoo native packages where possible
- Use OpenRC services for daemon management
- Keep detailed logs for troubleshooting
- Document all API rate limits and quotas
- Plan for gradual feature rollout and testing
