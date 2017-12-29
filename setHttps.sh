#!/bin/bash

# This is a quick SSL Site setup script for nginx
# PHP-FPM is used by default with unix socket
# By CrazyChen @ https://sunflyer.cn
# Aug 17.2015

ENABLE_TLS_13=0
LOG_FORMAT=""

PHP_SOCK="unix:/run/php/php7.1-fpm.sock"
#PHP_SOCK="unix:/run/php/php5.6-fpm.sock"
WEB_DIR="/var/www"
HOST=""
PUBKEY=""
PRIVKEY=""
WEBPATH=""
SSL_PORT=443
LE_WEB_NAME=".well-known"
LE_COMMON_PATH="/var/www/letsencrypt/"

if [ $# -lt '3' ]; then
	echo "Usage : setHttps.sh [host name] [pubkey path] [priv key path] [webroot] [port]"
	echo "Where : "
	echo -e "host name : host name of your website . e.g. www.qq.com"
	echo -e "pubkey path : absolute path for your ssl public cert file"
	echo -e "priv key path : absolute path for your ssl private key file"
	echo -e "webroot [optional] : where your website root should be , by default is [${WEB_DIR}/<host name>] , this should be given in absolute path"
	echo -e "port [optional] : ssl website server port , by default is ${SSL_PORT}"
	exit
else
	HOST=$1
	PUBKEY=$2
	PRIVKEY=$3
	if [ $# -gt '3' ]; then 
		WEBPATH=$4
	else
		WEBPATH="$WEB_DIR/$HOST"
	fi
	
	if [ $# -gt '4' ]; then
		SSL_PORT=$5
	fi
fi

TLS_VER="TLSv1 TLSv1.1 TLSv1.2"
TLS_CIPHER="EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5:!MEDIUM:!LOW"
TLS_CURV=""
if [ ${ENABLE_TLS_13} -eq '1' ]; then
	TLS_VER="${TLS_VER} TLSv1.3"
	TLS_CIPHER="TLS13-AES-128-GCM-SHA256:TLS13-AES-256-GCM-SHA384:TLS13-AES-128-CCM-SHA256:TLS13-AES-128-CCM-8-SHA256:EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES"
	TLS_CURV="ssl_ecdh_curve              X25519:P-256:P-384:P-224:P-521;"
fi

echo "#####################################"
echo "User Configuration is below"
echo "HOST NAME 	: $HOST"
echo "PUBLIC KEY 	: $PUBKEY"
echo "PRIVATE KEY	: $PRIVKEY"
echo "WEB ROOT		: $WEBPATH"
echo "SSL PORT		: $SSL_PORT"
echo "#####################################"

echo Now Start Configuration
echo "#####################################"
echo "Writing document SSL"
cat > /etc/nginx/conf.d/ssl-$HOST.conf  << EOF
server {
        listen 80;
        listen [::]:80;
        root $WEBPATH;
        index index.html index.htm;
        server_name $HOST;
        return 301 https://$HOST\$request_uri;
        access_log /var/log/host/$HOST/access.log ${LOG_FORMAT};
	error_log /var/log/host/$HOST/error.log;
        location / {
                try_files \$uri \$uri/ =404;
        }
}


server{
	server_name $HOST;
	root  $WEBPATH;
	index index.php index.html;
	server_tokens off;
	listen $SSL_PORT ssl http2;
	listen [::]:$SSL_PORT ssl http2;
	ssl on;
	ssl_certificate $PUBKEY;
	ssl_certificate_key $PRIVKEY;
	${TLS_CURV}
	ssl_protocols ${TLS_VER};
	ssl_prefer_server_ciphers on;
	#ssl_ciphers  "TLS13-AES-128-GCM-SHA256:TLS13-AES-256-GCM-SHA384:TLS13-AES-128-CCM-SHA256:TLS13-AES-128-CCM-8-SHA256:EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5:!MEDIUM:!LOW";
	ssl_ciphers "${TLS_CIPHER}";

	add_header Strict-Transport-Security "max-age=31536000";
	add_header X-XSS-Protection '1; mode=block';
	add_header X-Content-Type-Options 'nosniff';
	add_header X-Frame-Options 'SAMEORIGIN';
	
	ssl_session_cache shared:SSL:5m;
	ssl_session_timeout 5m;

	access_log /var/log/host/$HOST/access-ssl.log ${LOG_FORMAT};
	error_log /var/log/host/$HOST/error-ssl.log;
	resolver 8.8.8.8;
	ssl_stapling on;
  	ssl_trusted_certificate $PUBKEY;
	
	location ~ /${LE_WEB_NAME} {
		root ${LE_COMMON_PATH};
		try_files \$uri \$uri/ =404;
	}
	
	#avoid processing of calls to unexisting static files by yii
	location ~ \.(js|css|png|jpg|gif|swf|ico|pdf|mov|fla|zip|rar)$ {
		try_files \$uri =404;
	}
	
  	location ~ \.php$ {
	 	fastcgi_split_path_info ^(.+\.php)(/.+)$;
        	fastcgi_pass $PHP_SOCK;
        	fastcgi_index index.php;
        	include fastcgi_params;
        	fastcgi_param HTTPS on;
        	fastcgi_param  SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
	}

	location /{
        	if (!-e \$request_filename)  {
            		rewrite ^(.+)$ /index.php last;
          	}
        	try_files \$uri \$uri/ =404;
	}
}
EOF
echo "#####################################"
echo "#####################################"
echo "Make Directory and allocate permission"
if [ ! -d $WEBPATH ]; then
	mkdir -p $WEBPATH
fi
if [ ! -d "/var/log/host/$HOST" ]; then
	mkdir -p /var/log/host/$HOST
fi
if [ ! -d ${LE_COMMON_PATH} ]; then
	echo "Creating Let's encrypt common authentication path ${LE_COMMON_PATH}"
	mkdir -p ${LE_COMMON_PATH}
fi

chown www-data:www-data -R $WEBPATH
chown www-data:www-data -R /var/log/host/
echo "#####################################"
echo "#####################################"
echo "Reloading service"
service nginx reload
echo "#####################################"
echo "Complete Adding Host : $HOST"
