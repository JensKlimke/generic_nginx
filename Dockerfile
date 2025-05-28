FROM nginx:alpine

# Install git and other necessary tools
RUN apk add --no-cache git curl

# Set environment variables with default values
ENV REPO_PROTOCOL="https"
ENV REPO_DOMAIN="github.com"
ENV REPO=""
ENV REPO_USERNAME=""
ENV REPO_PASSWORD=""
ENV REPO_BRANCH="main"
ENV HTML_DIR="/usr/share/nginx/html"

# Create a directory for the repository
RUN mkdir -p /repo

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set the entrypoint script
ENTRYPOINT ["/entrypoint.sh"]

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
