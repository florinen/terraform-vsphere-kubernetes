#! /bin/bash

# disable swap since kubeadm documentation suggests disabling it
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo echo "vm.swappiness=0" | sudo tee --append /etc/sysctl.conf
 sudo sysctl -p
# sudo sed -i '/swap/d' /etc/fstab
exit
