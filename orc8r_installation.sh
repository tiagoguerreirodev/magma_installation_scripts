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

docker compose build magmalte

#TODO change ports in magmalte build
# 8082:8081

docker compose up -d

sleep 10

chmod a+x ./scripts/dev_setup.sh
bash ./scripts/dev_setup.sh

#TODO add the following lines in /etc/hosts
# 127.0.0.1 magma
# 127.0.0.1 magma-test
# 127.0.0.1 bootstrapper-controller.magma.test
# 127.0.0.1 controller.magma.test

#TODO configure containers to auto-restart in reboot
