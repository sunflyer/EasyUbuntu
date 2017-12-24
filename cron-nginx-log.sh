#!/bin/bash 
#
# This script used to compress nginx log file every day 
#  
# 
# How to use :
#   1. add the sub-directory name which for storaging log files to "LOG_CONFIG"
#
#   2. crontab add : 00 00 * * * /bin/bash /root/cron/cron-nginx-log.sh
#   3. then script will run in 00:00 every day
#

CF_NAME="log.tar.gz"
NGINX_PID="/var/run/nginx.pid"
LOG_CONFIG="/root/cron/log.config"
LOGDIR_ROOTPATH="/var/log/host/"

for x in `cat ${LOG_CONFIG}`
do
	logspath="${LOGDIR_ROOTPATH}${x}/"
	yesterday=`date -d '-1 day' +%Y%m%d`
	historypath="${logspath}history/${yesterday}/"
#if [ ! -d $hostorypath ]; then
	mkdir -p $historypath
#fi
	mv ${logspath}*.log ${historypath}
	tar zcf ${historypath}${CF_NAME} ${historypath}*.log --remove-files
done
kill -USR1 `cat ${NGINX_PID}`
