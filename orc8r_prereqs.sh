mkdir -p /var/opt/magma/configs/
cp ./control_proxy.yml /var/opt/magma/configs/control_proxy.yml

bash /home/magma/magma/orc8r/cloud/deploy/scripts/self_sign_certs.sh localhost
bash /home/magma/magma/orc8r/cloud/deploy/scripts/create_application_certs.sh localhost

mkdir -p /var/opt/magma/certs

cp /home/magma/magma/orc8r/cloud/deploy/scripts/rootCA.pem /var/opt/magma/certs/rootCA.pem
cp /home/magma/magma/orc8r/cloud/deploy/scripts/admin_operator.key.pem /var/opt/magma/certs/admin_operator.key.pem
cp /home/magma/magma/orc8r/cloud/deploy/scripts/admin_operator.pem /var/opt/magma/certs/admin_operator.pem
