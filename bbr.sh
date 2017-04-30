#!/bin/bash
#ADDR=http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.9/linux-image-4.9.0-040900-generic_4.9.0-040900.201612111631_amd64.deb
#ADDR=http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.9.12/linux-image-4.9.12-040912-generic_4.9.12-040912.201702231232_amd64.deb
ADDR=http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.9.25/linux-image-4.9.25-040925-generic_4.9.25-040925.201704270431_amd64.deb
wget $ADDR -O linux-4.9.deb
dpkg -i linux-4.9.deb
rm linux-4.9.deb
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sysctl -p
reboot
