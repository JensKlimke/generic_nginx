#!/bin/sh
set -e

# Function to log messages
log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Function to update the repository and refresh content
update_repo() {
  log "Pulling latest changes from repository"
  cd /repo && git pull

  # Check if the HTML folder exists in the repository
  if [ ! -d "/repo/html" ]; then
    log "ERROR: HTML folder not found in the repository"
    return 1
  fi

  # Clear the HTML directory and copy the updated content
  log "Updating HTML content in $HTML_DIR"
  rm -rf "$HTML_DIR"/*
  cp -r /repo/html/* "$HTML_DIR"/
  log "Content updated successfully"
  return 0
}

# Check if required environment variables are set
if [ -z "$REPO_URL" ]; then
  log "ERROR: REPO_URL environment variable is not set"
  exit 1
fi

# Set default value for webhook token if not provided
if [ -z "$WEBHOOK_TOKEN" ]; then
  # Generate a random token if not provided
  WEBHOOK_TOKEN=$(tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 32)
  log "Generated random webhook token: $WEBHOOK_TOKEN"
fi

# Clear the HTML directory
rm -rf "$HTML_DIR"/*

# Clone the repository
log "Cloning repository from $REPO_URL (branch: $REPO_BRANCH)"
git clone --branch "$REPO_BRANCH" --single-branch "$REPO_URL" /repo

# Check if the repository was cloned successfully
if [ ! -d "/repo" ]; then
  log "ERROR: Failed to clone repository"
  exit 1
fi

# Check if the HTML folder exists in the repository
if [ ! -d "/repo/html" ]; then
  log "ERROR: HTML folder not found in the repository"
  exit 1
fi

# Copy the HTML folder to the Nginx serving directory
log "Copying HTML content to $HTML_DIR"
cp -r /repo/html/* "$HTML_DIR"/

# Process template files with environment variables
envsubst '${WEBHOOK_TOKEN} ${HTML_DIR} ${WEBHOOK_PATH}' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf
envsubst '${WEBHOOK_TOKEN}' < /usr/share/nginx/cgi-bin/webhook.sh.template > /usr/share/nginx/cgi-bin/webhook.sh
envsubst '${HTML_DIR}' < /usr/share/nginx/cgi-bin/update.sh.template > /usr/share/nginx/cgi-bin/update.sh

# Make scripts executable
chmod +x /usr/share/nginx/cgi-bin/webhook.sh /usr/share/nginx/cgi-bin/update.sh

# Start fcgiwrap
spawn-fcgi -s /var/run/fcgiwrap.socket -u nginx -g nginx /usr/bin/fcgiwrap

log "Webhook endpoint configured at http://localhost$WEBHOOK_PATH"
log "Use Authorization header with 'Bearer $WEBHOOK_TOKEN' to authenticate"

# Start Nginx
log "Starting Nginx"
exec "$@"
