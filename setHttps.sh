#!/bin/bash

# This is a quick SSL Site setup script for nginx
# PHP-FPM is used by default with unix socket
# By CrazyChen @ https://sunflyer.cn
# Aug 17.2015

PHP_SOCK="unix:/run/php/php7.1-fpm.sock"
#PHP_SOCK="unix:/run/php/php5.6-fpm.sock"
WEB_DIR="/var/www"
HOST=""
PUBKEY=""
PRIVKEY=""
WEBPATH=""
SSL_PORT=443
if [ $# -lt '3' ]; then
	echo "Usage : setHttps.sh [host name] [pubkey path] [priv key path] [webroot] [port]"
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
        access_log /var/log/host/$HOST/access.log;
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
	ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
	ssl_prefer_server_ciphers on;
	ssl_ciphers  "EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5:!MEDIUM:!LOW";

	add_header Strict-Transport-Security "max-age=31536000";
	add_header X-XSS-Protection '1; mode=block';
	add_header X-Content-Type-Options 'nosniff';
	add_header X-Frame-Options 'SAMEORIGIN';
	
	ssl_session_cache shared:SSL:5m;
	ssl_session_timeout 5m;

	access_log /var/log/host/$HOST/access-ssl.log;
	error_log /var/log/host/$HOST/error-ssl.log;
	resolver 8.8.8.8;
	ssl_stapling on;
  	ssl_trusted_certificate $PUBKEY;
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
mkdir -p $WEBPATH
mkdir -p /var/log/host/$HOST
chown www-data:www-data -R $WEBPATH
chown www-data:www-data -R /var/log/host/
echo "#####################################"
echo "#####################################"
echo "Reloading service"
service nginx reload
echo "#####################################"
echo "Complete Adding Host : $HOST"
