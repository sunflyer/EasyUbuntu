#!/bin/bash

# PLEASE EXECUTE THIS SCRIPT USING SUDO
# Script is used for installing PHP5.6 MYSQL5.6 and Nginx Stable version from PPA
# Available on Ubuntu / Debian
# By CrazyChen @ https://sunflyer.cn
# last updated : Aug 17 , 2015

PHP_VERSION="7.1"
PHP_PREFIX="php${PHP_VERSION}"

apt-get update
apt-get install software-properties-common -y --force-yes 
add-apt-repository ppa:ondrej/php -y

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C

wget http://nginx.org/keys/nginx_signing.key -O nginx.key && apt-key add nginx.key && rm nginx.key

VER=""
DATA=$(cat /etc/issue | grep 14.04)
if [ "x$DATA" != "x" ]; then
    VER="trusty"
else
    VER="xenial"
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
apt-get dist-upgrade -y

echo "########################################"
echo Begin Installation
echo "########################################"
echo 	Nginx Installation Begin			
echo "########################################"
apt-get install nginx -y --force-yes

echo "########################################"
echo 	MySQL 5.6 Installation Begin		
echo "########################################"
apt-get install mysql-server -y --force-yes

echo "########################################"
echo 	PHP5.6 Installation Begin			
echo "########################################"
apt-get install ${PHP_PREFIX} ${PHP_PREFIX}-fpm ${PHP_PREFIX}-common ${PHP_PREFIX}-curl ${PHP_PREFIX}-gd ${PHP_PREFIX}-xml ${PHP_PREFIX}-bz2 ${PHP_PREFIX}-bcmath ${PHP_PREFIX}-ldap ${PHP_PREFIX}-sqlite3 ${PHP_PREFIX}-cli ${PHP_PREFIX}-mcrypt ${PHP_PREFIX}-mbstring ${PHP_PREFIX}-mysql -y --force-yes

echo "########################################"
echo  "Installation complete . If you see	something error , please check by	yourself."
echo  'DO NOT FORGET to add the following line to your website configuration file "http" part or "fastcgi" part if using php via nginx , otherwise it may leads to blank content'
echo  "fastcgi_param  SCRIPT_FILENAME \$document_root\$fastcgi_script_name";
echo "########################################"
