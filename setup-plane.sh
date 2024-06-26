# Enabling kernel modules (overlay and br_netfilter)
sudo modprobe overlay
sudo modprobe br_netfilter

# automatically load kernel modules via the config file
sudo cat <<EOF | sudo tee /etc/modules-load.d/kubernetes.conf
overlay
br_netfilter
EOF

# Checking kernel module status
lsmod | grep overlay
lsmod | grep br_netfilter

# setting up kernel parameters via config file
sudo cat <<EOF | sudo tee /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Applying new kernel parameters
sudo sysctl --system

# Disabling SWAP

sudo swapoff -a

# checking SWAP via /procs/swaps
cat /proc/swaps

# checking SWAP via command free -m
sudo free -m

# Opening ports for Control Plane
sudo ufw allow 6443/tcp
sudo ufw allow 2379:2380/tcp
sudo ufw allow 10250/tcp
sudo ufw allow 10259/tcp
sudo ufw allow 10257/tcp

# Opening ports for Calico CNI
sudo ufw allow 179/tcp
sudo ufw allow 4789/udp
sudo ufw allow 4789/tcp
sudo ufw allow 2379/tcp

sudo ufw status
# Create two environment variables OS* and CRIO-VERSION on all your servers
OS=xUbuntu_22.04
CRIO_VERSION=1.28

# Execute the following commands to add the cri-o repository via apt
sudo echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /"|sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
sudo echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$CRIO_VERSION/$OS/ /"|sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION.list

## Download the gpg key
sudo curl -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$CRI_VERSION/$OS/Release.key | sudo apt-key --keyring /etc/apt/trusted.gpg.d/libcontainers.gpg add -
sudo curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | sudo apt-key --keyring /etc/apt/trusted.gpg.d/libcontainers.gpg add -

# Update and refresh package index
sudo apt-get update 
sudo apt upgrade -y

# Install CRI-O container runtime
sudo apt install -y cri-o cri-o-runc

# Restarting Cri-o to check for errors
sudo systemctl restart crio

# Enabling CRI-O service to start at boot
sudo systemctl enable crio

# Checking CRI-O service status
sudo systemctl status crio
apt-cache policy cri-o

# Add the Kube-Repo
sudo echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo apt-get update

# installs the Kubernetes components/packages
sudo apt install -y kubeadm kubelet kubectl --allow-change-held-packages

# Prevent them from being updated automatically
sudo apt-mark hold kubelet kubeadm kubectl 

# Pull container images for Kubernetes beforehand
sudo kubeadm config images pull

# Save time by setting kubectl to "kc"
echo 'alias kc=kubectl' >>~/.bashrc 
echo 'source <(kubectl completion bash)' >>~/.bashrc 
echo 'complete -F __start_kubectl kc' >>~/.bashrc

# Kubeadm init
publicIP=192.168.1.118
ip_address=192.168.1.118
cidr=172.18.0.0/16
sudo kubeadm init --control-plane-endpoint $publicIP --apiserver-advertise-address $ip_address --pod-network-cidr=$cidr --upload-certs

### OR (recommended by official documentation)
#### setup autocomplete in bash into the current shell, bash-completion package should be installed first.
source <(kubectl completion bash)
#### add autocomplete permanently to your bash shell.
echo "source <(kubectl completion bash)" >> ~/.bashrc 
#### shorthand alias
alias kc=kubectl
complete -F __start_kubectl kc

# Same for kubeadm > "ka"
#### setup autocomplete in bash into the current shell, bash-completion package should be installed first. 
source <(kubectl completion bash)
#### add autocomplete permanently to your bash shell.
echo "source <(kubectl completion bash)" >> ~/.bashrc 
#### shorthand alias
alias ka=kubeadm
complete -F __start_kubectl ka

# To start using your cluster, you need to run the following as a regular user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install Weave
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml

