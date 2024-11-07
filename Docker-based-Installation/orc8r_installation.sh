set -x

mv -f /home/magma/magma_installation_scripts/Docker-based-Installation/orc8r/docker-compose.yml /home/magma/magma/orc8r/cloud/docker/docker-compose.yml

cd /home/magma/magma/orc8r/cloud/docker

chmod a+x ./build.py
python3 ./build.py --all

chmod a+x ./run.py
python3 ./run.py --metrics

mv -f /home/magma/magma_installation_scripts/Docker-based-Installation/nms/docker-compose.yml /home/magma/magma/nms/docker-compose.yml

mv -f /home/magma/magma_installation_scripts/Docker-based-Installation/nms/proxy_ssl.conf /home/magma/magma/nms/docker/docker_ssl_proxy/proxy_ssl.conf

sed -i "1i127.0.0.1 magma\n127.0.0.1 magma-test\n127.0.0.1 magma.test\n127.0.0.1 magma-test.localhost\n127.0.0.1 fluentd.magma.test\n127.0.0.1 magma-test\n127.0.0.1 bootstrapper-controller.magma.test\n127.0.0.1 controller.magma.test" /etc/hosts

cd /home/magma/magma/nms

COMPOSE_PROJECT_NAME=magmalte docker-compose build magmalte

docker-compose up -d

sleep 60

chmod a+x ./scripts/dev_setup.sh
bash ./scripts/dev_setup.sh


#TODO configure containers to auto-restart in reboot