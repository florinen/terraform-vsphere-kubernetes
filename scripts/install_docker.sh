#! /bin/bash
## UBUNTU

# Necessary packages to allow the use of Docker’s repository
sudo apt-get install -y\
         apt-transport-https \
         ca-certificates \
         curl \
         gnupg-agent \
         software-properties-common\

# Add Docker’s GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
# Verify the fingerprint of the GPG key
sudo apt-key fingerprint 0EBFCD88
#Add the stable Docker repository
sudo add-apt-repository \
           "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
              $(lsb_release -cs) \
                 stable"
 
## For Ubuntu 19.04 you will need to use the edge / test repository
#sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable edge test"

## Update
sudo apt-get update
### To check the list of available Docker versions, run ###
#  apt-cache madison docker-ce

## Install docker
sudo apt-get install -y docker-ce=5:18.09.0~3-0~ubuntu-bionic 

# Setup daemon.
sudo su - -c "cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF"

sudo mkdir -p /etc/systemd/system/docker.service.d

## Restart service
sudo systemctl daemon-reload && sudo systemctl restart docker

# Run as non-root user
sudo usermod -aG docker $(whoami)




## Centos 7
## Install prerequisites.
#yum install yum-utils device-mapper-persistent-data lvm2 -y
#sudo apt-get install  curl apt-transport-https ca-certificates gnupg-agent software-properties-common -y
## Add docker repository.
# yum-config-manager \
#     --add-repo \
#     https://download.docker.com/linux/centos/docker-ce.repo

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

# Restart docker.
#sudo systemctl daemon-reload && sudo systemctl restart docker && sudo systemctl enable docker




.


 

