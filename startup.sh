#!/bin/bash
GO_VERSION="1.12.5"
TF_VERSION="0.12.1"

install_go(){
	echo "+ installing golang"
	cd /root
	wget https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz

	tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
	export PATH=$PATH:/usr/local/go/bin
	go version
	rm go${GO_VERSION}.linux-amd64.tar.gz
	echo "+ golang installed"
}

install_terraform(){
	echo "+ installing Terraform"
	wget https://releases.hashicorp.com/terraform/0.12.1/terraform_${TF_VERSION}_linux_amd64.zip

	unzip terraform_${TF_VERSION}_linux_amd64.zip -d /usr/local/bin/
	terraform version
	rm terraform_${TF_VERSION}_linux_amd64.zip
	echo "+ Terraform installed" 
}

install_consul(){
	#install Consul docker image for consul keygen
	echo "+ installing Consul"
	docker pull consul
	echo "+ consul installed"
}

install_ansible(){
	echo "+ installing Ansible"
	apt -y install software-properties-common
	apt-add-repository --yes --update ppa:ansible/ansible
	apt -y install ansible
	ansible --version
	echo "+ Ansible installed" 
}

install_deps(){
	echo "+ installing deps"
	apt -y update
	sleep 3
	apt -y install unzip git


	#install go(needed to build Vultr TF Provider, will hopefully become official/bundled w/ the TF binary eventually
	install_go
	install_consul
	install_terraform
	install_ansible
	echo "deps installed"
}

provisioning_prep(){
	echo "+ prepping tf dir"
	#dir for git cloning plans to, TF plans reference this dir and subdirs
	mkdir /root/terraform

	#create consul encrypt key for new cluster
	docker run consul keygen > /root/terraform/consul_key

	#git dir for tf plugins and libraries 
	mkdir /root/git
	
	#dir for symlinks to plugins(Vultr TF provider primarily)
	mkdir /root/.terraform.d/plugins/
	
	#Create provisioner SSH key pair
	ssh-keygen -f /root/.ssh/id_rsa -t rsa -b 4096 -N ''
	
	echo "+ tf prep finished, git clone plans to /root/terraform/"
}

main(){
	install_deps
	provisioning_prep
	#save boot script log
	cp /tmp/firstboot.log /root/boot.log
}

main
