mkdir -p /var/opt/magma/configs/
cp ./control_proxy.yml /var/opt/magma/configs/control_proxy.yml

mkdir -p /var/opt/magma/certs

cp /home/magma/magma/orc8r/cloud/deploy/scripts/self_sign_certs.sh /var/opt/magma/certs/self_sign_certs.sh
cp /home/magma/magma/orc8r/cloud/deploy/scripts/create_application_certs.sh /var/opt/magma/certs/create_application_certs.sh

cd /var/opt/magma/certs

bash self_sign_certs.sh localhost
bash create_application_certs.sh localhost