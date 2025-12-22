#!/usr/bin/env bash

curl -sfL https://get.k3s.io | sh -
sudo kubectl get nodes

# Root -> Normal User
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER:$USER ~/.kube/config

sudo mkdir -p /etc/systemd/system/k3s.service.d
sudo tee /etc/systemd/system/k3s.service.d/kubeconfig.conf << 'EOF'
[Service]
ExecStart=
ExecStart=/usr/local/bin/k3s server --write-kubeconfig-mode 644
EOF

kubectl get pods -A

kubectl get pods -n kube-system
