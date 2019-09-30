#! /bin/bash

## Install prerequisites.
#yum install yum-utils device-mapper-persistent-data lvm2 -y
#sudo apt-get install  curl apt-transport-https ca-certificates gnupg-agent software-properties-common -y
## Add docker repository.
# yum-config-manager \
#     --add-repo \
#     https://download.docker.com/linux/centos/docker-ce.repo
sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

#sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
#curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"

## Install docker.
sudo apt-get update && sudo apt-get install docker-ce docker-ce=18.06.2~ce~3-0~ubuntu containerd.io -y

# Run as non-root user
#sudo usermod -aG docker your-user

# Setup daemon
sudo su -
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

mkdir -p /etc/systemd/system/docker.service.d
su - ubuntu 

# Restart docker.
sudo systemctl daemon-reload && sudo systemctl restart docker && sudo systemctl enable docker




## Create /etc/docker directory.
# mkdir /etc/docker

# Setup daemon.
# cat > /etc/docker/daemon.json <<EOF
# {
#   "exec-opts": ["native.cgroupdriver=systemd"],
#   "log-driver": "json-file",
#   "log-opts": {
#     "max-size": "100m"
#   },
#   "storage-driver": "overlay2",
#   "storage-opts": [
#     "overlay2.override_kernel_check=true"
#   ]
# }
# EOF

# mkdir -p /etc/systemd/system/docker.service.d

