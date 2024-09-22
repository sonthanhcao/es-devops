#!/bin/bash

# Exit immediately if any command exits with a non-zero status
set -e

# Load environment variables from config.yaml
while IFS=: read -r key value; do
  key=$(echo "$key" | xargs)         # Trim whitespace
  value=$(echo "$value" | xargs | tr -d '"')  # Trim whitespace and remove quotes
  export "$key=$value"
done < <(awk '!/^#/ && NF {print}' config.yaml)  # Ignore comments and empty lines

docker login ghcr.io -u $GITHUB_USER -p $GITHUB_TOKEN

# Build the frontend Docker image
echo "Building frontend Docker image..."
docker build --build-arg NODE_ENV=${NODE_ENV} -t ${DOCKER_REPO}/${FRONTEND_IMAGE_NAME}:${IMAGE_TAG} -f ${FRONTEND_DOCKERFILE} .

# Build the backend Docker image
echo "Building backend Docker image..."
docker build --build-arg NODE_ENV=${NODE_ENV} -t ${DOCKER_REPO}/${BACKEND_IMAGE_NAME}:${IMAGE_TAG} -f ${BACKEND_DOCKERFILE} .

# Push the frontend Docker image
echo "Pushing frontend Docker image to ${DOCKER_REPO}..."
docker push ${DOCKER_REPO}/${FRONTEND_IMAGE_NAME}:${IMAGE_TAG}

# Push the backend Docker image
echo "Pushing backend Docker image to ${DOCKER_REPO}..."
docker push ${DOCKER_REPO}/${BACKEND_IMAGE_NAME}:${IMAGE_TAG}

echo "Docker images built and pushed successfully."