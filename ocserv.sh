#!/bin/bash
if [ $# -lt '2' ]; then
  echo "Simple OCServ (OpenConnect Server) Script for Ubuntu"
  echo "Usage : ocserv.sh [SSL Cert Pubkey File] [SSL Priv Key Path]"
  exit
fi

OCSERV_VERSION="0.11.10"
INSTALL_PATH="/opt/ocserv"
SUBNET="192.168.100.0/24"

PUBKEY=$1
PRIVKEY=$2

echo "####  Checking Updates And Dependens"
apt-get update && apt-get install libgnutls28-dev libev-dev nettle-dev build-essential libreadline-dev  -y && apt-get clean

mkdir -p "${INSTALL_PATH}/compile"
cd "${INSTALL_PATH}/compile"
wget ftp://ftp.infradead.org/pub/ocserv/ocserv-${OCSERV_VERSION}.tar.xz -O ocserv.tar.xz
tar xvf ocserv.tar.xz

cd ocserv*
./configure --prefix=${INSTALL_PATH} && make && make install

mkdir ${INSTALL_PATH}/etc/

cat > ${INSTALL_PATH}/etc/config << EOF
device = tun0
# by default using plain text authentication
# comment this out if you would like to use cert auth
auth = "plain[${INSTALL_PATH}/etc/passwd]"
# uncomment following 3 line and download ocm.sh in this repo to use cert auth
#auth = "certificate"
#cert-user-oid = 2.5.4.3
#ca-cert = /opt/ocserv/certs/ca.pem
tcp-port = 8443
udp-port = 8443
try-mtu-discovery = true
max-clients = 128
max-same-clients = 4
server-cert = ${PUBKEY}
server-key = ${PRIVKEY}
#ca-cert = ${PUBKEY}
mobile-idle-timeout = 2400
ipv4-network = ${SUBNET}
dns = 8.8.8.8
dns = 8.8.4.4
cisco-client-compat = true
#route = 
#route-add-cmd = "ip route add 192.168.100.0 dev tun0"
#route-del-cmd = "ip route delete 192.168.100.0 dev tun0"
no-route=10.0.0.0/8
no-route=100.64.0.0/10
no-route=169.254.0.0/16
no-route=172.16.0.0/12
no-route=192.168.0.0/16
no-route=203.0.113.0/24
no-route=224.0.0.0/4
no-route=240.0.0.0/4
no-route=fc00::/7
no-route=fe80::/10
no-route=ff00::/8

socket-file = /var/run/ocserv-socket.sf
#run-as-user = ocserv 
#run-as-group = ocserv
EOF

cat > ${INSTALL_PATH}/run.sh << EOF
#!/bin/bash
iptables -t nat -D POSTROUTING -s ${SUBNET} -j MASQUERADE
${INSTALL_PATH}/sbin/ocserv -c ${INSTALL_PATH}/etc/config
iptables -t nat -A POSTROUTING -s ${SUBNET} -j MASQUERADE
EOF

chmod +x ${INSTALL_PATH}/run.sh
ln -s ${INSTALL_PATH}/run.sh /etc/init.d/ocserv-autorun
update-rc.d ocserv-autorun defaults 99

bash ${INSTALL_PATH}/run.sh

cat > ${INSTALL_PATH}/addUser.sh << EOF
#!/bin/bash
echo "Input a user name for authentication / 请输入你的用户名 : "
read USERNAME
echo "Input password for your user / 请输入密码  "
${INSTALL_PATH}/bin/ocpasswd -c ${INSTALL_PATH}/etc/passwd \${USERNAME}
EOF

chmod +x ${INSTALL_PATH}/addUser.sh

bash ${INSTALL_PATH}/addUser.sh
