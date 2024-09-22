#!/bin/bash

export DATE=$(date +%s)

if [[ -z $IMAGE_TAG ]]; then
  echo "IMAGE_TAG is empty"
  exit 1
fi

if [[ "$CI_COMMIT_TAG" != "" ]]; then
  export IMAGE_TAG=$CI_COMMIT_TAG
fi

# Create Docker Pull Secret
kubectl create secret docker-registry docker-pull-secret \
  --docker-server=$DOCKER_REPO \
  --docker-username=$GITHUB_USER \
  --docker-password=$GITHUB_TOKEN \
  --docker-email=sc@example.com \
  --namespace $NAMESPACE \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic mongo-uri-secret \
  --from-literal=MONGODB_URI=$MONGODB_URI \
  --namespace $NAMESPACE \
  --dry-run=client -o yaml | kubectl apply -f -

# Escape special characters in variables
ESCAPED_DOCKER_REPO=$(printf '%s\n' "$DOCKER_REPO" | sed -e 's/[\/&]/\\&/g')

# Replace variables in the YAML file
sed -e "s/\$SERVICE_NAME/$SERVICE_NAME/g" -e "s/\$HOSTNAME/$HOSTNAME/g"  -e "s/\$IMAGE_TAG/$IMAGE_TAG/g" -e "s/\$DOCKER_REPO/$ESCAPED_DOCKER_REPO/g" ./deployment/main.yaml > ./deployment/k8s-main.yaml
kubectl apply -f ./deployment/k8s-main.yaml -n $NAMESPACE
if [[ $? != 0 ]]; then exit 1; fi

kubectl rollout status deployments/$SERVICE_NAME -n $NAMESPACE

if [[ $? != 0 ]]; then
  kubectl logs -n $NAMESPACE $(kubectl get pods -n $NAMESPACE --sort-by=.metadata.creationTimestamp | grep "$SERVICE_NAME" | awk '{print $1}' | tac | head -1 ) --tail=20 && exit 1
fi