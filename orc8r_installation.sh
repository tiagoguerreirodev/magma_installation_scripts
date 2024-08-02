set -x

cd /home/magma/magma/orc8r/cloud/docker

sed -i 's@$PWD/../../../.cache/test_certs:/var/opt/magma/certs@/var/opt/magma/certs:/var/opt/magma/certs@g'

chmod a+x build.py
python3 ./build.py --all

#TODO change ports in orc8r build
#24225:24224
#24225:24224/udp
#24226:24224
#24226:24224/udp

chmod a+x run.py
python3 ./run.py --metrics

cd /home/magma/magma/nms/app/packages/magmalte

sed -i '70,74d;40d' docker-compose.yml

docker-compose build magmalte

sed -i 's/"8081:8081"/"8082:8081"/g' /home/magma/magma/nms/app/packages/magmalte/docker-compose.yml

sed -i 's@API_CERT_FILENAME:-../../../../.cache/test_certs/admin_operator.pem@API_CERT_FILENAME:-/var/opt/magma/certs/admin_operator.pem@g' /home/magma/magma/nms/app/packages/magmalte/docker-compose.yml
sed -i 's@API_PRIVATE_KEY_FILENAME:-../../../../.cache/test_certs/admin_operator.key.pem@API_CERT_FILENAME:-/var/opt/magma/certs/admin_operator.key.pem@g' /home/magma/magma/nms/app/packages/magmalte/docker-compose.yml

docker-compose up -d

sleep 10

chmod a+x ./scripts/dev_setup.sh
bash ./scripts/dev_setup.sh

sed -i "1i127.0.0.1 magma\n127.0.0.1 magma-test\n127.0.0.1 bootstrapper-controller.magma.test\n127.0.0.1 controller.magma.test" /etc/hosts

#TODO configure containers to auto-restart in reboot
