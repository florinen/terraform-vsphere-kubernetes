#! /bin/bash

## Ubuntu ##
sudo su -
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
su - ubuntu


sudo apt-get install -y nfs-common kubelet kubeadm kubectl kubernetes-cni openssl jq
sudo apt-mark hold kubelet kubeadm kubectl 
sudo systemctl enable kubelet && sudo  systemctl start kubelet
 
 





## Centos ##
# cat <<EOF > /etc/yum.repos.d/kubernetes.repo
# [kubernetes]
# name=Kubernetes
# baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
# enabled=1
# gpgcheck=1
# repo_gpgcheck=1
# gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
# exclude=kube*
# EOF

# Set SELinux in permissive mode (effectively disabling it)
# setenforce 0
# sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# yum install -y nfs-utils kubelet kubeadm kubectl openssl --disableexcludes=kubernetes


# cat <<EOF >  /etc/sysctl.d/k8s.conf
# net.bridge.bridge-nf-call-ip6tables = 1
# net.bridge.bridge-nf-call-iptables = 1
# EOF

# sysctl --system
