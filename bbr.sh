#!/bin/bash

UPDATE=0
if [ $# -gt '0' ]; then
    echo "Go Kernel Update"
    UPDATE=1
fi

ADDR="http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.9.74/linux-image-4.9.74-040974-generic_4.9.74-040974.201801022030_amd64.deb"
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
