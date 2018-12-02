#!/bin/bash
Version=1

#System Version
UBUNTU_SYS_VER=16
UBUNTU_SYS_NAME=""

#define ssh port to be changed
SSH_PORT=12345
SSH_KEY=""
SSH_KEY_ONLY=0
SSH_CONFIG="/etc/ssh/sshd_config"

#PHP Installation
PPA_PROXY=""
SESSION_NAME="__sessionflag"
PROC_NUM_MAX=10
PHP_VERSION="7.2"

#SWAP Config
SWAP_SIZE="1G"
SWAP_FILE="/opt/swapfile"

#BBR Config
KERNEL_FILE="http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.9.118/linux-image-4.9.118-0409118-generic_4.9.118-0409118.201808061531_amd64.deb"
KERNEL_FILE_SAVE="linux-image.deb"

#Motd Config
MOTD_IP_ADDR=""
MOTD_TEMPLATE="
=======================================================

=======================================================
		
=======================================================
"

#color config
COL_RED="\033[31m"
COL_GREEN="\033[32m"
COL_CYAN="\033[36m"
COL_WHITE="\033[37m"
COL_END="\033[0m"


#Begin Function area
err() {
	echo -e "${COL_RED}[ERROR] $1 ${COL_END}"
}

info() {
	echo -e "${COL_GREEN} [INFO] $1 ${COL_END}"
}

tips() {
	echo -e "${COL_CYAN} [INFO] $1 ${COL_END}"
}

checkVer() {
	if [ -f /etc/lsb-release ]; then
		UBUNTU_SYS_VER=`cat /etc/lsb-release | grep DISTRIB_RELEASE | cut -c 17-18`
		if [ ${UBUNTU_SYS_VER} -eq '14' ]; then
			UBUNTU_SYS_NAME="trusty"
		elif [ ${UBUNTU_SYS_VER} -eq '16' ]; then
			UBUNTU_SYS_NAME="xenial"
		elif [ ${UBUNTU_SYS_VER} -eq '18' ]; then
			UBUNTU_SYS_NAME="bionic"
		else
			err "Unable to determine system version : ${UBUNTU_SYS_VER}"
			err "Script supports only following version : Trusty ( 14.04 ) / Xenial ( 16.04 ) / Bionic ( 18.04 )"
			exit
		fi
	else
		err "你使用的似乎不是Ubuntu的发行版本，脚本无法支持"
		err "Seems You are not using the distro of Ubuntu , so script cannot support."
		exit
	fi
}

setIp() {
	MOTD_IP_ADDR=`curl myip.ipip.net | awk '{print $2}' | cut -c 6-`
	info "IP Address is [${MOTD_IP_ADDR}]"
}

initSsh() {
	sed -i 's/Port/#Port/g' ${SSH_CONFIG}
	sed -i 's/PermitRootLogin/#PermitRootLogin/g' ${SSH_CONFIG}
	
	echo "Port ${SSH_PORT}" >> ${SSH_CONFIG}
	echo "PermitRootLogin yes" >> ${SSH_CONFIG}
	
	enable_chap='yes'
	
	if [ ${SSH_KEY_ONLY} -eq '1' ]; then
		enable_chap='no'
	fi
	
	#use challenge authentication instead
	sed -i 's/PasswordAuthentication/#PasswordAuthentication/g' ${SSH_CONFIG}
	sed -i 's/ChallengeResponseAuthentication/#ChallengeResponseAuthentication/g' ${SSH_CONFIG}
	
	echo "ChallengeResponseAuthentication ${enable_chap}" >> ${SSH_CONFIG}
	echo "PasswordAuthentication no" >> ${SSH_CONFIG}
	
	if [ x"${SSH_KEY}" != "x" ]; then
		if [ ! -d "~/.ssh" ]; then
			mkdir ~/.ssh
			chmod 600 ~/.ssh
		fi
		echo ${SSH_KEY} > ~/.ssh/authorized_keys
		chmod 600 ~/.ssh/authorized_keys
	fi
	
	/etc/init.d/ssh restart
	info "SSH Init complete , Port changed to [${SSH_PORT}]"
}

initSwap() {
	fallocate -l ${SWAP_SIZE} ${SWAP_FILE}
	chmod 600 ${SWAP_FILE}
	mkswap ${SWAP_FILE}
	swapon ${SWAP_FILE}
	echo "${SWAP_FILE} none swap sw 0 0" | sudo tee -a /etc/fstab
	info "Swap file init complete with size [${SWAP_SIZE}] file[${SWAP_FILE}]"
}

initBBR() {
	info "BBR Installation Start"
	echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
	if [ ${UBUNTU_SYS_VER} -lt '18' ]; then
		curl -L ${KERNEL_FILE} -o ${KERNEL_FILE_SAVE}
		dpkg -i ${KERNEL_FILE_SAVE}
		info "System need a reboot to switch kernel , Please reboot later manually"
	else
		sysctl -p
		info "BBR Initialized"
	fi
}

installNginx() {
	info "Nginx installation Begin"
	curl -L http://nginx.org/keys/nginx_signing.key -o nginx.key && apt-key add nginx.key && rm nginx.key
	echo "deb http://nginx.org/packages/ubuntu/ $UBUNTU_SYS_NAME nginx" > /etc/apt/sources.list.d/nginx-official.list
	echo "deb-src http://nginx.org/packages/ubuntu/ $UBUNTU_SYS_NAME nginx" >> /etc/apt/sources.list.d/nginx-official.list
	apt update
	apt install nginx -y
	apt-get clean
	
	info "Import config file"
	mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
	cat >> /etc/nginx/nginx.conf << EOF
user  nginx;
worker_processes  auto;
error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;
events {
    worker_connections  1024;
}
http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    log_format cnlog '\$time_local|\$remote_addr|\$http_x_forwarded_for|\$http_x_real_ip|\$remote_user|\$status|\$request|\$body_bytes_sent|\$http_referer|\$http_user_agent';
    access_log  /var/log/nginx/access.log  cnlog;
    sendfile        on;
    keepalive_timeout  65;
    client_max_body_size 100m;
    server_tokens off;
    include /etc/nginx/conf.d/*.conf;
    gzip on;
    gzip_vary on;
    gzip_comp_level 6;
    gzip_buffers 16 8k;
    gzip_http_version 1.1;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
}
EOF

	info "Configure user group"
	usermod -a -G www-data nginx

	info "Downloading Script to config https site"
	curl -OL https://raw.githubusercontent.com/sunflyer/EasyUbuntu/master/setHttps.sh
	
	info "Downloading Proxy Script to config proxy site"
	curl -OL https://github.com/sunflyer/EasyUbuntu/raw/master/nginx-proxy.sh
	
	chmod +x *.sh
	
	/etc/init.d/nginx restart
	info "Installation complete"
	
	mkdir ~/cron/
	curl -L https://github.com/sunflyer/EasyUbuntu/raw/master/cron-nginx-log.sh -o /root/cron/nginx.sh

	chmod +x /root/cron/nginx.sh
	(crontab -l ; echo "00 00 * * * /bin/bash /root/cron/nginx.sh") | crontab
#echo "00 00 * * * /bin/bash /root/cron/nginx.sh" >> /var/spool/cron/root
}

installPhp() {
	info "Begin PHP Installation , version [${PHP_VERSION}]"
	PHP_PREFIX="php${PHP_VERSION}"
	
	apt-get update
	apt-get install software-properties-common -y --force-yes 
	add-apt-repository ppa:ondrej/php -y
	
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C
	
	apt update
	
	apt-get install ${PHP_PREFIX} ${PHP_PREFIX}-fpm ${PHP_PREFIX}-common ${PHP_PREFIX}-curl ${PHP_PREFIX}-gd ${PHP_PREFIX}-xml ${PHP_PREFIX}-bz2 ${PHP_PREFIX}-bcmath ${PHP_PREFIX}-ldap ${PHP_PREFIX}-sqlite3 ${PHP_PREFIX}-cli ${PHP_PREFIX}-mbstring ${PHP_PREFIX}-mysql ${PHP_PREFIX}-redis ${PHP_PREFIX}-zip -y --force-yes
	
	#replace config file
	local conf_php="/etc/php/${PHP_VERSION}/fpm/php.ini"
	local conf_pool="/etc/php/${PHP_VERSION}/fpm/pool.d/www.conf"
	
	tips "Modifying Config file , SessionName[${SESSION_NAME}]"
	
	sed -i 's/;opcache/opcache/g' ${conf_php}
	sed -i 's/session.name/;session.name/g' ${conf_php}
	echo "session.name = ${SESSION_NAME}" >> ${conf_php}
	
	sed -i 's/pm.max_children/;pm.max_children/g' ${conf_pool}
	sed -i 's/pm.start_servers/;pm.start_servers/g' ${conf_pool}
	sed -i 's/pm.max_spare_servers/;pm.max_spare_servers/g' ${conf_pool}
	sed -i 's/pm.max_requests/;pm.max_requests/g' ${conf_pool}
	
	echo "pm.max_children = ${PROC_NUM_MAX}" >> ${conf_pool}
	echo "pm.start_servers = $(( ${PROC_NUM_MAX} / 2 ))" >> ${conf_pool}
	echo "pm.max_spare_servers = $(( ${PROC_NUM_MAX} / 2 ))" >> ${conf_pool}
	echo "pm.max_requests = 2000" >> ${conf_pool}
	
	/etc/init.d/php${PHP_VERSION}-fpm restart
	
	info "Installation Complete"
}

prep() {
	info "Perparing tools needed"
	apt update
	apt install htop iftop dnsutils traceroute mtr curl python python-pip -y && apt-get clean
}

helpinf() {
	echo -e "
Ubuntu Server 一键初始化工具
使用方式: $0 [...args]
参数列表：
	-h 显示此帮助消息
	-p [Version] 设置PHP版本，0表示不安装PHP
	-n 不安装Nginx
	-s [Port] 修改SSH Port，当前默认端口为[${SSH_PORT}]
	-k [Key] 修改SSH Key并只允许ssh key登陆（禁用密码登陆） , 当key为空时此选项无效，默认SSH PubKey [${SSH_KEY}]
	-b 禁止BBR安装
	-w [Size] 修改Swap空间大小，0表示禁用
	";
	exit
}


info "Checking argument"
INSTALL_NGINX=1
INSTALL_PHP=1
INSTALL_BBR=1
INSTALL_SWAP=1
INSTALL_SSH=1

while getopts "hp:ns:bw:k:i:" arg
do
	case $arg in
		h)
			helpinf
			exit
		;;
		p)
			info "PHP Config found: ${OPTARG}"
			if [ x"${OPTARG}" = "x0" ]; then
				tips "PHP Installation Disabled"
				INSTALL_PHP=0
			else
				INSTALL_PHP=1
				PHP_VERSION=${OPTARG}
				PHP_PREFIX="php${PHP_VERSION}"
			fi
		;;
		n)
			tips "Nginx Installation Disabled"
			INSTALL_NGINX=0
		;;
		s)
			if [ x"${OPTARG}" = "x0" ]; then
				tips "SSH Config Disabled"
				INSTALL_SSH=0
			else
				info "SSH Port Changed to [${OPTARG}]"
				SSH_PORT=${OPTARG}
			fi
		;;
		b)
			tips "BBR Installation Disabled"
			INSTALL_BBR=0
		;;
		w)
			if [ x"${OPTARG}" = "x0" ]; then
				tips "SWAP Disabled"
				INSTALL_SWAP=0
			else 
				info "Swap size changed to [${OPTARG}]"
				SWAP_SIZE=${OPTARG}
			fi
		;;
		k)
			local key=${OPTARG}
			if [ x${key} = "x" ]; then
				err "SSH Key Given is empty"
			fi
			
			if [ x${SSH_KEY} = "x" ]; then
				err "Unable to set key login only because you provided no valid ssh key."
			else
				tips "Key login only has been set."
				SSH_KEY_ONLY=1
			fi
			;;
		?)
			err "Unknown option : $arg"
		;;
	esac
done

checkVer
prep
setIp

if [ ${INSTALL_NGINX} -eq '1' ]; then
	installNginx
fi

if [ ${INSTALL_BBR} -eq '1' ]; then
	initBBR
fi

if [ ${INSTALL_SSH} -eq '1' ]; then
	initSsh
fi

if [ ${INSTALL_PHP} -eq '1' ]; then
	installPhp
fi

if [ ${INSTALL_SWAP} -eq '1' ]; then
	initSwap
fi

