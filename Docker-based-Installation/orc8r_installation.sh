set -x

mv -f /home/magma/magma_installation_scripts/Docker-based-Installation/orc8r/docker-compose.yml /home/magma/magma/orc8r/cloud/docker/docker-compose.yml

chmod a+x /home/magma/magma/orc8r/cloud/docker/build.py
python3 /home/magma/magma/orc8r/cloud/docker/build.py --all

chmod a+x /home/magma/magma/orc8r/cloud/docker/run.py
python3 /home/magma/magma/orc8r/cloud/docker/run.py --metrics

mv -f /home/magma/magma_installation_scripts/Docker-based-Installation/nms/docker-compose.yml /home/magma/magma/nms/docker-compose.yml

mv -f /home/magma/magma_installation_scripts/Docker-based-Installation/nms/proxy_ssl.conf /home/magma/magma/nms/docker/docker_ssl_proxy/proxy_ssl.conf

sed -i "1i127.0.0.1 magma\n127.0.0.1 magma-test\n127.0.0.1 magma.test\n127.0.0.1 magma-test.localhost\n127.0.0.1 fluentd.magma.test\n127.0.0.1 magma-test\n127.0.0.1 bootstrapper-controller.magma.test\n127.0.0.1 controller.magma.test" /etc/hosts

docker-compose up -d

sleep 10

chmod a+x /home/magma/magma/nms/scripts/dev_setup.sh
bash /home/magma/magma/nms/scripts/dev_setup.sh


#TODO configure containers to auto-restart in reboot
