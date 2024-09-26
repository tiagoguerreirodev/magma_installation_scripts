#!/usr/bin/env bash

### Docker installation

# Remove conflicting packages
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do apt-get remove $pkg; done

# Add Docker's official GPG key:
sudo apt-get update
apt-get install -y ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update

# Install
apt-get install -y docker-ce docker-ce-cli containerd.io
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
wget https://linuxfoundation.jfrog.io/artifactory/magma-blob/go1.18.3.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.18.3.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
echo "Installed golang"

### Python installation
apt update -y
apt install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev  libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python-openssl git

git clone https://github.com/pyenv/pyenv.git /home/magma/.pyenv

echo 'export PYENV_ROOT="/home/magma/.pyenv"' >> /home/magma/.bashrc
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> /home/magma/.bashrc
echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n eval "$(pyenv init -) "\nfi' >> /home/magma/.bashrc

echo "Added Pyenv variables to bashrc and profile"

source /home/magma/.bashrc

pyenv install 3.8.10
pyenv global 3.8.10

dpkg --configure -a
apt-get -y install curl make virtualenv zip rsync git software-properties-common python3-pip python-dev apt-transport-https

echo "Configured python 3.8.10"

git clone https://github.com/magma/magma.git /home/magma/magma

mkdir -p /var/opt/magma/configs/
cp ./control_proxy.yml /var/opt/magma/configs/control_proxy.yml

mkdir -p /var/opt/magma/certs

cp /home/magma/magma/orc8r/cloud/deploy/scripts/self_sign_certs.sh /var/opt/magma/certs/self_sign_certs.sh
cp /home/magma/magma/orc8r/cloud/deploy/scripts/create_application_certs.sh /var/opt/magma/certs/create_application_certs.sh

cd /var/opt/magma/certs

bash self_sign_certs.sh magma-test
bash create_application_certs.sh magma-test

openssl pkcs12 -export -inkey admin_operator.key.pem -in admin_operator.pem -out admin_operator.pfx

chown magma:magma *
chmod a+rw ./controller.key