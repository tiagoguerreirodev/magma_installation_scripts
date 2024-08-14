#!/bin/bash

set -x

chmod a+x ./install_prereqs.sh
chmod a+x ./agw_ubuntu_custom.sh

bash ./install_prereqs.sh

source ~/.bashrc

apt purge netplan.io -y

cp ./eth0 /etc/network/interfaces.d/eth0
cp ./eth1 /etc/network/interfaces.d/eth1

ls /etc/network/interfaces.d
sleep 5

bash ./agw_ubuntu_custom.sh
