#!/bin/bash
if [ $# -lt '2' ]; then
  echo "Simple Squid + Stunnel Proxy Script for Ubuntu"
  echo "Usage : squidtunnel.sh [SSL Cert Pubkey File] [SSL Priv Key Path]"
  exit
fi

PUBKEY=$1
PRIVKEY=$2

apt-get update && apt-get upgrade -y
apt-get install squid stunnel apache2-utils -y && apt-get clean
#mkdir /etc/squid
mv /etc/squid/squid.conf /etc/squid/squid.conf.bak
cat > /etc/squid/squid.conf << EOF
http_port 127.0.0.1:18080
acl CONNECT method CONNECT
auth_param basic program /usr/lib/squid/basic_ncsa_auth /etc/squid/squid.passwd
auth_param basic children 5
auth_param basic realm Non-Authoritive Service Password
auth_param basic credentialsttl 2 hours
auth_param basic casesensitive off
acl ncsa_users proxy_auth REQUIRED

acl internal dst 172.16.0.0/12
acl internal dst 10.0.0.0/8
acl internal dst 100.64.0.0/10
acl internal dst 192.168.0.0/16
acl dstlocal dst 127.0.0.0/8
acl dstlocal dst ::1

http_access deny internal
http_access deny dstlocal

http_access allow ncsa_users
http_access deny all
httpd_suppress_version_string on
cache deny all
via off
forwarded_for off
follow_x_forwarded_for deny all
request_header_access X-Forwarded-For deny all
header_access X_Forwarded_For deny all
error_directory /usr/share/squid/errors/en
reply_header_access X-Squid-Error deny all
reply_header_access Server deny all
reply_header_access X-Cache deny all
reply_header_access X-Cache-Lookup deny all
EOF

echo "Input user name for Proxy Authentication :"
read NAME
echo "Input password for Proxy Authentication : "
read PASSWORD
htpasswd -bc /etc/squid/squid.passwd $NAME $PASSWORD
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

cat > /etc/default/stunnel4 << EOF
ENABLED=1
FILES="/etc/stunnel/*.conf"
OPTIONS=""
PPP_RESTART=0
RLIMITS=""
EOF

echo "Checking config of Squid"
squid -k check
echo "restarting service"
service squid restart
service stunnel4 restart

echo "Service Deploy complete , please use "
