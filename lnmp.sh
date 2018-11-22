#!/bin/bash

# PLEASE EXECUTE THIS SCRIPT USING SUDO
# Script is used for installing PHP5.6 MYSQL5.6 and Nginx Stable version from PPA
# Available on Ubuntu / Debian
# By CrazyChen @ https://sunflyer.cn
# last updated : Aug 17 , 2015

INSTALL_MYSQL=1
INSTALL_PHP=1

if [ $# -gt '0' ]; then
    INSTALL_MYSQL=$1
fi

if [ $# -gt '1' ]; then
    INSTALL_PHP=$2
fi

PHP_VERSION="7.2"
PHP_PREFIX="php${PHP_VERSION}"

apt-get update
apt-get install software-properties-common -y --force-yes 
add-apt-repository ppa:ondrej/php -y

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C

wget http://nginx.org/keys/nginx_signing.key -O nginx.key && apt-key add nginx.key && rm nginx.key

VER=""
source /etc/lsb-release
DATA=`echo ${DISTRIB_RELEASE}| cut -c 1-2`
if [ "$DATA" = "14" ]; then
    VER="trusty"
elif [ "$DATA" = "16" ]; then
    VER="xenial"
elif [ "$DATA" = "18" ]; then
    VER="bionic"
fi

echo deb http://nginx.org/packages/ubuntu/ $VER nginx >> /etc/apt/sources.list
echo deb-src http://nginx.org/packages/ubuntu/ $VER nginx >> /etc/apt/sources.list

#wget https://dev.mysql.com/get/mysql-apt-config_0.5.3-1_all.deb && dpkg -i mysql-apt-config_0.5.3-1_all.deb

echo "########################################"
echo Now updating source
echo "########################################"
apt-get update

echo "########################################"
echo Applying Dist-Upgrade
echo "########################################"
apt-get upgrade -y

echo "########################################"
echo Begin Installation
echo "########################################"
echo 	Nginx Installation Begin			
echo "########################################"
apt-get install nginx -y --force-yes

if [ ${INSTALL_MYSQL} -eq '1' ]; then
echo "########################################"
echo 	MySQL 5.6 Installation Begin		
echo "########################################"
apt-get install mysql-server -y --force-yes
fi

if [ ${INSTALL_PHP} -eq '1' ]; then
echo "########################################"
echo 	PHP5.6 Installation Begin			
echo "########################################"
apt-get install ${PHP_PREFIX} ${PHP_PREFIX}-fpm ${PHP_PREFIX}-common ${PHP_PREFIX}-curl ${PHP_PREFIX}-gd ${PHP_PREFIX}-xml ${PHP_PREFIX}-bz2 ${PHP_PREFIX}-bcmath ${PHP_PREFIX}-ldap ${PHP_PREFIX}-sqlite3 ${PHP_PREFIX}-cli ${PHP_PREFIX}-mcrypt ${PHP_PREFIX}-mbstring ${PHP_PREFIX}-mysql ${PHP_PREFIX}-redis ${PHP_PREFIX}-zip -y --force-yes
fi

mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
cat >> /etc/nginx/nginx.conf << EOF
user  nginx;
worker_processes  auto;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format cnlog '\$time_local|\$remote_addr|\$http_x_forwarded_for|\$http_x_real_ip|\$remote_user|\$status|\$request|\$body_bytes_sent|\$http_referer|\$http_user_agent';
    access_log  /var/log/nginx/access.log  cnlog;

    sendfile        on;

    keepalive_timeout  65;

    client_max_body_size 100m;
    server_tokens off;

    include /etc/nginx/conf.d/*.conf;

    gzip on;
    gzip_vary on;
    gzip_comp_level 6;
    gzip_buffers 16 8k;
    gzip_http_version 1.1;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
}
EOF

echo "########################################"
echo  "Installation complete . If you see	something error , please check by	yourself."
echo  'DO NOT FORGET to add the following line to your website configuration file "http" part or "fastcgi" part if using php via nginx , otherwise it may leads to blank content'
echo  "fastcgi_param  SCRIPT_FILENAME \$document_root\$fastcgi_script_name";
echo "########################################"
