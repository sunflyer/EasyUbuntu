#!/bin/bash

# This is a shadowsock server installation script for Debian/Ubuntu
# Will install shadowsock and make a configuration file and launch scripts on current directory , and make a default port/password
# You can always edit your own configuration any time you want.
# By CrazyChen @ https://sunflyer.cn
# Aug 17 , 2015

echo "#####################################"
echo "# Shadowsock Server Installation    #"
echo "# By Crazychen @https://sunflyer.cn #"
echo "#####################################"

echo "#####################################"
echo "Updating sources"
echo "#####################################"
apt-get update
apt-get dist-upgrade -y

echo "#####################################"
echo " Install python pip and gevent   "
echo "#####################################"
apt-get install python-pip git -y --force-yes

echo "#####################################"
echo " Install Shadowsocks Server via pip"
echo "#####################################"
pip install setuptools
pip install wheel
#pip install shadowsocks
mkdir shadowsocks
cd shadowsocks
git clone https://github.com/shadowsocks/shadowsocks.git -b master
cd shadowsocks
python setup.py install

cd ../
echo "#####################################"
echo "Configuring chacha20 for shadowsocks"
echo "#####################################"

wget https://download.libsodium.org/libsodium/releases/LATEST.tar.gz -O LATEST.tar.gz
tar zxf LATEST.tar.gz
cd libsodium*
./configure
make && make install

echo /usr/local/lib > /etc/ld.so.conf.d/usr_local_lib.conf
ldconfig

cd ../
rm -rf libsodium* -rf
rm LATEST.tar.gz
echo "#####################################"
echo "Configuring json and scripts"
echo "#####################################"

echo -e '{"local_port":1080,\n"port_password":\n{\n "2333":"123456789",\n "2330":"987654321"\n},\n"method":"chacha20",\n"timeout":600}' > ssconfig.json
echo -e '#!/bin/bash\nssserver -d stop\nssserver -c ssconfig.json -d start --user nobody' > ss.sh
chmod a+x ss.sh

./ss.sh

echo "#####################################"
echo "Shadowsock server has launched with RC4-MD5 encryption , default port is 2333 with password 123456789 and port 2330 with password 987654321 "
echo "Remember to change your password and port by editing ssconfig.json and run ./restart.sh to make it alive"
echo "to start / stop / restart Shadowsock , run ./start.sh ./stop.sh or ./restart.sh "
echo "#####################################"
