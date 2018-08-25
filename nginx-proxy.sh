#!/bin/bash

DOMAIN=""
SSL_CERT=""
SSL_KEY=""
UPSTREAM_SVR=""
UPSTREAM_SCHEME="http"
CACHE_PATH="/var/cache/website/"
NGINX_CONF_PATH="/etc/nginx/conf.d/"
PROXY_FILE="proxy"
XDOMAIN=""
CACHE_SIZE="100m"
INACTIVE="30m"
MAX_SIZE="100m"
LOG_PATH="/var/log/host/"
LOG_FORMAT=""
HSTS_HEADER=""
HSTS_FORCE=""
CHOWN="www-data:www-data"

HSTS_RAW="
	add_header Strict-Transport-Security \"max-age=31536000\";
	add_header X-XSS-Protection '1; mode=block';
	add_header X-Content-Type-Options 'nosniff';
	add_header X-Frame-Options 'SAMEORIGIN';
"

HSTS_FORCE_RAW="
	if (\$scheme = http) {
 	       return 301 https://\$host\$request_uri;
	}
"

if [ $# -lt 2 ]; then
	echo "Simple script to generate proxy script for nginx"
	echo "Usage: $0 [options]"
	echo "Where options can be :"
	echo -e "\t -d [domain]\t:\tdomain for access (required)"
	echo -e "\t -u [upstream:port]\t:\tUpstream server address ( domain or ip address ) (required)"
	echo -e "\t -c [cert file path]\t:\tCertificate file path if using SSL (required)"
	echo -e "\t -k [key file path]\t:\tSSL Key file (required)"
	echo -e "\t -s \t:\t using HTTPS as scheme when proxy to upstream "
	echo -e "\t -p [port]\t:\t listen port (optional)"
	echo -e "\t -n [path]\t:\t nginx conf file path for storing config file"
	echo -e "\t -h \t:\t allow HSTS and protection header in cdn site , this will also force redirect all http request to https by return 301"
	echo -e "\t -m [size] \t:\t set max cache size ( i.e.  50m , 100m , 1g) , default is ${MAX_SIZE}"
	echo -e "\t -i [time] \t:\t inactive time for cache ,default is ${INACTIVE}"
	echo -e "\t -l [log path] \t:\t log file path , default is ${LOG_PATH}"
	exit
fi

echo "[INFO] parsing args"
while getopts "d:u:c:k:sp:n:hm:i:l:" arg
do
	case $arg in
		d)
			echo -e "\t found domain : ${OPTARG}"
			DOMAIN="${DOMAIN} ${OPTARG}"
			if [ ${PROXY_FILE} = "proxy" ]; then
				XDOMAIN=${OPTARG}
				PROXY_FILE="proxy_${OPTARG}.conf"
				echo -e "\t [INFO] proxy file will be write to [${PROXY_FILE}]"
			fi
		;;
		u)
			echo -e "\t found upstream : ${OPTARG}"
			UPSTREAM_SVR="server ${OPTARG}; ${UPSTREAM_SVR}"
		;;
		c)
			if [ -f ${OPTARG} ]; then
				echo -e "\t found SSL Certificate file : ${OPTARG}"
				SSL_CERT=${OPTARG}
			else
				echo -e "\t [WARN] ssl certificate file applied but file not found : ${OPTARG}"
			fi
		;;
		k)
			if [ -f ${OPTARG} ]; then
				echo -e "\t found SSL Certificate key : ${OPTARG}"
				SSL_KEY=${OPTARG}
			else
				echo -e "\t [WARN] ssl certificate key applied but file not found : ${OPTARG}"
			fi
		;;
		s)
			echo -e "\t Using HTTPS as upstream scheme to origin site"
			UPSTREAM_SCHEME="https"
		;;
		h)
			HSTS=${HSTS_RAW}
			HSTS_FORCE=${HSTS_FORCE_RAW}
			echo -e "\t HSTS Header and protection header added"
		;;
		m)
			MAX_SIZE=${OPTARG}
			echo -e "\t max cache size has been set to [${OPTARG}]"
		;;
		i)
			INACTIVE=${OPTARG}
			echo -e "\t inactive time has been set to [${OPTARG}]"
		;;
		l)
			if [ -d ${OPTARG} ]; then
				LOG_PATH=${OPTARG}
				echo -e "\t log path has been set to [${OPTARG}]"
			fi
		;;	
		n)
			if [ -d ${OPTARG} ]; then
				echo -e "\t found nginx conf file path [${OPTARG}]"
				NGINX_CONF_PATH=${OPTARG}
			fi
		;;
		?)
		;;
	esac
done

if [ "x" = "x${DOMAIN}" ]  || [ "x${UPSTREAM_SVR}" = "x" ]; then
	echo "[FATAL] sorry , domain or upstream server can not be empty as proxy. "
	exit
fi

TIME=`date +%Y%m%d%H%M%S`
UPSTREAM_NAME="ssmiler_upstream_${TIME}"
CACHE_DIR_NAME="cd_${XDOMAIN}"
REAL_LOG_DIR="${LOG_PATH}/${XDOMAIN}"

echo -e "[INFO] generating config for ${DOMAIN} with upstream ${UPSTREAM_SVR} in file ${PROXY_FILE}"
cat >  ${PROXY_FILE} << EOF
proxy_cache_path $CACHE_PATH/${CACHE_DIR_NAME} levels=1:2 keys_zone=${UPSTREAM_NAME}:${CACHE_SIZE} inactive=${INACTIVE} max_size=${MAX_SIZE};

upstream ${UPSTREAM_NAME} {
	keepalive 30;
	${UPSTREAM_SVR}
}

server {
	listen 80;
	listen [::]:80;

	listen 443  ssl http2;
	listen [::]:443  ssl http2;

	server_name ${DOMAIN};
	server_tokens off;

	client_max_body_size 500m;

	ssl_certificate_key ${SSL_KEY};
	ssl_certificate ${SSL_CERT};

	ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
	ssl_prefer_server_ciphers on;	
	ssl_session_cache shared:SSL:5m;
	ssl_session_timeout 5m;
	ssl_ciphers "EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5:!MEDIUM:!LOW";
	resolver 8.8.8.8 8.8.4.4;
	ssl_stapling on;
  	ssl_trusted_certificate ${SSL_CERT};

	${HSTS}
	add_header X-Cache-Status \$upstream_cache_status;

	access_log ${REAL_LOG_DIR}/http-access.log ${LOG_FORMAT};
	error_log ${REAL_LOG_DIR}/http-error.log;

	${HSTS_FORCE_RAW}

	location ~ /.well-known {
		root /var/www/letsencrypt/;
		try_files $uri $uri/ =404;
	}

	location ~ /ssmiler/cdn {
		return 403;
	}

	location / {
		proxy_pass ${UPSTREAM_SCHEME}://${UPSTREAM_NAME};
		proxy_http_version 1.1;
		set \$addr \$remote_addr;
		if ( \$http_cf_ray != "" ) {
			set \$addr \$http_x_forwarded_for;
		} 
		proxy_set_header X-Forwarded-For \$addr;
		proxy_set_header Connection '';
		proxy_redirect off;
	        proxy_set_header X-Real-IP \$remote_addr;
		
		location ~ \.(js|css|png|jpg|gif|swf|ico|pdf|mov|fla|zip|rar|doc|docx|xls|xlsx|ppt|pptx|exe|7z|gz|tar|tgz|mp3|mp4|avi|flac) {
			proxy_cache ${UPSTREAM_NAME};
			proxy_cache_valid  200 304  30m;
			proxy_cache_valid  301 24h;
			proxy_cache_valid  500 502 503 504 0s;
			proxy_cache_valid any 0s;
			expires 12h;
		}

	}
}

EOF

echo "[INFO] config generation complete"
echo "[INFO] now creating directory"
[ ! -d ${REAL_LOG_DIR} ] && mkdir -p ${REAL_LOG_DIR} && chown -R ${CHOWN} ${REAL_LOG_DIR}
[ ! -d $CACHE_PATH/${CACHE_DIR_NAME} ] && mkdir -p $CACHE_PATH/${CACHE_DIR_NAME} && chown -R ${CHOWN} $CACHE_PATH/${CACHE_DIR_NAME}
echo "[INFO] copy file to nginx conf directory [${NGINX_CONF_PATH}]"
cp ${PROXY_FILE} ${NGINX_CONF_PATH}
echo "[INFO] testing if config is available"
nginx -t
echo "[INFO] done."
