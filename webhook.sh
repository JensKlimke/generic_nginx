#!/bin/sh
echo "Content-type: text/plain"
echo ""

# Get the authorization header
AUTH_HEADER=$(echo "$HTTP_AUTHORIZATION")

# Extract the token from the header
if [ -z "$AUTH_HEADER" ] || [ "${AUTH_HEADER#Bearer }" = "$AUTH_HEADER" ]; then
  echo "Error: Missing or invalid authorization header"
  exit 1
fi

TOKEN="${AUTH_HEADER#Bearer }"

# Check if the token matches
if [ "$TOKEN" != "${WEBHOOK_TOKEN}" ]; then
  echo "Error: Invalid token"
  exit 1
fi

# Run the update script
/usr/share/nginx/cgi-bin/update.sh