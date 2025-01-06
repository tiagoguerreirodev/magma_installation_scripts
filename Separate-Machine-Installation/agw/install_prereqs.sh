#!/usr/bin/env bash

### Docker installation

ROOT_DIR="$PWD"

# Remove conflicting packages
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do apt-get remove $pkg; done

# Add Docker's official GPG key:
apt update
apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add the repository to Apt sources:
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update

apt-cache policy docker-ce

# Install
apt-get install -y docker-ce
curl -fsSL https://github.com/docker/compose/releases/download/v2.29.1/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Add user to Docker group
if [[ -z $(getent group docker) ]]; then
  echo "Groupadd docker"
	groupadd docker	
fi

usermod -aG docker $USER
echo "Added current user to Docker group"
chmod 777 /var/run/docker.sock

### Golang installation
wget https://go.dev/dl/go1.18.3.linux-amd64.tar.gz -O go.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go.tar.gz
echo export PATH=$HOME/go/bin:/usr/local/go/bin:$PATH >> /home/magma/.bashrc
rm go.tar.gz
echo "Installed golang"

git clone https://github.com/magma/magma.git /home/magma/magma
cd /home/magma/magma
git checkout v1.8
cd $ROOT_DIR

mkdir -p /var/opt/magma/configs/
cp ./control_proxy.yml /var/opt/magma/configs/control_proxy.yml
