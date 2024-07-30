mkdir -p /var/opt/magma/configs/
cp ./control_proxy.yml /var/opt/magma/configs/control_proxy.yml

bash /home/magma/magma/orc8r/cloud/deploy/scripts/self_sign_certs.sh localhost

mkdir -p /var/opt/magma/tmp/certs
cp /home/magma/magma/orc8r/cloud/deploy/scripts/rootCA.pem /var/opt/magma/certs/rootCA.pem
