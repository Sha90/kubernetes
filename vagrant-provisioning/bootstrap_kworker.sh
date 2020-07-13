#!/bin/bash

# Join worker nodes to the Kubernetes cluster
echo "[TASK 1] Join node to Kubernetes Cluster"
apt-get install -y sshpass >/dev/null 2>&1
sshpass -p "vagrant" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no vagrant@kmaster.example.com:/joincluster.sh /joincluster.sh > /dev/null 2>&1
bash /joincluster.sh > /dev/null 2>&1

