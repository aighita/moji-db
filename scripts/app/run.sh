#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$DIR/../.."

# Build the Docker image
echo "Building Docker image for Moji App..."
docker build --no-cache -t moji-app "$PROJECT_ROOT/app"

# Run the container
# We use -p to map the port and --add-host to access the host database
echo "Starting Moji App container..."
echo "You can access the dashboard at http://localhost:8501"
docker run --rm \
    -p 8501:8501 \
    --add-host=host.docker.internal:host-gateway \
    -e DB_HOST=host.docker.internal \
    --name moji-app-container \
    moji-app
