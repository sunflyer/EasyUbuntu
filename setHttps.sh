#!/bin/bash
echo -n "Please input a host name :"
read HOST
if [ -z $HOST ]; then
        echo "Host Invalid"
        exit 8
fi

echo -e "Host Name : $HOST\n"
echo -n "Please choose the web-page path (Default : /var/www/$HOST) : "
read WEBPATH
if [ -z $WEBPATH ]; then
        WEBPATH=/var/www/$HOST
else
        WEBPATH=/var/www/$WEBPATH
fi
echo -e "Path : $WEBPATH\n"
echo -n "Where is public key file ? "
read PUBKEY
if [ -z $PUBKEY ]; then
	if [  ! -f $PUBKEY ]; then
        echo "Pubkey not found"
        exit 8
	fi
fi
echo -e "Pubkey : $PUBKEY\n"

echo -n "Where is private key ? "
read PRIVKEY
if [ -z $PRIVKEY ];  then
	if [  ! -f  $PRIVKEY ]; then
        echo "Private key  not found"
        exit 8
	fi
fi

echo -e "Private key : $PRIVKEY\n"

echo Now Start Configuration
echo "#####################################"
echo "Writing document SSL"
cat > /etc/nginx/sites-enabled/ssl-$HOST  << EOF
server{
server_name $HOST;
root  $WEBPATH;
index index.php index.html;
server_tokens off;
listen 443  ssl spdy;
ssl on;
ssl_certificate $PUBKEY;
ssl_certificate_key $PRIVKEY;
ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
ssl_prefer_server_ciphers on;
ssl_ciphers "EECDH+ECDSA+AESGCM EECDH+aRSA+AESGCM EECDH+ECDSA+SHA384 EECDH+ECDSA+SHA256 EECDH+aRSA+SHA384 EECDH+aRSA+SHA256 ECDHE-RSA-AES256-SHA ECDHE-RSA-AES128-SHA !RC4 !LOW !aNULL !eNULL !LOW !3DES !MD5 !EXP !PSK !SRP !DSS !MEDIUM";

add_header Strict-Transport-Security "max-age=31536000";
add_header X-XSS-Protection '1; mode=block';
add_header X-Content-Type-Options 'nosniff';
add_header X-Frame-Options 'SAMEORIGIN';

## Use a SSL/TLS cache for SSL session resume.
ssl_session_cache shared:SSL:5m;
ssl_session_timeout 5m;
#ssl_session_tickets off;

access_log /var/log/host/$HOST/access.log;
error_log /var/log/host/$HOST/error.log;
resolver 8.8.8.8;
  ssl_stapling on;
  ssl_trusted_certificate $PUBKEY;
  location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
#       # NOTE: You should have "cgi.fix_pathinfo = 0;" in php.ini}
#
#       # With php5-cgi alone:
#       fastcgi_pass 127.0.0.1:9000;
#       # With php5-fpm:
        fastcgi_pass unix:/var/run/php5-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param HTTPS on;
        fastcgi_param  SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
}

location /{
         if (!-e \$request_filename)  {
            rewrite ^(.+)\ /index.php last;
          }
        try_files \$uri \$uri/ =404;
}

}
EOF
echo "#####################################"
echo "#####################################"
echo "Writing Document Jump"
cat > /etc/nginx/sites-enabled/def-$HOST << EOF
server {
        listen 80;
        listen [::]:80;
        root $WEBPATH;
        index index.html index.htm;
        server_name $HOST;
        return 301 https://$HOST;
        location / {
                try_files \$uri \$uri/ =404;
        }
}
EOF
echo "#####################################"
echo "#####################################"
echo "Make Directory and allocate permission"
mkdir /var/www/$HOST
mkdir /var/log/host/$HOST
chown www-data -R /var/www
chown www-data -R /var/log/host
echo "#####################################"
echo "#####################################"
echo "Reloading service"
service nginx load
echo "#####################################"
echo "Complete Adding Host : $HOST"
