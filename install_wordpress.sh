#!/bin/bash

apt-get -y update

logger "Installing WordPress"

# Set up a silent install of MySQL
dbpass=$1

export DEBIAN_FRONTEND=noninteractive
echo mysql-server-5.6 mysql-server/root_password password $dbpass | debconf-set-selections
echo mysql-server-5.6 mysql-server/root_password_again password $dbpass | debconf-set-selections

# Install the LAMP stack and WordPress
apt-get -y install apache2 mysql-server php php-mysql wordpress

# Setup WordPress
gzip -d /usr/share/doc/wordpress/examples/setup-mysql.gz
bash /usr/share/doc/wordpress/examples/setup-mysql -n wordpress localhost

ln -s /usr/share/wordpress /var/www/html/wordpress
mv /etc/wordpress/config-localhost.php /etc/wordpress/config-default.php
sed -i '5s/.*/define("'"DB_PASSWORD"'", "'"AyzT7MUp"'");/' /etc/wordpress/config-default.php

echo "ALTER USER 'wordpress'@'localhost' IDENTIFIED BY 'AyzT7MUp';" > change_password.sql
mysql -h localhost -u root --password="$dbpass" < change_password.sql

# Restart Apache
apachectl restart

logger "Done installing WordPress; open /wordpress to configure"
