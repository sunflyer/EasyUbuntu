#!/bin/bash

#if you would like to use nginx as front-end proxy , set to 1, else please consider use TLS functions provided by V2Ray self.
#by default , we consider you are using nginx as proxy , and please consider adding TLS to nginx
USE_NGINX=1
#websocket path for request , this should be the same between client and server
# e.g.  "/" , "/test" , "/request/path"
#if you are using nginx as proxy , then the location of WS_PATH should be configured pass to your v2ray server.
# Nginx config example:
# location ~ ${WS_PATH} {
#		             proxy_pass http://${V2RAY_SERVER};
#                proxy_redirect off;
#                proxy_http_version 1.1;
#                proxy_set_header Upgrade $http_upgrade;
#                proxy_set_header Connection "upgrade";
#                proxy_set_header Host $http_host;
#	}
#

WS_PATH="/"
#alter id number
ALTER_ID="128"
# listen address
LISTEN="0.0.0.0"
# listen port
PORT="8080"

UPDATE=1
if [ $# -lt '1' ]; then
  UPDATE=0
fi


if [ ${USE_NGINX} -eq '1' ]; then
  LISTEN="127.0.0.1"
  PORT="18081"
fi


echo "=============== V2Ray Quick Installer ==============="
echo "==     Note : Will use TLS+WebSocket by default    =="

apt-get update && apt-get install curl -y && apt-get clean
UUID=`cat /proc/sys/kernel/random/uuid`

echo "Instanlling v2ray using script "
bash <(curl -L -s https://install.direct/go.sh)

if [ ${UPDATE} -eq '0' ]; then
  echo 'new config writing'
  mv /etc/v2ray/config.json /etc/v2ray/config.json.bak
  cat > /etc/v2ray/config.json << EOF
{
        "log":{
                "access":"/var/log/v2ray/access.log",
                "error":"/var/log/v2ray/error.log",
                "loglevel":"warning"
        },
        "inbounds":[
            {
                "port":${PORT},
                "protocol":"vmess",
                "listen":"${LISTEN}",
                "settings":{
                        "clients":[
                                {
                                        "id": "${UUID}",
                                        "alterId": ${ALTER_ID}
                                }
                        ]
                },
                "streamSettings":{
                        "network":"ws",
                        "wsSettings": {
                                "connectionReuse": true,
                                "path": "${WS_PATH}" 
                        }
                }
            }
        ],
        "outbounds":[
            {
                "protocol": "freedom",
                "settings": {}
            }
        ]
}
EOF
  service v2ray restart
  echo -e "V2ray installation complete \n\tYour uuid is [${UUID}] \n\talter id is [${ALTER_ID}]"
  echo -e "Server Listen on [${LISTEN}:${PORT}]"
  
else
  echo 'Update complete'
fi
