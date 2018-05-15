#! /bin/sh

echo "kris ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
apt update
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
apt-get update -y
apt-get install google-chrome-stable -y
apt-get install -y vim glances crudini curl
apt-get install -y qemu-kvm libvirt-bin bridge-utils

cat << 'EOF' >> /etc/network/interfaces

auto eth1
iface eth1 inet manual
  up ip link set dev eth1 up
  down ip link set dev eth1 down
EOF

cp hosts /etc/hosts

apt-get install python-jinja2 python-pip libssl-dev -y
pip install -U pip
crudini --set /etc/default/grub "" GRUB_CMDLINE_LINUX '"net.ifnames=0 biosdevname=0"'
update-grub
apt upgrade -y

# Set-up LVM for cinder-volumes
pvcreate /dev/vdb
vgcreate cinder-volumes /dev/vdb
echo "configfs" >> /etc/modules
update-initramfs -u
systemctl daemon-reload
systemctl stop open-iscsi
systemctl disable open-iscsi
systemctl stop iscsid
systemctl disable iscsid

reboot
