#! /bin/sh

pip install ansible==2.5.2

pip install kolla-ansible==6.0.0

cp -r /usr/local/share/kolla-ansible/etc_examples/kolla /etc/kolla
cp globals.yml /etc/kolla

# vim /etc/kolla/globals.yml
# ifconfig
# ip a

kolla-genpwd
kolla-ansible -i /usr/local/share/kolla-ansible/ansible/inventory/all-in-one bootstrap-servers

mkdir -p /etc/systemd/system/docker.service.d
cat << 'EOF' > /etc/systemd/system/docker.service.d/kolla.conf
[Service]
MountFlags=shared
ExecStart=
ExecStart=/usr/bin/docker daemon -H fd:// --mtu 1400
EOF
systemctl daemon-reload
systemctl restart docker

kolla-ansible -i /usr/local/share/kolla-ansible/ansible/inventory/all-in-one pull
kolla-ansible -i /usr/local/share/kolla-ansible/ansible/inventory/all-in-one prechecks
kolla-ansible -i /usr/local/share/kolla-ansible/ansible/inventory/all-in-one deploy
docker ps -a
kolla-ansible post-deploy
pip install python-openstackclient
cp init-runonce /usr/local/share/kolla-ansible/init-runonce
. /etc/kolla/admin-openrc.sh
cd /usr/local/share/kolla-ansible
./init-runonce
echo "Horizon available at 10.0.0.10, user 'admin', password below:"
grep keystone_admin_password /etc/kolla/passwords.yml
