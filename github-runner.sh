#!/bin/bash
# Disable exit on error
set +e
# Setup Github runner
CONCURRENT_RUNNERS=3
RUNNER_VERSION=2.317.0
RUNNER_ORG=sonthanhcao
RUNNER_LABELS=self-hosted,x64,shared-github-runner
RUNNER_GROUP=Default
RUNNER_NAME=shared-github-runner

cd /opt
# Download the latest runner package
curl -o actions-runner-linux-x64-$RUNNER_VERSION.tar.gz -L https://github.com/actions/runner/releases/download/v$RUNNER_VERSION/actions-runner-linux-x64-$RUNNER_VERSION.tar.gz
RANDOM_STRING=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 8)
for (( i=1; i<=$CONCURRENT_RUNNERS; i++ ))
do
  # Create a user for each runner
  USERNAME="github-runner-$i"
  sudo useradd -m -s /bin/bash $USERNAME
  sudo usermod -aG sudo $USERNAME
  echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$USERNAME
  sudo usermod -aG docker $USERNAME

  # Set up the runner
  RUNNER_DIR="/opt/actions-runner-$i"
  sudo mkdir -p $RUNNER_DIR
  sudo chown $USERNAME:$USERNAME $RUNNER_DIR

  sudo -u $USERNAME bash <<EOF
    

    # Extract the installer
    tar xzf /opt/actions-runner-linux-x64-$RUNNER_VERSION.tar.gz -C $RUNNER_DIR

    cd $RUNNER_DIR
    # Configure the runner
    ./config.sh --url https://github.com/$RUNNER_ORG --name aws-github-runner-$RANDOM_STRING-$i --pat $GITHUB_TOKEN --unattended --runnergroup $RUNNER_GROUP --labels "$RUNNER_LABELS"

    # Install the runner as a service
    sudo ./svc.sh install

    # Start the service
    sudo ./svc.sh start

    # Check the service status
    sudo ./svc.sh status
EOF

done

# # Mount instance store
# sudo mkfs.ext4 /dev/nvme0n1p1
# sudo mkdir -p /data
# sudo mount /dev/nvme0n1p1 /data
# sudo cp /etc/fstab /etc/fstab.bak
# sudo echo '/dev/nvme0n1p1  /data  ext4  defaults,nofail  0  2' | sudo tee -a /etc/fstab
# sudo mount -a

# Post Installation Steps
INSTANCE_MODE=$(curl -s http://169.254.169.254/latest/meta-data/instance-life-cycle)
if [ "$INSTANCE_MODE" = "spot" ]; then
    echo "This is a Spot Instance."
    # Tag EC2
    export AWS_REGION=${REGION}
    export EC2_NAME="github-runner"
    export INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

    # Run the AWS CLI command with each tag separately
    aws ec2 create-tags --region $AWS_REGION --resources $INSTANCE_ID --tags \
    Key=Name,Value=$EC2_NAME \
    Key=Terraform,Value=true \
    Key=Environment,Value=prod \
    Key=Application,Value=$EC2_NAME \
    Key=Team,Value=devops \
    Key=Contact,Value=devops
else
    echo "This is an On-Demand Instance."
fi

