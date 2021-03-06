####setting interface
#interface 1:ex0001->setting static
#interface 2:eno1->setting manual
## https://docs.openstack.org/devstack/latest/
sed -i 's/us.archive.ubuntu.com/ftp.daumkakao.com/g' /etc/apt/sources.list
sed -i 's/security.ubuntu.com/ftp.daumkakao.com/g' /etc/apt/sources.list
apt-get update && apt-get dist-upgrade -y
sudo useradd -s /bin/bash -d /opt/stack -m stack
echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/stack
sudo su - stack
#git clone -b stable/ocata https://git.openstack.org/openstack-dev/devstack
git clone https://git.openstack.org/openstack-dev/devstack
cd devstack
cat <<EOF >/opt/stack/devstack/local.conf
[[local|localrc]]
HOST_IP=192.168.10.86
FIXED_RANGE=10.10.10.0/20
FIXED_NETWORK_SIZE=256
FLAT_INTERFACE=enp0s25
FLOATING_RANGE=192.168.11.224/27
ADMIN_PASSWORD=lovedcn
DATABASE_PASSWORD=\$ADMIN_PASSWORD
RABBIT_PASSWORD=\$ADMIN_PASSWORD
SERVICE_PASSWORD=\$ADMIN_PASSWORD
#MULTI_HOST=True
LOGFILE=/opt/stack/devstack.log
LOGDAYS=2
LOG_COLOR=True
#heat
enable_service h-eng h-api h-api-cfn h-api-cw
enable_plugin heat https://git.openstack.org/openstack/heat
#Mistral
enable_plugin mistral https://github.com/openstack/mistral.git
#Barbican
enable_plugin barbican https://git.openstack.org/openstack/barbican
#zun
enable_plugin zun https://git.openstack.org/openstack/zun
enable_plugin devstack-plugin-container https://git.openstack.org/openstack/devstack-plugin-container
enable_plugin zun-ui https://git.openstack.org/openstack/zun-ui
KURYR_ETCD_PORT=2379
enable_plugin kuryr-libnetwork https://git.openstack.org/openstack/kuryr-libnetwork
# install python-zunclient from git
LIBS_FROM_GIT="python-zunclient"
#Magnum
enable_plugin magnum https://github.com/openstack/magnum
#Tacker
#enable_plugin tacker https://github.com/openstack/tacker.git
#Neutron SFC
#SFC_UPDATE_OVS=False
#enable_plugin networking-sfc https://git.openstack.org/openstack/networking-sfc
#Ceilometer
CEILOMETER_BACKEND=gnocchi
#enable_service ceilometer-api
enable_plugin ceilometer https://git.openstack.org/openstack/ceilometer
enable_plugin aodh https://git.openstack.org/openstack/aodh
#lbaas
enable_plugin neutron-lbaas https://git.openstack.org/openstack/neutron-lbaas
enable_plugin octavia https://github.com/openstack/octavia
ENABLED_SERVICES+=,q-lbaasv2
ENABLED_SERVICES+=,octavia,o-cw,o-hk,o-hm,o-api
disable_service tempest
disable_service swift
disable_service c-api
disable_service c-sch
disable_service c-vol
disable_service cinder
USE_BARBICAN=True
EOF
./stack.sh
