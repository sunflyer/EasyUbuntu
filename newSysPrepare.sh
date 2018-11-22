#!/bin/bash
#懒的一个一个下载了，直接拉一群自动执行

apt update
apt install htop iftop dnsutils traceroute mtr curl python python-pip -y && apt-get clean

SCR_LIST="bbr.sh,jdkenv1.8.sh,lnmp.sh,mkswap.sh,setHttps.sh,v2ray.sh"
DOWNADDR="https://github.com/sunflyer/EasyUbuntu/raw/master/"

OLD_IFS="${IFS}"
IFS=","

LIST=(${SCR_LIST})

IFS=${OLD_IFS}

for x in ${LIST[@]}
do
        ADDR="${DOWNADDR}${x}"
        echo "Getting script [${x}] from [${ADDR}]"
        curl -OL ${ADDR}
        chmod +x ${x}
        # since script may not be required to run at the moment , no need the following line
        # bash {x}
done
