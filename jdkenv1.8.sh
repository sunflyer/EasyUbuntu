#!/bin/bash
TIME=$(date +%s)
TIME="$TIME"123
FILENAME="jdk-8u131-linux-x64.tar.gz"
curl -H "Cookie: s_cc=true; oraclelicense=accept-securebackup-cookie; s_nr=$TIME; gpw_e24=http%3A%2F%2Fwww.oracle.com%2Ftechnetwork%2Fjava%2Fjavase%2Fdownloads%2Fjdk8-downloads-2133151.html; s_sq=%5B%5BB%5D%5D" -H "User-Agent: Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36" -O -L http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.tar.gz
tar zxf $FILENAME
mkdir /usr/lib/jvm
mv jdk1.8.0* /usr/lib/jvm/jdk1.8.0
cat >> /etc/profile << EOF
export JAVA_HOME=/usr/lib/jvm/jdk1.8.0
export CLASSPATH=.:\$JAVA_HOME/lib:\$JAVA_HOME/jre/lib:\$CLASSPATH
export PATH=\$JAVA_HOME/bin:\$JAVA_HOME/jre/bin:\$PATH
export JRE_HOME=\$JAVA_HOME/jre
EOF
source /etc/profile
