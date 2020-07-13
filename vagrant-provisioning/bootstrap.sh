#!/bin/bash

# Update hosts file
echo "[TASK 1] Update /etc/hosts file"
cat >>/etc/hosts<<EOF
172.16.16.100 kmaster.example.com kmaster
172.16.16.101 kworker1.example.com kworker1
172.16.16.102 kworker2.example.com kworker2
EOF

# Install docker from Docker-ce repository
echo "[TASK 2] Install docker container engine"
apt-get update && \
apt-get install -y apt-transport-https ca-certificates curl gnupg-agent \
                   software-properties-common > /dev/null 2>&1
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /dev/null 2>&1
apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io > /dev/null 2>&1

# Enable docker service
#echo "[TASK 3] Enable and start docker service"
#systemctl enable docker >/dev/null 2>&1
#systemctl start docker

# Add sysctl settings
echo "[TASK 4] Add sysctl settings"
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system >/dev/null 2>&1

# Disable swap
echo "[TASK 5] Disable and turn off SWAP"
sed -i '/swap/d' /etc/fstab
swapoff -a

# Add apt repo file for Kubernetes
echo "[TASK 6] Add apt repo file for kubernetes"
apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF | tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update

# Install Kubernetes
echo "[TASK 7] Install Kubernetes (kubeadm, kubelet and kubectl)"
apt-get install -y kubelet kubeadm kubectl >/dev/null 2>&1
apt-mark hold kubelet kubeadm kubectl >/dev/null 2>&1

# Start and Enable kubelet service
echo "[TASK 8] Enable and start kubelet service"
systemctl daemon-reload >/dev/null 2>&1
systemctl restart kubelet >/dev/null 2>&1

# Enable ssh password authentication
echo "[TASK 9] Enable ssh password authentication"
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl reload sshd

# Set Root password
#echo "[TASK 10] Set root password"
#echo "kubeadmin" | passwd root >/dev/null 2>&1

# Update vagrant user's bashrc file
echo "export TERM=xterm" >> /etc/bashrc
