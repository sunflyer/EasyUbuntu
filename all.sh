#!/bin/bash

BASE_ADDR="https://github.com/sunflyer/EasyUbuntu/raw/master/"
SRC=('lnmp.sh' 'setHttps.sh' 'shadowsock.sh' 'jdkenv1.8.sh' 'bbr.sh')

echo "Checking Wget "
apt-get update && apt-get install wget

for src in ${SRC[@]}; do
    echo "Fetching $src"
    URL="$BASE_ADDR/$src"
    wget $ULR -O $src
    chmod +x $src
    echo "Executing $src"
    ./$src
done
