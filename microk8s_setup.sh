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

# Notify user to log out and log back in for group membership to take effect
echo "Please log out and log back in for group membership to take effect."

# Ensure the .kube directory exists for 'baka' user
if [ ! -d "/home/baka/.kube" ]; then
  echo "Creating .kube directory for 'baka'..."
  sudo mkdir -p /home/baka/.kube
  sudo chown -R baka: /home/baka/.kube
fi

# Enable necessary MicroK8s services (dns, storage, and dashboard)
microk8s enable dns storage dashboard

# Restart MicroK8s to apply configuration changes
echo "Restarting MicroK8s services..."
sudo snap restart microk8s

# Wait for the Kubernetes API server to be fully available
echo "Waiting for Kubernetes API server to be available..."
# Loop until kubectl can successfully contact the API server
until microk8s kubectl get nodes &>/dev/null; do
  echo "Waiting for the Kubernetes API server to be available..."
  sleep 5
done

# Update the kubectl config to use the new server address
microk8s kubectl config set-cluster microk8s-cluster --server=https://$LOCAL_IP:16443

# Wait for kubeconfig to be fully applied
echo "Waiting for kubectl to be fully configured..."
sleep 5  # Allow some time for kubeconfig to take effect

# Test the kubectl connection
echo "Testing kubectl connection..."
microk8s kubectl get nodes

# Add the Wiki.js Helm chart repository
echo "Adding Wiki.js Helm repository..."
helm repo add wikijs https://charts.js.wiki
helm repo update

# Verify the Helm repository has been added
echo "Verifying the Wiki.js Helm repository..."
helm repo list

# Create a namespace for Wiki.js
echo "Creating namespace 'wikijs'..."
microk8s kubectl create namespace wikijs || echo "Namespace 'wikijs' already exists."

# Install Wiki.js using Helm (correct chart name)
echo "Installing Wiki.js..."
helm install wikijs wikijs/wiki --namespace wikijs

# Wait for Wiki.js pods to be created (optional)
echo "Waiting for Wiki.js to be deployed..."
sleep 60  # Wait time may vary depending on resources

# Verify the deployment exists
DEPLOYMENT_EXISTS=$(microk8s kubectl get deployment wikijs -n wikijs --ignore-not-found)
if [ -z "$DEPLOYMENT_EXISTS" ]; then
  echo "Wiki.js deployment failed to create."
  exit 1
fi

# Expose Wiki.js via NodePort
microk8s kubectl expose deployment wikijs --type=NodePort --name=wikijs-service --port=80 --target-port=3000 --namespace wikijs

# Get the exposed service port
EXTERNAL_PORT=$(microk8s kubectl get svc wikijs-service -n wikijs -o=jsonpath='{.spec.ports[0].nodePort}')

if [ -z "$EXTERNAL_PORT" ]; then
  echo "Failed to expose Wiki.js service on NodePort."
  exit 1
fi

echo "Wiki.js is exposed on port $EXTERNAL_PORT. You can access it at http://$LOCAL_IP:$EXTERNAL_PORT"

# Print completion message
echo "Setup complete: Wiki.js is ready to use."

# Complete
echo "Group membership applied. Kubernetes cluster setup is complete."
