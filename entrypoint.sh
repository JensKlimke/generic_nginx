#!/bin/sh
set -e

# Function to log messages
log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Check if required environment variables are set
if [ -z "$REPO_URL" ]; then
  log "ERROR: REPO_URL environment variable is not set"
  exit 1
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

# Start Nginx
log "Starting Nginx"
exec "$@"
