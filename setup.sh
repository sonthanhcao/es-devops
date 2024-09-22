#!/bin/bash
set -e

load_config() {
    while IFS=: read -r key value; do
        key=$(echo "$key" | xargs)         # Trim whitespace
        value=$(echo "$value" | xargs | tr -d '"')  # Trim whitespace and remove quotes
        export "$key=$value"
    done < <(awk '!/^#/ && NF {print}' config.yaml)  # Ignore comments and empty lines
}

# Load variables from config.yaml
load_config

# Function to install dependencies on macOS
install_macos() {
    echo "Installing dependencies on macOS..."
    # Check if Homebrew is installed, install if not
    if ! command -v brew &> /dev/null; then
        echo "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    # Install dependencies using Homebrew
    brew install docker kubectl kind helm
}

# Function to install dependencies on Linux
install_linux() {
    echo "Installing dependencies on Linux..."
    # Update package list and install dependencies using apt-get
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

    # Install Docker
    # Add Docker's official GPG key:
    apt-get update
    apt-get install -y ca-certificates curl apt-transport-https gnupg
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc
    # Add the repository to Apt sources:
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Install kubectl
    curl -LO "https://dl.k8s.io/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

    # Install kind
    # For AMD64 / x86_64
    [ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.24.0/kind-linux-amd64
    # For ARM64
    [ $(uname -m) = aarch64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.24.0/kind-linux-arm64
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind

    # Install Helm
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
}

# Detect the operating system
if [[ "$OSTYPE" == "darwin"* ]]; then
    install_macos
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    install_linux
else
    echo "Unsupported operating system: $OSTYPE"
    exit 1
fi

# Start kind cluster
echo "Starting kind cluster..."
cat <<EOF | kind create cluster --config=- || true
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
EOF


echo "Dependencies installed and kind cluster started successfully."

NAMESPACE="arc-systems"
helm upgrade --install arc \
    --namespace "$NAMESPACE" \
    --create-namespace \
    oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller

# Setup Runner Scale Set
INSTALLATION_NAME="shared-github-runner"
NAMESPACE="arc-runners"
GITHUB_CONFIG_URL="https://github.com/$GITHUB_RUNNER_ORG/$GITHUB_RUNNER_REPO"
helm upgrade --install "$INSTALLATION_NAME" \
    --namespace "$NAMESPACE" \
    --create-namespace \
    --set githubConfigUrl="$GITHUB_CONFIG_URL" \
    --set githubConfigSecret.github_token="$GITHUB_TOKEN" \
    oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set
kubectl create clusterrolebinding shared-github-runner-binding \
  --clusterrole=cluster-admin \
  --serviceaccount=arc-runners:shared-github-runner-gha-rs-no-permission || true

# Create Ingress Nginx 
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Create Namespace
kubectl create ns development > /dev/null 2>&1 || true
kubectl create ns production > /dev/null 2>&1 || true
