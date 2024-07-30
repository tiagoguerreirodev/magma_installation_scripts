set -x

cd /home/magma/magma/orc8r/cloud/docker

chmod a+x build.py
bash ./build.py --all

#TODO change ports in orc8r build
#24225:24224
#24225:24224/udp
#24226:24224
#24226:24224/udp

chmod a+x run.py
bash ./run.py --metrics

cd /home/magma/magma/nms/app/packages/magmalte

docker-compose build magmalte

sed -i 's/"8081:8081"/"8082:8081"/g' /home/magma/magma/nms/app/packages/magmalte/docker-compose.yml

docker-compose up -d

sleep 10

chmod a+x ./scripts/dev_setup.sh
bash ./scripts/dev_setup.sh

sed -i "1i127.0.0.1 magma\n127.0.0.1 magma-test\n127.0.0.1 bootstrapper-controller.magma.test\n127.0.0.1 controller.magma.test" /etc/hosts

#TODO configure containers to auto-restart in reboot
