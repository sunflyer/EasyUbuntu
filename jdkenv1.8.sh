#!/bin/bash
apt-get update && apt-get install curl -y && apt-get clean
TIME=$(date +%s)
TIME="$TIME"123
FILENAME="oracle-jdk11.tgz"
#URL="https://download.oracle.com/otn-pub/java/jdk/10.0.2+13/19aef61b38124481863b1413dce1855f/serverjre-10.0.2_linux-x64_bin.tar.gz"
URL="https://download.oracle.com/otn-pub/java/jdk/11.0.1+13/90cf5d8f270a4347a95050320eef3fb7/jdk-11.0.1_linux-x64_bin.tar.gz"
curl -o ${FILENAME} -H "Cookie: s_cc=true; oraclelicense=accept-securebackup-cookie; s_nr=$TIME; gpw_e24=http%3A%2F%2Fwww.oracle.com%2Ftechnetwork%2Fjava%2Fjavase%2Fdownloads%2Fjdk8-downloads-2133151.html; s_sq=%5B%5BB%5D%5D" -H "User-Agent: Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36" -O -L ${URL}
tar zxf $FILENAME
mkdir /usr/lib/jvm
mv jdk-10* /usr/lib/jvm/jdk11
cat >> /etc/profile << EOF
export JAVA_HOME=/usr/lib/jvm/jdk11
export CLASSPATH=.:\$JAVA_HOME/lib:\$JAVA_HOME/jre/lib:\$CLASSPATH
export PATH=\$JAVA_HOME/bin:\$JAVA_HOME/jre/bin:\$PATH
export JRE_HOME=\$JAVA_HOME/jre
EOF
source /etc/profile
