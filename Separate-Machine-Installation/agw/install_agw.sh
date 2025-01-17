#!/bin/bash
# Copyright 2021 The Magma Authors.

# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree.

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Setting up env variable, user and project path
set -x

addr1="$1"
gw_addr="$2"

MAGMA_USER="magma"
AGW_INSTALL_CONFIG_LINK="/etc/systemd/system/multi-user.target.wants/agw_installation.service"
AGW_INSTALL_CONFIG="/lib/systemd/system/agw_installation.service"
AGW_SCRIPT_PATH="/root/agw_install_ubuntu.sh"
DEPLOY_PATH="/home/$MAGMA_USER/magma/lte/gateway/deploy"
SUCCESS_MESSAGE="ok"
NEED_REBOOT=0
WHOAMI=$(whoami)
MAGMA_VERSION="${MAGMA_VERSION:-v1.8}"
CLOUD_INSTALL="cloud"
GIT_URL="${GIT_URL:-https://github.com/magma/magma.git}"
INTERFACE_DIR="/etc/network/interfaces.d"

echo "Checking if the script has been executed by root user"
if [ "$WHOAMI" != "root" ]; then
  echo "You're executing the script as $WHOAMI instead of root.. exiting"
  exit 1
fi

echo "Checking if Ubuntu is installed"
if ! grep -q 'Ubuntu' /etc/issue; then
  echo "Ubuntu is not installed"
  exit 1
fi

if [ "$SKIP_PRECHECK" != "$SUCCESS_MESSAGE" ]; then
  wget https://raw.githubusercontent.com/magma/magma/"$MAGMA_VERSION"/lte/gateway/deploy/agw_pre_check_ubuntu.sh
  if [[ -f ./agw_pre_check_ubuntu.sh ]]; then
    bash agw_pre_check_ubuntu.sh
  else
    echo "agw_pre_check_ubuntu.sh is not available in your version"
  fi
fi

apt-get update

FILE="/home/$MAGMA_USER/already_configured"

echo "Running initial configuration. Please configure eth and eth1 interfaces manually, using ifupdown."
if ! [ -f $FILE ]; then
  # changing intefaces name
  sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"/g' /etc/default/grub
  # sed -i 's/enp0s3/eth0/g' /etc/netplan/50-cloud-init.yaml
  # changing interface name
  grub-mkconfig -o /boot/grub/grub.cfg

  # name server config
  ln -sf /var/run/systemd/resolve/resolv.conf /etc/resolv.conf
  sed -i 's/#DNS=/DNS=8.8.8.8 208.67.222.222/' /etc/systemd/resolved.conf
  service systemd-resolved restart

  # interface config
  apt install -y ifupdown net-tools ipcalc
  apt purge netplan.io -y
  mkdir -p "$INTERFACE_DIR"
  echo "source-directory $INTERFACE_DIR" > /etc/network/interfaces

  echo "rename enp0s3=eth0
  auto eth0
  iface eth0 inet dhcp" > "$INTERFACE_DIR"/eth0

  echo "rename enp0s8=eth1
  auto eth1
  iface eth1 inet static
  address 192.168.2.2
  netmask 255.255.255.0" > "$INTERFACE_DIR"/eth1

  # get rid of netplan
  systemctl unmask networking
  systemctl enable networking

  apt-get --assume-yes purge nplan netplan.i

  # Setting REBOOT flag to 1 because we need to reload new interface and network services.
  NEED_REBOOT=1

  touch $FILE
else
  echo "Interfaces name are correct, let's check if network and DNS are up"
  while ! nslookup google.com; do
    echo "DNS not reachable"
    sleep 1
  done

  while ! ping -c 1 -W 1 -I eth0 8.8.8.8; do
    echo "Network not ready yet"
    sleep 1
  done
fi

echo "Making sure $MAGMA_USER user is sudoers"
if ! grep -q "$MAGMA_USER ALL=(ALL) NOPASSWD:ALL" /etc/sudoers; then
  apt install -y sudo
  adduser --disabled-password --gecos "" $MAGMA_USER
  adduser $MAGMA_USER sudo
  echo "$MAGMA_USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
fi

if [ $NEED_REBOOT = 1 ]; then
  echo "Will reboot in a few seconds, loading a boot script in order to install magma"
  sleep 20
  if [ ! -f "$AGW_SCRIPT_PATH" ]; then
      cp "$(realpath $0)" "${AGW_SCRIPT_PATH}"
  fi
  cat <<EOF > $AGW_INSTALL_CONFIG
[Unit]
Description=AGW Installation
After=network-online.target
Wants=network-online.target
[Service]
Environment=MAGMA_VERSION=${MAGMA_VERSION}
Environment=GIT_URL=${GIT_URL}
Environment=REPO_PROTO=${REPO_PROTO}
Environment=REPO_HOST=${REPO_HOST}
Environment=REPO_DIST=${REPO_DIST}
Environment=REPO_COMPONENT=${REPO_COMPONENT}
Environment=REPO_KEY=${REPO_KEY}
Environment=REPO_KEY_FINGERPRINT=${REPO_KEY_FINGERPRINT}
Environment=SKIP_PRECHECK=${SUCCESS_MESSAGE}
Type=oneshot
ExecStart=/bin/bash ${AGW_SCRIPT_PATH}
TimeoutStartSec=3800
TimeoutSec=3600
User=root
Group=root
[Install]
WantedBy=multi-user.target
EOF
  chmod 644 $AGW_INSTALL_CONFIG
  ln -sf $AGW_INSTALL_CONFIG $AGW_INSTALL_CONFIG_LINK
  sleep 20
  reboot
fi

MAGMA_SUCCESS="/home/$MAGMA_USER/installation_success"

echo "Checking if magma has been installed"

if ! [ -f $MAGMA_SUCCESS ]; then
  echo "Magma not installed, processing installation"
  apt-get -y install curl make virtualenv zip rsync git software-properties-common python3-pip python-dev apt-transport-https

  alias python=python3
  pip3 install ansible==5.10.0

  git clone "${GIT_URL}" /home/$MAGMA_USER/magma
  cd /home/$MAGMA_USER/magma || exit
  git checkout "$MAGMA_VERSION"

  echo "Generating localhost hostfile for Ansible"
  echo "[magma_deploy]
  127.0.0.1 ansible_connection=local" > $DEPLOY_PATH/agw_hosts

  # install magma and its dependencies including OVS.
  su - $MAGMA_USER -c "ansible-playbook -e \"MAGMA_ROOT='/home/$MAGMA_USER/magma' OUTPUT_DIR='/tmp'\" -i $DEPLOY_PATH/agw_hosts $DEPLOY_PATH/magma_deploy.yml"

  echo "Cleanup temp files"
  cd /root || exit
  #rm -rf $AGW_INSTALL_CONFIG
  #rm -rf /home/$MAGMA_USER/build
  #rm -rf /home/$MAGMA_USER/magma

  echo "AGW installation is done, Run agw_post_install_ubuntu.sh install script after reboot to finish installation"
  wget https://raw.githubusercontent.com/magma/magma/"$MAGMA_VERSION"/lte/gateway/deploy/agw_post_install_ubuntu.sh -P /root/

  touch $MAGMA_SUCCESS

  sleep 20
  reboot
else
  echo "Magma already installed, skipping.."
fi
