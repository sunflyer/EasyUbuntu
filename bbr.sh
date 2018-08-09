#!/bin/bash

UPDATE=0
if [ $# -gt '0' ]; then
    echo "Go Kernel Update"
    UPDATE=1
fi

#ADDR="http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.9.75/linux-image-4.9.75-040975-generic_4.9.75-040975.201801051530_amd64.deb"
#ADDR="http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.9.87/linux-image-4.9.87-040987-generic_4.9.87-040987.201803111631_amd64.deb"
ADDR="http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.9.118/linux-image-4.9.118-0409118-generic_4.9.118-0409118.201808061531_amd64.deb"
wget "${ADDR}" -O linux-4.9.deb
#wget "${ADDR_HEADER_H}" -O linux-header-4.9-h.deb
#wget "${ADDR_HEADER}" -O linux-header-4.9.deb
dpkg -i linux-4.9.deb
#dpkg -i linux-header-4.9-h.deb
#dpkg -i linux-header-4.9.deb
rm linux-4.9.deb
#rm linux-header-4.9.deb
#rm linux-header-4.9-h.deb

if [ ${UPDATE} -eq '0' ]; then
    echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
    sysctl -p
fi
reboot
