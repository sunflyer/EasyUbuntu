#!/bin/bash
curl -sSL http://update.aegis.aliyun.com/download/quartz_uninstall.sh | sudo bash
sudo rm -rf /usr/local/aegis
sudo rm /usr/sbin/aliyun-service
sudo rm /lib/systemd/system/aliyun.service
