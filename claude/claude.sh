#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ ! -s "${SCRIPT_DIR}/.env" ]; then
	echo "no .env" && exit 1
fi
source "${SCRIPT_DIR}/.env" 
# https://docs.claude.com/en/api/versioning
while [ true ]; do
read -ep "Enter: " user_input
    return_message=$(curl -s https://api.anthropic.com/v1/messages \
      -H "Content-Type: application/json" \
      -H "x-api-key: $ANTHROPIC_API_KEY" \
      -H "anthropic-version: 2023-06-01" \
      -d "{
        \"model\": \"claude-sonnet-4-5-20250929\",
        \"max_tokens\": 1000,
        \"messages\": [
          {
            \"role\": \"user\", 
            \"content\": \"$user_input\"
          }
        ]
      }")
    echo "$return_message" | jq -r '.content[0].text'
    echo -en "\n\n"
done
