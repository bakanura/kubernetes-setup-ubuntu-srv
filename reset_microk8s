#!/bin/bash

# Stop and remove MicroK8s
echo "Stopping MicroK8s..."
sudo microk8s stop

# Reset MicroK8s (removes all configurations, add-ons, and resources)
echo "Resetting MicroK8s..."
sudo microk8s reset

# Remove MicroK8s snap package (completely uninstall)
echo "Removing MicroK8s installation..."
sudo snap remove microk8s

# Optionally, remove any leftover configurations or directories
echo "Removing residual configurations..."
sudo rm -rf /var/snap/microk8s
sudo rm -rf /home/$USER/.kube

# Reinstall MicroK8s if desired
# echo "Reinstalling MicroK8s..."
# sudo snap install microk8s --classic
