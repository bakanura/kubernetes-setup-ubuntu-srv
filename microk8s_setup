#!/bin/bash

# Define the local IP
LOCAL_IP="192.168.8.122"

# Update and install necessary packages
sudo apt update
sudo apt install -y snapd curl apt-transport-https ca-certificates software-properties-common

# Install MicroK8s
sudo snap install microk8s --classic

# Add the user 'baka' to the 'microk8s' group to allow access to kubectl
sudo usermod -a -G microk8s baka

# Apply new group membership immediately using 'newgrp'
echo "Reloading group membership for 'baka'..."
newgrp microk8s <<EOF
echo "Group membership for 'baka' has been reloaded."
EOF

# Ensure the .kube directory exists for 'baka' user
if [ ! -d "/home/baka/.kube" ]; then
  echo "Creating .kube directory for 'baka'..."
  sudo mkdir -p /home/baka/.kube
  sudo chown -R baka: /home/baka/.kube
fi

# Enable necessary MicroK8s services (dns, storage, and dashboard)
echo "Enabling MicroK8s services: DNS, Storage, and Dashboard..."
microk8s enable dns storage dashboard

# Update the MicroK8s API server to bind to the local IP
echo "Updating API server bind address to $LOCAL_IP"
sudo sed -i "s/--bind-address=0.0.0.0/--bind-address=$LOCAL_IP/" /var/snap/microk8s/current/args/kube-apiserver

# Reload systemd to ensure any new unit files are recognized
sudo systemctl daemon-reload

# Restart the entire MicroK8s service to apply changes
echo "Restarting MicroK8s services..."
sudo snap restart microk8s

# Update the kubectl config to use the new server address
echo "Updating kubectl config to use the new server address..."
microk8s kubectl config set-cluster microk8s-cluster --server=https://$LOCAL_IP:16443

# Ensure that the kubectl setup is working (testing connectivity)
echo "Testing Kubernetes connectivity..."
microk8s kubectl get nodes || { echo "Error: Unable to connect to the Kubernetes cluster"; exit 1; }

# Patch Kubernetes Dashboard to expose it on all interfaces (hostPort 8443)
echo "Patching Kubernetes Dashboard deployment..."
sudo microk8s kubectl patch deployment kubernetes-dashboard -n kube-system --patch '{"spec":{"template":{"spec":{"containers":[{"name":"kubernetes-dashboard","ports":[{"containerPort":8443,"hostPort":8443}]}]}}}}'

# Install Helm
echo "Installing Helm..."
sudo snap install helm --classic

# Add GitLab Helm repository
echo "Adding GitLab Helm repository..."
helm repo add gitlab https://charts.gitlab.io
helm repo update

# Create a namespace for GitLab and install GitLab
echo "Creating namespace for GitLab and installing GitLab..."
microk8s kubectl create namespace gitlab
helm install gitlab gitlab/gitlab --namespace gitlab

# Wait for GitLab pods to be created (optional)
echo "Waiting for GitLab to be deployed..."
sleep 60  # Wait time may vary depending on resources

# Create the folder structure
echo "Creating folder structure..."
mkdir -p ~/server/game-server/spt_dedicated

# Print completion message
echo "Setup complete: MicroK8s, Kubernetes Dashboard, GitLab, and folder structure are ready."

# Output the URL for accessing the Kubernetes dashboard (you can open this on your local network)
echo "You can access the Kubernetes Dashboard at https://$LOCAL_IP:8443"

# To get your local IP address (for accessing the dashboard and other services)
echo "Your local IP address is: $LOCAL_IP"

# Provide instructions to access GitLab
echo "GitLab is being deployed. You can access it using the external IP of the GitLab service (use 'microk8s kubectl get svc --namespace gitlab' to check)."

# Complete
echo "Group membership applied. Kubernetes cluster setup is complete."
