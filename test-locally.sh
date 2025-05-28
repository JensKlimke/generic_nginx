#!/bin/bash
set -e

echo "=== Generic Nginx Local Testing Script ==="
echo "This script will help you test the generic-nginx Docker image locally."
echo

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed or not in PATH"
    exit 1
fi

# Create a temporary directory for the test repository
echo "Creating test repository..."
TEST_DIR=$(mktemp -d)
mkdir -p "$TEST_DIR/html"

# Initialize Git repository
cd "$TEST_DIR"
git init
echo "<html><body><h1>Hello, World!</h1><p>This is a test page from generic-nginx.</p></body></html>" > html/index.html
git add .
git config --local user.email "test@example.com"
git config --local user.name "Test User"
git commit -m "Initial commit"
TEST_REPO_PATH=$(pwd)
cd - > /dev/null

echo "Test repository created at: $TEST_REPO_PATH"

# Build the Docker image
echo "Building Docker image..."
docker build -t generic-nginx-test .

# Run the container
echo "Running container..."
docker run -d --name nginx-test -p 8080:80 \
  -e REPO_URL="file://$TEST_REPO_PATH" \
  -e WEBHOOK_TOKEN="test-token" \
  generic-nginx-test

echo "Waiting for container to start..."
sleep 3

# Check if the container is running
if [ "$(docker ps -q -f name=nginx-test)" ]; then
    echo "Container is running!"
else
    echo "Error: Container failed to start"
    docker logs nginx-test
    echo "Cleaning up..."
    docker rm -f nginx-test 2>/dev/null || true
    rm -rf "$TEST_DIR"
    exit 1
fi

# Test basic functionality
echo "Testing basic functionality..."
echo "Checking if the website is accessible..."
if curl -s http://localhost:8080 | grep -q "Hello, World!"; then
    echo "Success! Website is accessible."
else
    echo "Error: Website is not accessible or doesn't contain expected content"
    docker logs nginx-test
    echo "Cleaning up..."
    docker rm -f nginx-test
    rm -rf "$TEST_DIR"
    exit 1
fi

# Test webhook functionality
echo "Testing webhook functionality..."
cd "$TEST_DIR"
echo "<html><body><h1>Hello, Updated World!</h1><p>This page has been updated.</p></body></html>" > html/index.html
git add .
git commit -m "Update content"
cd - > /dev/null

echo "Triggering webhook..."
curl -X POST -H "Authorization: Bearer test-token" http://localhost:8080/webhook

echo "Waiting for update to apply..."
sleep 2

echo "Checking if the website has been updated..."
if curl -s http://localhost:8080 | grep -q "Updated World"; then
    echo "Success! Website has been updated via webhook."
else
    echo "Error: Website was not updated or doesn't contain expected content"
    docker logs nginx-test
    echo "Cleaning up..."
    docker rm -f nginx-test
    rm -rf "$TEST_DIR"
    exit 1
fi

# Clean up
echo "All tests passed successfully!"
echo "Cleaning up..."
docker stop nginx-test
docker rm nginx-test
rm -rf "$TEST_DIR"

echo "Testing completed successfully!"
echo "You can now build and use the generic-nginx image with confidence."