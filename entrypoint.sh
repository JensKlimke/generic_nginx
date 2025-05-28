#!/bin/sh
set -e

# Function to log messages
log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Check if required environment variables are set
if [ -z "$REPO" ]; then
  log "ERROR: REPO environment variable is not set"
  exit 1
fi

# Set default values for optional variables
REPO_PROTOCOL=${REPO_PROTOCOL:-https}
REPO_DOMAIN=${REPO_DOMAIN:-github.com}

# Clear the HTML directory
rm -rf "$HTML_DIR"/*

# Construct the repository URL
if [ -n "$REPO_USERNAME" ] && [ -n "$REPO_PASSWORD" ]; then
  # Construct URL with authentication
  REPO_URL="${REPO_PROTOCOL}://${REPO_USERNAME}:${REPO_PASSWORD}@${REPO_DOMAIN}/${REPO}.git"
else
  # Construct URL without authentication
  REPO_URL="${REPO_PROTOCOL}://${REPO_DOMAIN}/${REPO}.git"
fi

# Clone the repository
log "Cloning repository from ${REPO_PROTOCOL}://${REPO_DOMAIN}/${REPO} (branch: $REPO_BRANCH)"
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
