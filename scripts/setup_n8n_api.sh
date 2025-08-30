#!/bin/bash

echo "Setting up n8n API access..."

# First, let's use curl to login
echo "Logging in to n8n..."
COOKIE_JAR="/tmp/n8n_cookies.txt"

# Login and save cookies
curl -c "$COOKIE_JAR" -X POST http://localhost:5678/rest/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@localhost","password":"TempPassword123!"}' \
  -s -o /tmp/login_response.json

# Check if login was successful
if grep -q "success" /tmp/login_response.json 2>/dev/null || [ -s "$COOKIE_JAR" ]; then
    echo "Login successful!"
    
    # Try to get current API keys
    echo "Checking for existing API keys..."
    curl -b "$COOKIE_JAR" -X GET http://localhost:5678/rest/api-keys \
      -H "Content-Type: application/json" \
      -s -o /tmp/api_keys.json
    
    # Try to create a new API key
    echo "Creating new API key..."
    API_RESPONSE=$(curl -b "$COOKIE_JAR" -X POST http://localhost:5678/rest/api-keys \
      -H "Content-Type: application/json" \
      -d '{"label":"MCP Integration"}' \
      -s)
    
    echo "API Response:"
    echo "$API_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$API_RESPONSE"
    
    # Extract API key if present
    API_KEY=$(echo "$API_RESPONSE" | grep -o '"apiKey":"[^"]*' | cut -d'"' -f4)
    
    if [ -n "$API_KEY" ]; then
        echo ""
        echo "========================================="
        echo "API KEY CREATED SUCCESSFULLY!"
        echo "API Key: $API_KEY"
        echo "========================================="
        echo ""
        echo "IMPORTANT: Save this key - it won't be shown again!"
        echo ""
        
        # Save to a file
        echo "$API_KEY" > /home/user/n8n/n8n_api_key.txt
        echo "API key saved to: /home/user/n8n/n8n_api_key.txt"
    else
        echo "Could not extract API key. Manual setup may be required."
        echo "Access n8n at: http://localhost:5678"
        echo "Login with: admin@localhost / TempPassword123!"
    fi
else
    echo "Login failed. Please check credentials."
fi

# Cleanup
rm -f "$COOKIE_JAR" /tmp/login_response.json /tmp/api_keys.json