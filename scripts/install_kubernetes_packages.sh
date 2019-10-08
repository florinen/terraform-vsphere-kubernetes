#! /bin/bash

## Ubuntu ##

sudo su - -c "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -"
sudo su - -c "cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF"

#sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"

sudo apt-get install -y nfs-common kubelet kubeadm kubectl kubernetes-cni openssl jq
sudo apt-mark hold kubelet kubeadm kubectl 
sudo systemctl enable kubelet && sudo  systemctl start kubelet

## CRI-O as CRI runtime 
# sudo su - c "cat > /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
# net.bridge.bridge-nf-call-iptables  = 1
# net.ipv4.ip_forward                 = 1
# net.bridge.bridge-nf-call-ip6tables = 1
# EOF"
sysctl net.bridge.bridge-nf-call-iptables=1
sysctl --system

# Install prerequisites
# apt-get update
# apt-get install software-properties-common -y

add-apt-repository ppa:projectatomic/ppa -y
apt-get update

# Install CRI-O
# apt-get install -y cri-o-1.13
# systemctl start crio


 
