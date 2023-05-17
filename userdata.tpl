#!/bin/bash
sudo apt-get update -y &&
sudo apt-get install -y \
apt-transport-https \
ca-certificates \
curl \
gnupg-agent \
software-properties-common &&
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo a>
sudo add-apt-repository "deb [arch=amd64] https://download.docke>
sudo apt-get update -y &&
sudo sudo apt-get install docker-ce docker-ce-cli containerd.io >
sudo usermod -aG docker ubuntu

