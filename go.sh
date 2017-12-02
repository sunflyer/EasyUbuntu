#!/bin/bash

CONFIG_FILE="/root/go/config.data"
#
#   Config file content format :
#   <svr name>   <ip addr/domain>    <ssh port>     <username>
#
#   e.g
#   test-svr  192.168.1.1  22  root
#

showlist(){
        echo -e "\tServer Name\tServer Addr\n\t==========================="
        cat ${CONFIG_FILE} | grep -v "#" | awk '{printf("\t%s\t\t%s\n" ,$1,$2)}'
}

if [ $# -eq '0' ]; then
        echo "Usage : go.sh [name]"
        echo -e "\tServer List in [$CONFIG_FILE]: "
        showlist
        exit
fi

NAME=$1
echo "Now going $NAME"

CONFIG=$(cat ${CONFIG_FILE} | grep -v "#" | grep $NAME)

if [ -z "$CONFIG" ]; then
        echo "No Config for $NAME FOUND , check config"
        exit
fi

HOST=$(echo $CONFIG | awk '{print $2}')
PORT=$(echo $CONFIG | awk '{print $3}')
USER=$(echo $CONFIG | awk '{print $4}')

echo "Trying to login [$NAME] (${USER}@${HOST}:${PORT})"
ssh ${USER}@${HOST} -p ${PORT}
