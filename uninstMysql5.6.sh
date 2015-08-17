#!/bin/bash

# This script is used for uninstall MySQL on Ubuntu / Debian
# Will clean all mysql named directory in /etc and /var/lib
# By CrazyChen

rm -rf /var/lib/mysql/debian-*.flag
apt-get install -f -y --force-yes

echo "##########################################"
echo "Removing MySQL ......"
echo "##########################################"
apt-get remove --purge mysql-server mysql-client mysql-common -y --force-yes

echo "##########################################"
echo "Autoremove Unneeded file ......"
echo "##########################################"
apt-get autoremove -y --force-yes

echo "##########################################"
echo "Autocleaning ......"
echo "##########################################"
apt-get autoclean

echo "##########################################"
echo "Removing Files ......"
echo "##########################################"
rm -rf /etc/mysql
rm -rf /var/lib/mysql

echo "##########################################"
echo "Clean up complete ."
echo "##########################################"
