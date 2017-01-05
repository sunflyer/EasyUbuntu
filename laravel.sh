#!/bin/bash

wget https://getcomposer.org/installer -O installer
php installer
mv composer.phar /usr/local/bin/composer

echo "Making User , please input user name for laravel : "
read NAME
useradd $NAME -m -d /home/$NAME -s /bin/bash
echo "Please set a password for user $NAME"
passwd $NAME
echo "Changing to $NAME"
su $NAME
cd ~/
composer global require "laravel/installer"
echo "export PATH=\$PATH:/home/$NAME/.config/composer/vendor/bin" >> /home/$NAME/.bashrc
echo "Completed. "

