# EasyUbuntu
Quick Installation Scripts For installing LNMP(Nginx stable + PHP5.6 + MySQL 5.6) and some more on ubuntu/debian.

Attention : Please use root privileges (either su or sudo ) to run all the scripts

## Install LNMP :
wget https://raw.githubusercontent.com/sunflyer/EasyUbuntu/master/lnmp.sh && sudo bash lnmp.sh

This scripts will install PHP5.6 \ MySQL 5.6 and Nginx Stable Version FROM PPA SOURCE.  

Note : MySQL 5.6 may install failed if memory lower tha 128MB （Due to buffer pool） , if you see something like "dpkg returned error code (1)" , please choose MySQL 5.5 or reduce Buffer Pool size(not recommended).


## Install Shadowsock Server :
wget https://raw.githubusercontent.com/sunflyer/EasyUbuntu/master/shadowsock.sh && sudo bash shadowsock.sh

This scripts will make 3 scripts and 1 json file for shadowsock in current directory. The three scripts is used for start/stop/restart shadowsock and json file is used for configuration. 

By default ,the ecryption method is rc4-md5 and two port (2330 and 2333) opened with password (987654321 and 123456789).
Remember to change it!
