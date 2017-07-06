#!/bin/bash

UPDATE=0
if [ $# -gt '0' ]; then
    echo "Go Kernel Update"
    UPDATE=1
fi

ADDR=http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.9.36/linux-image-4.9.36-040936-generic_4.9.36-040936.201707050932_amd64.deb
ADDR_HEADER=http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.9.36/linux-headers-4.9.36-040936-generic_4.9.36-040936.201707050932_amd64.deb
ADDR_HEADER_H=http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.9.36/linux-headers-4.9.36-040936_4.9.36-040936.201707050932_all.deb
wget "${ADDR}" -O linux-4.9.deb
wget "${ADDR_HEADER_H}" -O linux-header-4.9-h.deb
wget "${ADDR_HEADER}" -O linux-header-4.9.deb
dpkg -i linux-4.9.deb
dpkg -i linux-header-4.9-h.deb
dpkg -i linux-header-4.9.deb
rm linux-4.9.deb
rm linux-header-4.9.deb
rm linux-header-4.9-h.deb

if [ ${UPDATE} -eq '1' ]; then
    echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
    sysctl -p
fi
reboot
