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
sed -e "s/\$SERVICE_NAME/$SERVICE_NAME/g" -e "s/\$TAG/$TAG/g" ./deployment/main.yaml > ./deployment/k8s-main.yaml

if [[ $? != 0 ]]; then exit 1; fi

kubectl rollout status deployments/$SERVICE_NAME

if [[ $? != 0 ]]; then
    kubectl logs $(kubectl get pods --sort-by=.metadata.creationTimestamp | grep "$SERVICE_NAME" | awk '{print $1}' | tac | head -1 ) --tail=20 && exit 1;
fi




kubectl apply -f ./deployment/main-k8s.yaml