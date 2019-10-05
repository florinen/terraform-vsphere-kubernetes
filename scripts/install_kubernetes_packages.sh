#! /bin/bash

## Ubuntu ##

# curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
# sudo su - -c "cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
# deb https://apt.kubernetes.io/ kubernetes-xenial main
# EOF"

# #sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"

# sudo apt-get install -y nfs-common kubelet kubeadm kubectl kubernetes-cni openssl jq
# sudo apt-mark hold kubelet kubeadm kubectl 
# sudo systemctl enable kubelet && sudo  systemctl start kubelet

# ## CRI-O as CRI runtime 
# sudo su - c "cat > /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
# net.bridge.bridge-nf-call-iptables  = 1
# net.ipv4.ip_forward                 = 1
# net.bridge.bridge-nf-call-ip6tables = 1
# EOF"

# sysctl --system

# # Install prerequisites
# apt-get update
# apt-get install software-properties-common

# add-apt-repository ppa:projectatomic/ppa
# apt-get update

# # Install CRI-O
# apt-get install cri-o-1.13
# systemctl start crio


# sudo su - -c "cat <<EOF >>/etc/ufw/sysctl.conf 
# net/bridge/bridge-nf-call-ip6tables = 1
# net/bridge/bridge-nf-call-iptables = 1
# net/bridge/bridge-nf-call-arptables = 1
# EOF"

# sudo sysctl -p



## Centos ##
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kube*
EOF

# #Set SELinux in permissive mode (effectively disabling it)
# setenforce 0
# sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

yum install -y nfs-utils kubelet kubeadm kubectl openssl --disableexcludes=kubernetes
systemctl enable kubelet && systemctl start kubelet

cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sysctl --system

# # Install prerequisites
# yum-config-manager --add-repo=https://cbs.centos.org/repos/paas7-crio-115-release/x86_64/os/

# # Install CRI-O
# yum install --nogpgcheck cri-o
# systemctl start criovim