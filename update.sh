#!/bin/sh
cd /repo && git pull

# Check if the HTML folder exists in the repository
if [ ! -d "/repo/html" ]; then
  echo "ERROR: HTML folder not found in the repository"
  exit 1
fi

# Clear the HTML directory and copy the updated content
rm -rf "${HTML_DIR}"/*
cp -r /repo/html/* "${HTML_DIR}"/
echo "Content updated successfully"