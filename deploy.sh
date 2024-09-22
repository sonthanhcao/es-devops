#!/bin/bash

export DATE=$(date +%s)

if [[ -z $IMAGE_TAG ]]; then
  echo "IMAGE_TAG is empty"
  exit 1
fi

if [[ "$CI_COMMIT_TAG" != "" ]]; then
      export IMAGE_TAG=$CI_COMMIT_TAG
fi
# Replace variables in the YAML file
sed -e "s/\$SERVICE_NAME/$SERVICE_NAME/g" -e "s/\$SERVICE_NAME/$DOCKER_REPO/g" -e "s/\$IMAGE_TAG/$IMAGE_TAG/g" ./deployment/main.yaml > ./deployment/k8s-main.yaml
kubectl apply -f ./deployment/k8s-main.yaml -n $NAMESPACE
if [[ $? != 0 ]]; then exit 1; fi

kubectl rollout status deployments/$SERVICE_NAME -n $NAMESPACE

if [[ $? != 0 ]]; then
    kubectl logs -n $NAMESPACE $(kubectl get pods -n $NAMESPACE --sort-by=.metadata.creationTimestamp | grep "$SERVICE_NAME" | awk '{print $1}' | tac | head -1 ) --tail=20 && exit 1;
fi
