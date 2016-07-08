#!/bin/bash

mkdir /opt/nginx
cd /opt/nginx
wget http://nginx.org/download/nginx-1.10.1.tar.gz -O nginx.tar.gz
wget http://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-2.4.1.tar.gz -O libressl.tar.gz

echo "Decompressing LibreSSL"

tar zxf libressl.tar.gz
cd libressl*

./configure --prefix=/usr LDFLAGS=-lrt
make

mkdir -p .openssl/lib
cp crypto/.libs/libcrypto.a ssl/.libs/libssl.a .openssl/lib
cd .openssl && ln -s ../include ./
cd lib && strip -g libssl.a && strip -g libcrypto.a
cd ../../../

echo "Preparing required libs for compiling nginx"

apt-get update
apt-get install libxslt1-dev libxml2-dev zlib1g-dev libpcre3-dev libgd-dev -y --force-yes


echo "Configuring Nginx Complies"
tar zxf nginx.tar.gz 

cd nginx*
./configure --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --user=nginx --group=nginx --with-http_ssl_module --with-http_realip_module --with-http_addition_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_stub_status_module --with-http_auth_request_module --with-http_xslt_module=dynamic --with-http_image_filter_module=dynamic --with-threads --with-stream --with-stream_ssl_module --with-http_slice_module --with-mail --with-mail_ssl_module --with-file-aio --with-ipv6 --with-http_v2_module --with-cc-opt='-g -O2 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2' --with-ld-opt='-Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,--as-needed' --with-openssl=/opt/nginx/libressl-2.4.1 --with-ld-opt="-lrt" --with-stream

touch /opt/nginx/libressl-2.4.1/.openssl/include/openssl/ssl.h

make
make install

sudo ln -s /usr/local/nginx/sbin/nginx /usr/bin/nginx

wget https://raw.githubusercontent.com/sunflyer/EasyUbuntu/master/nginx.init -O /etc/init.d/nginx

sudo chmod +x /etc/init.d/nginx #安装启动脚本

sudo update-rc.d -f nginx defaults #设置开机自启动
