#!/bin/bash
if [ $# -lt '2' ]; then
  echo "Simple Squid + Stunnel Proxy Script for Ubuntu"
  echo "Usage : squidtunnel.sh [SSL Cert Pubkey File] [SSL Priv Key Path]"
  exit
fi

PUBKEY=$1
PRIVKEY=$2

apt-get update && apt-get upgrade -y
apt-get install squid3 stunnel apache2-utils -y && apt-get clean
mkdir /etc/squid3
cat > /etc/squid3/squid.conf << EOF
http_port 127.0.0.1:18080
acl CONNECT method CONNECT
auth_param basic program /usr/lib/squid3/basic_ncsa_auth /etc/squid3/squid.passwd
auth_param basic children 5
auth_param basic realm Non-Authoritive Service Password
auth_param basic credentialsttl 2 hours
auth_param basic casesensitive off
acl ncsa_users proxy_auth REQUIRED
http_access allow ncsa_users
http_access deny all
httpd_suppress_version_string on
EOF

echo "Input user name for Proxy Authentication :"
read NAME
echo "Input password for Proxy Authentication : "
read PASSWORD
htpasswd -bc /etc/squid3/squid.passwd $NAME $PASSWORD
echo "Now configuring Stunnel"
mkdir /etc/stunnel
cat > /etc/stunnel/stunnel.conf << EOF
client = no
[squid]
accept = 8443
connect = 127.0.0.1:18080
cert = $PUBKEY
key = $PRIVKEY
EOF

echo "Checking config of Squid"
squid3 -k check
echo "restarting service"
service squid3 restart
service stunnel4 restart

echo "Service Deploy complete , please use "
