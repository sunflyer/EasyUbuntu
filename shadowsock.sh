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
apt-get upgrade -y

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

#wget https://download.libsodium.org/libsodium/releases/LATEST.tar.gz -O LATEST.tar.gz
wget https://github.com/jedisct1/libsodium/releases/download/1.0.13/libsodium-1.0.13.tar.gz  -O LATEST.tar.gz
tar zxf LATEST.tar.gz
cd libsodium*
./configure
make && make install

echo /usr/local/lib > /etc/ld.so.conf.d/usr_local_lib.conf
ldconfig

cd ../
rm -rf libsodium* -rf
rm LATEST.tar.gz
cd ../
echo "#####################################"
echo "Configuring json and scripts"
echo "#####################################"

echo "Input port number for shadowsock (choose a port number from 1 to 65535) : "
read PORT_NUM
echo "Input password for shadowsock : "
read PASSWORD

CURR_PATH=`pwd`

cat > /etc/ssconfig.json << EOF
{
    "local_port":1080,
    "port_password":{
        "${PORT_NUM}":"${PASSWORD}"
    },
    "method":"chacha20",
    "timeout":600
}
EOF

echo -e '#!/bin/bash\nssserver -d stop\nssserver -c /etc/ssconfig.json -d start --user nobody' > ss.sh
chmod a+x ss.sh

#autorun for shadowsock
ln -s "${CURR_PATH}/ss.sh" /etc/init.d/shadowsock-python-autorun
update-rc.d shadowsock-python-autorun defaults 99

./ss.sh

echo "#####################################"
echo "Configuration complete"
echo "Shadowsock Port : ${PORT_NUM}"
echo "Shadowsock Password : ${PASSWORD}"
echo "#####################################"
