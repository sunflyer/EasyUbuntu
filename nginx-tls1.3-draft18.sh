#!/bin/bash
//
// seems there is some problem when using chrome to access the website which deployed with TLS1.3 draft 18 
// this script is designed for testing in your prerelease or testing environment , do not use it in production
//
// TLS 1.3 Cipher suite : TLS13-AES-128-GCM-SHA256:TLS13-AES-256-GCM-SHA384:TLS13-AES-128-CCM-SHA256:TLS13-AES-128-CCM-8-SHA256 (of course more available , this list is just for example )
// 


NGINXVER=1.13.7
OPENSSLDIR="openssl-1.1.1-tls1.3-draft-18"

apt install git -y

mkdir /opt/nginx
cd /opt/nginx
wget http://nginx.org/download/nginx-$NGINXVER.tar.gz -O nginx.tar.gz

echo "Decompressing LibreSSL"

#tar zxf libressl.tar.gz
#cd libressl*
git clone https://github.com/openssl/openssl.git -b tls1.3-draft-18 --single-branch ${OPENSSLDIR}
#cd openssl-1.1.1-tls1.3-draft-18



echo "Preparing required libs for compiling nginx"

apt-get update
apt-get install build-essential libxslt1-dev libxml2-dev zlib1g-dev libpcre3-dev libgd-dev -y --force-yes


echo "Configuring Nginx Complies"
tar zxf nginx.tar.gz 

cd nginx*
./configure --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --user=nginx --group=nginx --with-http_ssl_module --with-http_realip_module --with-http_addition_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_stub_status_module --with-http_auth_request_module --with-http_xslt_module=dynamic --with-http_image_filter_module=dynamic --with-threads --with-stream --with-stream_ssl_module --with-http_slice_module --with-mail --with-mail_ssl_module --with-file-aio --with-ipv6 --with-http_v2_module --with-cc-opt='-g -O2 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2' --with-ld-opt='-Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,--as-needed' --with-openssl=/opt/nginx/${OPENSSLDIR} --with-openssl-opt=enable-tls1_3 --with-stream --with-http_dav_module

make -j8
make install
