#!/bin/bash
echo "This is an OpenVPN Private Network Setting Tool"
echo "By CrazyChen @ Jan 2,2016"

VER="1.0.0.1"
DATE="20170102"
DIR="/etc/openvpn/clts"
SVRIP=""
PORT=1194
PROTOCOL="udp"

helpinf(){
        echo -e "Supported Usage : \nsetup.sh [OPERATION]\nWhere OPERATION coule be:\n"
         echo -e "\tinst : install server\n\tclt : generate client cert and conf\n\tversion : show version of this tools\n\tupdate : update this script"
}

genkey(){
        echo "Generating DH Param"
        openssl dhparam -out /etc/openvpn/dh2048.pem 2048
        echo "Operating"
        cd /etc/openvpn/easy-rsa
        . ./vars
        echo "Cleaning all"
        ./clean-all
        echo "Building ca cert"
        ./build-ca
        echo "Building Server cert"
        ./build-key-server server
        echo "Copy keys to openvpn dir"
        cp /etc/openvpn/easy-rsa/keys/{server.crt,server.key,ca.crt} /etc/openvpn
}

svrconf(){
        echo "Please tell me which port you would like to use ? "
        read PORT
        if [ $PORT -lt '0' ]; then
            PORT=1194
        fi
        echo "Please tell me which proto you would like to use ? (t for TCP and u for UDP , by default UDP is used) "
        PROTOCOL="udp"
        read PROTOCOL
        if [ x$PROTOCOL == 'xt' ]; then
            PROTOCOL='tcp'
        else
            PROTOCOL='udp'
        fi
        #write conf file
cat>/etc/openvpn/server.conf<<EOF
        port $PORT
        proto $PROTOCOL
        dev tun
        ca ca.crt
        cert server.crt
        key server.key 
        dh dh2048.pem
        server 192.168.240.0 255.255.244.0
        ifconfig-pool-persist ipp.txt
        client-to-client
        keepalive 10 120
        cipher AES-128-CBC
        comp-lzo
        user nobody
        group nogroup
        persist-key
        persist-tun
        status openvpn-status.log
        log         /var/log/openvpn.log
        verb 3
EOF
echo "Gen conf complete"
}

getLocalIp(){

}

gencltConf(){
        echo "Config name for client is $1"
        mkdir $DIR -p
        getLocalIp()
        
cat>$DIR/$1.ovpn<<EOF
        dev tun
        proto udp
        remote $SVRIP $PORT
        cipher AES-128-CBC
        auth SHA1
        resolv-retry infinite
nobind
persist-key
persist-tun
client
verb 3
#auth-user-pass pass.txt
comp-lzo
<ca>
</ca>
<cert>
</cert>
<key>
</key>
EOF
echo "Gen client complete"
}

genclt(){
        cd /etc/openvpn/easy-rsa
        echo "Client Cert : input a name for your client "
        read NAME
        ./build-key $NAME
        gencltConf $NAME
}

install(){
        echo "Install instruction detected , go installation"
        apt-get update && apt-get upgrade -y && apt-get install openvpn easy-rsa  -y --force-yes
        echo "Generating RSA Key , just press ENTER if asked by system"       
        cp -r /usr/share/easy-rsa/ /etc/openvpn
        mkdir /etc/openvpn/easy-rsa/keys
        genkey   
        echo "Configuring svr"
        svrconf
        echo "Config complete , restarting openvpn"
        service openvpn restart
        service openvpn status
}

if [ $# -eq '0' ]; then
        echo -e "Param Invalid !\n\n"
        helpinf
        exit
fi

FUNC=$1

case $FUNC in
        inst)
                install
                ;;
        clt)

                ;;
        version)

                ;;
        update)

                ;;
        *)
                helpinf
                ;;
esac
