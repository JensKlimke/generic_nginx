# Generic Nginx Docker Image

A customizable Nginx Docker image that serves static content from a Git repository. This image automatically clones a specified Git repository at startup and serves its HTML content through Nginx.

## Features

- Automatically clones a Git repository at container startup
- Supports private repositories with authentication included in the URL
- Configurable branch selection
- Serves static content through Nginx
- Webhook endpoint for triggering content updates without container restart
- Lightweight Alpine-based image

## Usage

### Basic Usage

```bash
docker run -p 80:8080 -e REPO_URL=https://github.com/username/repo.git username/generic-nginx
```

### Environment Variables

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `REPO_URL` | Complete URL of the Git repository to clone (including protocol, domain, and authentication if needed) | Yes | - |
| `REPO_BRANCH` | Branch of the repository to clone | No | `main` |
| `HTML_DIR` | Directory where Nginx serves content from | No | `/usr/share/nginx/html` |
| `WEBHOOK_TOKEN` | Authentication token for the webhook endpoint | No | Random generated token |
| `WEBHOOK_PATH` | Path for the webhook endpoint | No | `/webhook` |

### Repository Structure

The repository being cloned must contain an `html` directory with the static content to be served.

Example repository structure:
```
repository/
├── html/
│   ├── index.html
│   ├── css/
│   ├── js/
│   └── ...
└── ...
```

### Using the Webhook

The image provides a webhook endpoint that allows you to trigger a content update without restarting the container. This is useful when you want to automatically update the website content when changes are pushed to the repository.

To trigger an update, send a POST request to the webhook endpoint with the authentication token:

```bash
curl -X POST -H "Authorization: Bearer YOUR_WEBHOOK_TOKEN" http://your-server-address/webhook
```

Replace `YOUR_WEBHOOK_TOKEN` with the token you specified in the `WEBHOOK_TOKEN` environment variable. If you didn't specify a token, a random one is generated and printed in the container logs at startup.

You can also customize the webhook path using the `WEBHOOK_PATH` environment variable:

```bash
docker run -p 80:80 -e REPO_URL=https://github.com/username/repo.git -e WEBHOOK_PATH=/custom-webhook -e WEBHOOK_TOKEN=your-secret-token username/generic-nginx
```

Then use the custom path in your webhook requests:

```bash
curl -X POST -H "Authorization: Bearer your-secret-token" http://your-server-address/custom-webhook
```

This is particularly useful for setting up automated deployments with CI/CD systems or Git webhooks.

## Docker Hub

This image is available on Docker Hub:

```bash
docker pull username/generic-nginx
```

## Building Locally

```bash
git clone https://github.com/username/generic-nginx.git
cd generic-nginx
docker build -t generic-nginx .
```

## GitHub Actions Workflow

This repository includes a GitHub Actions workflow with two main jobs:

1. **Test Job**: Runs on every push to any branch. This job builds the Docker image but does not push it to Docker Hub, serving as a validation step to ensure the image builds correctly.

2. **Build and Push Job**: Runs when a tagged release is created or when manually triggered. This job builds and publishes the Docker image to Docker Hub. For releases, the image is published with the corresponding version tag (e.g., for a release tagged as "v1.2.3", the image will be published with tags "1.2.3", "1.2", and "1").

### Setting Up GitHub Secrets

To enable the automatic publishing workflow, you need to set up the following secrets in your GitHub repository:

1. `DOCKERHUB_USERNAME`: Your Docker Hub username
2. `DOCKERHUB_TOKEN`: Your Docker Hub access token (not your password)

To create a Docker Hub access token:
1. Log in to [Docker Hub](https://hub.docker.com/)
2. Go to Account Settings > Security
3. Click "New Access Token" and follow the prompts

### Creating a Release

To publish a new version of the Docker image:
1. Go to the "Releases" section of your GitHub repository
2. Click "Create a new release"
3. Enter a tag version (e.g., "v1.2.3") and release title
4. Click "Publish release"

The workflow will automatically build and publish the Docker image with the corresponding version tag.

### Manual Workflow Trigger

You can also manually trigger the workflow from the GitHub Actions tab. When triggering manually, you can specify additional tags for the Docker image.

## License

This project is licensed under the terms of the license included in the repository.
