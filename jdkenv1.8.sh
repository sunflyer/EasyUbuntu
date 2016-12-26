#!/bin/bash
cat > /etc/profile << EOF
export JAVA_HOME=/usr/lib/jvm/jdk1.8.0
export CLASSPATH=.:\$JAVA_HOME/lib:\$JAVA_HOME/jre/lib:\$CLASSPATH
export PATH=\$JAVA_HOME/bin:\$JAVA_HOME/jre/bin:\$PATH
export JRE_HOME=\$JAVA_HOME/jre
EOF
source /etc/profile
