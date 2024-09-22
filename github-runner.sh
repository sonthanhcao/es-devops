#!/bin/bash
kubectl create ns actions-runner-system
kubectl create secret generic controller-manager \
    -n actions-runner-system \
    --from-literal=github_token=$GITHUB_TOKEN

helm repo add actions-runner-controller https://actions-runner-controller.github.io/actions-runner-controller
helm upgrade --install --namespace actions-runner-system --create-namespace \
             --wait actions-runner-controller actions-runner-controller/actions-runner-controller