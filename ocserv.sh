#!/bin/bash
if [ $# -lt '2' ]; then
  echo "Simple OCServ (OpenConnect Server) Script for Ubuntu"
  echo "Usage : ocserv.sh [SSL Cert Pubkey File] [SSL Priv Key Path]"
  exit
fi

OCSERV_VERSION="0.11.8"
INSTALL_PATH="/opt/ocserv"

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

cat >> ${INSTALL_PATH}/etc/config < EOF
device = tun0
auth = "plain[${INSTALL_PATH}/etc/passwd]"
tcp-port = 8443
udp-port = 8443
try-mtu-discovery = true
max-clients = 128
max-same-clients = 4
server-cert = ${PUBKEY}
server-key = ${PRIVKEY}
ca-cert = ${PUBKEY}
mobile-idle-timeout = 2400
ipv4-network = 192.168.100.0
ipv4-netmask = 255.255.255.0
dns = 8.8.8.8
dns = 8.8.4.4
cisco-client-compat = true
#route = 
route-add-cmd = "ip route add 192.168.100.0 dev tun0"
route-del-cmd = "ip route delete 192.168.100.0 dev tun0"
socket-file = /var/run/ocserv-socket.sf
#run-as-user = ocserv 
#run-as-group = ocserv
EOF

cat >> ${INSTALL_PATH}/run.sh < EOF
#!/bin/bash
iptables -t nat -D POSTROUTING -s 192.168.100.0/24 -j MASQUERADE
${INSTALL_PATH}/sbin/ocserv -c ${INSTALL_PATH}/etc/config
iptables -t nat -A POSTROUTING -s 192.168.100.0/24 -j MASQUERADE
EOF

chmod +x ${INSTALL_PATH}/run.sh
ln -s ${INSTALL_PATH}/run.sh /etc/init.d/ocserv-autorun
update-rc.d ocserv-autorun defaults 99

bash ${INSTALL_PATH}/run.sh
