data "vsphere_datastore" "node_datastore" {
  name          = "${var.virtual_machine_kubernetes_node["datastore"]}"
  datacenter_id = "${data.vsphere_datacenter.template_datacenter.id}"
}

# data "vsphere_resource_pool" "node_resource_pool" {
#   name          = "${var.virtual_machine_kubernetes_node["resource_pool"]}"
#   datacenter_id = "${data.vsphere_datacenter.template_datacenter.id}"
# }
# data "vsphere_compute_cluster" "cluster" {
#   name = "${var.virtual_machine_kubernetes_controller["drs_cluster"]}"
#   datacenter_id = "${data.vsphere_datacenter.template_datacenter.id}"
# }
data "vsphere_network" "node_network" {
  name          = "${var.virtual_machine_kubernetes_node["network"]}"
  datacenter_id = "${data.vsphere_datacenter.template_datacenter.id}"
}


resource "vsphere_virtual_machine" "kubernetes_nodes" {
  count            = "${var.virtual_machine_kubernetes_node["count"]}"
  name             = "${format("${var.virtual_machine_kubernetes_node["prefix"]}-%03d", count.index + 1)}"
  resource_pool_id = "${vsphere_resource_pool.vm_resource_pool.id}"
  datastore_id     = "${data.vsphere_datastore.node_datastore.id}"
  folder           = "${vsphere_folder.folder.path}"
  num_cpus = "${var.virtual_machine_kubernetes_node["num_cpus"]}"
  memory   = "${var.virtual_machine_kubernetes_node["memory"]}"
  guest_id = "${data.vsphere_virtual_machine.template.guest_id}"

  scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"

  network_interface {
    network_id   = "${data.vsphere_network.vm_network.id}"
    adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
  }

  disk {
    label = "${var.virtual_machine_kubernetes_node["prefix"]}"
    size = "${data.vsphere_virtual_machine.template.disks.0.size}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"

    customize {
      timeout = "20"
      linux_options {
        host_name = "${format("${var.virtual_machine_kubernetes_node["prefix"]}-%03d", count.index + 1)}"
        domain    = "${var.virtual_machine_kubernetes_node["domain"]}"
      }

      network_interface {
        ipv4_address = "${cidrhost( var.virtual_machine_kubernetes_node["ip_address_network"], var.virtual_machine_kubernetes_node["starting_hostnum"]+count.index )}"
        ipv4_netmask = "${element( split("/", var.virtual_machine_kubernetes_node["ip_address_network"]), 1)}"
      }

      ipv4_gateway = "${var.virtual_machine_kubernetes_node["gateway"]}"
      dns_server_list = ["${var.virtual_machine_kubernetes_node["dns_server"]}"]
      #dns_suffix_list = ["kubernetes.local"]    
    }
  }

  provisioner "file" {
    source      = "${var.virtual_machine_kubernetes_controller["public_key"]}"
    destination = "/tmp/authorized_keys"

    connection {
      host        = "${element(vsphere_virtual_machine.kubernetes_nodes.*.default_ip_address, count.index)}"
      type        = "${var.virtual_machine_template["connection_type"]}"
      user        = "${var.virtual_machine_template["connection_user"]}"
      password    = "${var.virtual_machine_template["connection_password"]}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /root/.ssh/",
      "chmod 700 /root/.ssh",
      "mv /tmp/authorized_keys /root/.ssh/authorized_keys",
      "chmod 600 /root/.ssh/authorized_keys",
      "sed -i 's/#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config",
      "service sshd restart"
    ]
    
    connection {
      host          = "${element(vsphere_virtual_machine.kubernetes_nodes.*.default_ip_address, count.index)}"
      type          = "${var.virtual_machine_template["connection_type"]}"
      user          = "${var.virtual_machine_template["connection_user"]}"
      password      = "${var.virtual_machine_template["connection_password"]}"
    }
  }

  
  provisioner "file" {
    source      = "${var.virtual_machine_kubernetes_controller["my_ssh_keys"]}"
    destination = "/tmp/my_ssh_keys"
    
    connection {
      host          = "${element(vsphere_virtual_machine.kubernetes_nodes.*.default_ip_address, count.index)}"
      type          = "${var.virtual_machine_template["connection_type"]}"
      user          = "${var.virtual_machine_template["connection_user"]}"
      private_key   = "${file("${var.virtual_machine_kubernetes_controller["private_key"]}")}" 
    }
  }

  provisioner "remote-exec" {
    inline =[
      "cat /tmp/my_ssh_keys >> $HOME/.ssh/authorized_keys",
       "rm -f '/tmp/my_ssh_keys'",
      #"sudo sed -i 's/preserve_hostname:.*/preserve_hostname: true/' /etc/cloud/cloud.cfg",
      # "IPADDRESS=$(ip address show dev ens160 | grep 'inet '| awk '{print $2}'| cut -d '/' -f1)",
      # "echo $IPADDRESS    $HOSTNAME >> /etc/hosts",
      # "sudo init 6"
    ]
  
    connection {
      host          = "${element(vsphere_virtual_machine.kubernetes_nodes.*.default_ip_address, count.index)}"
      type          = "${var.virtual_machine_template["connection_type"]}"
      user          = "${var.virtual_machine_template["connection_user"]}"
      private_key   = "${file("${var.virtual_machine_kubernetes_controller["private_key"]}")}" 
   
    }
  }
  provisioner "file" {
    source      = "./scripts/"
    destination = "/tmp/"

    connection {
      host          = "${element(vsphere_virtual_machine.kubernetes_nodes.*.default_ip_address, count.index)}"
      type          = "${var.virtual_machine_template["connection_type"]}"
      user          = "${var.virtual_machine_template["connection_user"]}"
      private_key   = "${file("${var.virtual_machine_kubernetes_controller["private_key"]}")}" 
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/*sh",
      "sudo /tmp/system_setup.sh",
      "sudo /tmp/install_docker.sh",
      "sudo /tmp/install_kubernetes_packages.sh",
    ]
    connection {
      host          = "${element(vsphere_virtual_machine.kubernetes_nodes.*.default_ip_address, count.index)}" 
      type          = "${var.virtual_machine_template["connection_type"]}"
      user          = "${var.virtual_machine_template["connection_user"]}"
      private_key   = "${file("${var.virtual_machine_kubernetes_controller["private_key"]}")}" 
    }
  }

}

resource "null_resource" "kubeadm_join" {
  count            = "${var.virtual_machine_kubernetes_node["count"]}"
  provisioner "remote-exec" {
    # Command #  "kubeadm join --token ${vsphere_virtual_machine.kubernetes_controller.*.default_ip_address}:6443 --discovery-token-ca-cert-hash sha256:${data.external.kubeadm-init-info.result.certhash}",
    inline = [
       "echo 'Running the kubeadm join command.'",
       "kubeadm join --token ${vsphere_virtual_machine.kubernetes_controller.*.default_ip_address}:6443 --discovery-token-ca-cert-hash sha256:${data.kubeadm-init-info.result.certhash}",
       "sleep 300"

    ]
    connection {
      host          = "${element(vsphere_virtual_machine.kubernetes_nodes.*.default_ip_address, count.index)}" 
      type          = "${var.virtual_machine_template["connection_type"]}"
      user          = "${var.virtual_machine_template["connection_user"]}"
      private_key   = "${file("${var.virtual_machine_kubernetes_controller["private_key"]}")}"
      
    }
  }
}
