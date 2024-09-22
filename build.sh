#!/bin/bash

# Exit immediately if any command exits with a non-zero status
set -e

# Load environment variables from config.yaml
while IFS=: read -r key value; do
  key=$(echo "$key" | xargs)         # Trim whitespace
  value=$(echo "$value" | xargs | tr -d '"')  # Trim whitespace and remove quotes
  export "$key=$value"
done < <(awk '!/^#/ && NF {print}' config.yaml)  # Ignore comments and empty lines

# Configurable variables (can be overridden via environment variables or arguments)
DOCKER_REGISTRY=${DOCKER_REGISTRY}
FRONTEND_IMAGE_NAME=${FRONTEND_IMAGE_NAME}
BACKEND_IMAGE_NAME=${BACKEND_IMAGE_NAME}
IMAGE_TAG=${IMAGE_TAG}
NODE_ENV=${NODE_ENV}
FRONTEND_DOCKERFILE=${FRONTEND_DOCKERFILE}
BACKEND_DOCKERFILE=${BACKEND_DOCKERFILE}
DOCKER_PASSWORD=${DOCKER_PASSWORD}

docker login --username $DOCKER_REGISTRY -p $DOCKER_PASSWORD

# Build the frontend Docker image
echo "Building frontend Docker image..."
docker build --build-arg NODE_ENV=${NODE_ENV} -t ${DOCKER_REGISTRY}/${FRONTEND_IMAGE_NAME}:${IMAGE_TAG} -f ${FRONTEND_DOCKERFILE} .

# Build the backend Docker image
echo "Building backend Docker image..."
docker build --build-arg NODE_ENV=${NODE_ENV} -t ${DOCKER_REGISTRY}/${BACKEND_IMAGE_NAME}:${IMAGE_TAG} -f ${BACKEND_DOCKERFILE} .

# Push the frontend Docker image
echo "Pushing frontend Docker image to ${DOCKER_REGISTRY}..."
docker push ${DOCKER_REGISTRY}/${FRONTEND_IMAGE_NAME}:${IMAGE_TAG}

# Push the backend Docker image
echo "Pushing backend Docker image to ${DOCKER_REGISTRY}..."
docker push ${DOCKER_REGISTRY}/${BACKEND_IMAGE_NAME}:${IMAGE_TAG}

echo "Docker images built and pushed successfully."