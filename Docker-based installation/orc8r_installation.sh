set -x

cd /home/magma/magma/orc8r/cloud/docker

# sed -i 's@$PWD/../../../.cache/test_certs:/var/opt/magma/certs@/var/opt/magma/certs:/var/opt/magma/certs@g' /home/magma/magma/orc8r/cloud/docker/docker-compose.yml

# sed -i -e '$anetworks:\n  orc8r_default:\n    name: orc8r_default' /home/magma/magma/orc8r/cloud/docker/docker-compose.yml

# sed -i -e '2s@$@\n    networks:\n      - orc8r_default@' /home/magma/magma/orc8r/cloud/docker/docker-compose.yml

mv -f ./orc8r/docker-compose.yml /home/magma/magma/orc8r/cloud/docker/docker-compose.yml


chmod a+x build.py
python3 ./build.py --all

chmod a+x run.py
python3 ./run.py --metrics

# cd /home/magma/magma/nms

mv -f ./nms/docker-compose.yml /home/magma/magma/nms/docker-compose.yml

mv -f ./nms/proxy_ssl.conf /home/magma/magma/nms/docker/docker_ssl_proxy/proxy_ssl.conf

# sed -i '39d' /home/magma/magma/nms/docker-compose.yml

# sed -i 's/"8081:8081"/"8082:8081"/g' /home/magma/magma/nms/docker-compose.yml

# COMPOSE_PROJECT_NAME=magmalte docker-compose build magmalte

# sed -i 's@API_CERT_FILENAME:-../.cache/test_certs/admin_operator.pem@API_CERT_FILENAME:-/var/opt/magma/certs/admin_operator.pem@g' /home/magma/magma/nms/docker-compose.yml
# sed -i 's@API_PRIVATE_KEY_FILENAME:-../.cache/test_certs/admin_operator.key.pem@API_CERT_FILENAME:-/var/opt/magma/certs/admin_operator.key.pem@g' /home/magma/magma/nms/docker-compose.yml

# sed -i 's@localhost:8081/healthz@localhost:8082/healthz@g' /home/magma/magma/nms/docker-compose.yml

# sed -i 's@http://magmalte:8081@http://magmalte:8082@g' /home/magma/magma/nms/docker/docker_ssl_proxy/proxy_ssl.conf

sed -i "1i127.0.0.1 magma\n127.0.0.1 magma-test\n127.0.0.1 magma.test\n127.0.0.1 magma-test.localhost\n127.0.0.1 fluentd.magma.test\n127.0.0.1 magma-test\n127.0.0.1 bootstrapper-controller.magma.test\n127.0.0.1 controller.magma.test" /etc/hosts

docker-compose up -d

sleep 10

chmod a+x ./scripts/dev_setup.sh
bash ./scripts/dev_setup.sh


#TODO configure containers to auto-restart in reboot
