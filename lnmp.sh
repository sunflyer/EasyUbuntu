#!/bin/bash

# PLEASE EXECUTE THIS SCRIPT USING SUDO
# Script is used for installing PHP5.6 MYSQL5.6 and Nginx Stable version from PPA
# Available on Ubuntu / Debian
# By CrazyChen @ https://sunflyer.cn
# last updated : Aug 17 , 2015


apt-get update
apt-get install software-properties-common -y --force-yes 
add-apt-repository ppa:ondrej/php5.6 -y

wget http://nginx.org/keys/nginx_signing.key && apt-key add nginx_signing.key

echo deb http://nginx.org/packages/mainline/ubuntu/ trusty nginx >> /etc/apt/sources.list
echo deb-src http://nginx.org/packages/mainline/ubuntu/ trusty nginx >> /etc/apt/sources.list

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
apt-get install php5 php5-fpm php5-common php5-xmlrpc php5-curl php5-gd php5-cli php-pear php5-dev php5-imap php5-mcrypt -y --force-yes

echo "########################################"
echo 	Checking for versions installed.
echo "########################################"
echo PHP5 and FPM :
php5 -v
php5-fpm -v
echo "########################################"
echo MYSQL :
mysqld --version
echo "########################################"
echo Nginx :
nginx -V

echo "########################################"
echo  "Installation complete . If you see	something error , please check by	yourself."
echo  'DO NOT FORGET to add the following line to your website configuration file "http" part or "fastcgi" part if using php via nginx , otherwise it may leads to blank content'
echo  "fastcgi_param  SCRIPT_FILENAME \$document_root\$fastcgi_script_name";
echo "########################################"
