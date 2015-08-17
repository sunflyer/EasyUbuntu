#!/bin/bash

# PLEASE EXECUTE THIS SCRIPT USING SUDO
# Script is used for installing PHP5.6 MYSQL5.6 and Nginx Stable version from PPA
# Available on Ubuntu / Debian
# By CrazyChen @ https://sunflyer.cn
# last updated : Aug 17 , 2015


apt-get update
apt-get install software-properties-common -y --force-yes 
add-apt-repository ppa:ondrej/php5-5.6 -y
add-apt-repository ppa:nginx/stable -y
add-apt-repository ppa:ondrej/mysql-5.6 -y
echo Now updating source
apt-get update
echo Applying Dist-Upgrade
apt-get dist-upgrade -y
echo Begin Installation
echo ########################################
echo 	Nginx Installation Begin			
echo ########################################
apt-get install nginx -y --force-yes

echo ########################################
echo 	MySQL 5.6 Installation Begin		
echo ########################################
apt-get install mysql-server -y --force-yes

echo ########################################
echo 	PHP5.6 Installation Begin			
echo ########################################
apt-get install php5 php5-fpm php5-mysql -y --force-yes

echo 	Checking for versions installed.
php5 -v
php5-fpm -v
mysqld --version
nginx -V

echo ########################################
echo   Installation complete . If you see	
echo  	something error , please check by 	
echo  	yourself.							
echo ########################################
