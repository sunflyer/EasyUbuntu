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
./configure --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --user=nginx --group=nginx --with-http_ssl_module --with-http_realip_module --with-http_addition_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_stub_status_module --with-http_auth_request_module --with-http_xslt_module=dynamic --with-http_image_filter_module=dynamic --with-threads --with-stream --with-stream_ssl_module --with-http_slice_module --with-mail --with-mail_ssl_module --with-file-aio --with-ipv6 --with-http_v2_module --with-cc-opt='-g -O2 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2' --with-ld-opt='-Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,--as-needed' --with-openssl=/opt/nginx/libressl-2.4.1 --with-ld-opt="-lrt"

touch /opt/nginx/libressl-2.4.1/.openssl/include/openssl/ssl.h

make
make install

sudo ln -s /usr/local/nginx/sbin/nginx /usr/bin/nginx

cat > /etc/init.d/nginx << EOF
#!/bin/sh
### BEGIN INIT INFO
# Provides:          nginx
# Required-Start:    \$network \$remote_fs \$local_fs
# Required-Stop:     \$network \$remote_fs \$local_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Stop/start nginx
### END INIT INFO

# Author: Sergey Budnevitch <sb@nginx.com>

PATH=/sbin:/usr/sbin:/bin:/usr/bin

if [ -L \$0 ]; then
    SCRIPTNAME=\`/bin/readlink -f \$0\`
else
    SCRIPTNAME=\$0
fi

sysconfig=\`/usr/bin/basename \$SCRIPTNAME\`

[ -r /etc/default/\$sysconfig ] && . /etc/default/\$sysconfig

DESC=\${DESC-nginx}
NAME=\${NAME-nginx}
CONFFILE=\${CONFFILE-/etc/nginx/nginx.conf}
DAEMON=\${DAEMON-/usr/sbin/nginx}
PIDFILE=\${PIDFILE-/var/run/nginx.pid}
SLEEPSEC=1
UPGRADEWAITLOOPS=5

[ -x \$DAEMON ] || exit 0

DAEMON_ARGS="-c \$CONFFILE \$DAEMON_ARGS"

. /lib/init/vars.sh

. /lib/lsb/init-functions

do_start()
{
    start-stop-daemon --start --quiet --pidfile \$PIDFILE --exec \$DAEMON -- \
        \$DAEMON_ARGS
    RETVAL="\$?"
    return "\$RETVAL"
}

do_stop()
{
    # Return
    #   0 if daemon has been stopped
    #   1 if daemon was already stopped
    #   2 if daemon could not be stopped
    #   other if a failure occurred
    start-stop-daemon --stop --quiet --oknodo --retry=TERM/30/KILL/5 --pidfile \$PIDFILE
    RETVAL="\$?"
    rm -f \$PIDFILE
    return "\$RETVAL"
}

do_reload() {
    #
    start-stop-daemon --stop --signal HUP --quiet --pidfile \$PIDFILE
    RETVAL="\$?"
    return "\$RETVAL"
}

do_configtest() {
    if [ "\$#" -ne 0 ]; then
        case "\$1" in
            -q)
                FLAG=\$1
                ;;
            *)
                ;;
        esac
        shift
    fi
    \$DAEMON -t \$FLAG -c \$CONFFILE
    RETVAL="\$?"
    return \$RETVAL
}

do_upgrade() {
    OLDBINPIDFILE=\$PIDFILE.oldbin

    do_configtest -q || return 6
    start-stop-daemon --stop --signal USR2 --quiet --pidfile \$PIDFILE
    RETVAL="\$?"

    for i in \`/usr/bin/seq  \$UPGRADEWAITLOOPS\`; do
        sleep \$SLEEPSEC
        if [ -f \$OLDBINPIDFILE -a -f \$PIDFILE ]; then
            start-stop-daemon --stop --signal QUIT --quiet --pidfile \$OLDBINPIDFILE
            RETVAL="\$?"
            return
        fi
    done

    echo \$"Upgrade failed!"
    RETVAL=1
    return \$RETVAL
}

case "\$1" in
    start)
        [ "\$VERBOSE" != no ] && log_daemon_msg "Starting \$DESC " "\$NAME"
        do_start
        case "\$?" in
            0|1) [ "\$VERBOSE" != no ] && log_end_msg 0 ;;
            2) [ "\$VERBOSE" != no ] && log_end_msg 1 ;;
        esac
        ;;
    stop)
        [ "\$VERBOSE" != no ] && log_daemon_msg "Stopping \$DESC" "\$NAME"
        do_stop
        case "\$?" in
            0|1) [ "\$VERBOSE" != no ] && log_end_msg 0 ;;
            2) [ "\$VERBOSE" != no ] && log_end_msg 1 ;;
        esac
        ;;
  status)
        status_of_proc -p "\$PIDFILE" "\$DAEMON" "\$NAME" && exit 0 || exit \$?
        ;;
  configtest)
        do_configtest
        ;;
  upgrade)
        do_upgrade
        ;;
  reload|force-reload)
        log_daemon_msg "Reloading \$DESC" "\$NAME"
        do_reload
        log_end_msg \$?
        ;;
  restart|force-reload)
        log_daemon_msg "Restarting \$DESC" "\$NAME"
        do_configtest -q || exit \$RETVAL
        do_stop
        case "\$?" in
            0|1)
                do_start
                case "\$?" in
                    0) log_end_msg 0 ;;
                    1) log_end_msg 1 ;; # Old process is still running
                    *) log_end_msg 1 ;; # Failed to start
                esac
                ;;
            *)
                # Failed to stop
                log_end_msg 1
                ;;
        esac
        ;;
    *)
        echo "Usage: \$SCRIPTNAME {start|stop|status|restart|reload|force-reload|upgrade|configtest}" >&2
        exit 3
        ;;
esac

exit \$RETVAL


EOF

sudo chmod +x /etc/init.d/nginx #安装启动脚本

sudo update-rc.d -f nginx defaults #设置开机自启动
