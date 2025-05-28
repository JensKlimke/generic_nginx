FROM nginx:alpine

# Install git and other necessary tools
RUN apk add --no-cache git curl fcgiwrap spawn-fcgi

# Set environment variables with default values
ENV REPO_URL=""
ENV REPO_BRANCH="main"
ENV HTML_DIR="/usr/share/nginx/html"
ENV WEBHOOK_TOKEN=""
ENV WEBHOOK_PATH="/webhook"

# Create a directory for the repository
RUN mkdir -p /repo

# Create directory for CGI scripts
RUN mkdir -p /usr/share/nginx/cgi-bin

# Copy the scripts and templates
COPY entrypoint.sh /entrypoint.sh
COPY webhook.sh /usr/share/nginx/cgi-bin/webhook.sh.template
COPY update.sh /usr/share/nginx/cgi-bin/update.sh.template
COPY nginx.conf.template /etc/nginx/conf.d/default.conf.template

# Make scripts executable
RUN chmod +x /entrypoint.sh

# Set the entrypoint script
ENTRYPOINT ["/entrypoint.sh"]

# Expose ports
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
