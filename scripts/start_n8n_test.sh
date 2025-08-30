#!/bin/bash
# n8n Test Startup Script
# This script starts n8n for testing purposes

echo "=== Starting n8n Test Instance ==="
echo "Loading environment from /var/lib/n8n/.env"

# Export environment variables
export $(grep -v '^#' /var/lib/n8n/.env | xargs)

# Start n8n as n8n user
echo "Starting n8n on http://localhost:5678"
echo "Username: admin"
echo "Password: n8n_admin_pass_2024"
echo "Press Ctrl+C to stop"
echo ""

sudo -u n8n -H bash -c 'export $(grep -v "^#" /var/lib/n8n/.env | xargs) && /usr/bin/n8n start'
