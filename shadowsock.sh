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
apt-get install python-pip python-gevent -y --force-yes

echo "#####################################"
echo " Install Shadowsocks Server via pip"
echo "#####################################"
pip install shadowsocks

echo "#####################################"
echo "Configuring json and scripts"
echo "#####################################"

echo -e '{"local_port":1080,\n"port_password":\n{\n "2333":"123456789",\n "2330":"987654321"\n},\n"method":"rc4-md5",\n"timeout":600}' > ssconfig.json
echo -e '#!/bin/bash\nssserver -c ssconfig.json -d start --user nobody' > start.sh
echo -e "#!/bin/bash\nssserver -d stop" > stop.sh
echo -e "#!/bin/bash\n./start.sh\n./stop.sh" > restart.sh
chmod a+x start.sh
chmod a+x stop.sh
chmod a+x restart.sh

./start.sh

echo "#####################################"
echo "Shadowsock server has launched with RC4-MD5 encryption , default port is 2333 with password 123456789 and port 2330 with password 987654321 "
echo "Remember to change your password and port by editing ssconfig.json and run ./restart.sh to make it alive"
echo "to start / stop / restart Shadowsock , run ./start.sh ./stop.sh or ./restart.sh "
echo "#####################################"
