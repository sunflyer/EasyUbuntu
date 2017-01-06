#!/bin/bash

BASE_ADDR="https://github.com/sunflyer/EasyUbuntu/raw/master/"

getsrc(){
    echo "Fetching $1"
    URL="$BASE_ADDR/$1"
    wget $URL -O $1
    chmod +x $1
    echo "Executing $1"
    ./$1
}


if [ $# -gt '0' ]; then
    for src in $@ do    
        getsrc $src
    done
    exit
fi

SRC=('lnmp.sh' 'setHttps.sh' 'shadowsock.sh' 'jdkenv1.8.sh' 'bbr.sh')

echo "Checking Wget "
apt-get update && apt-get install wget

for src in ${SRC[@]}; do
    getsrc $src
done
