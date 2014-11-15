#!/usr/bin/env bash

# Upgrade Base Packages
sudo apt-get update
sudo apt-get upgrade -y

sudo apt-get install -y curl git nano openssh-server python-software-properties python2.7-dev
# For PHP 5.4 use:
sudo add-apt-repository -y ppa:ondrej/php5-oldstable
# For PHP 5.5 use:
# sudo add-apt-repository -y ppa:ondrej/php5
# For PHP 5.6 use:
# sudo add-apt-repository -y ppa:ondrej/php5-5.6
sudo apt-get update

sudo apt-get install -y build-essential dkms re2c apache2 beanstalkd memcached postgresql libapache2-mod-php5 php5 php-pear php5-common php5-dev php5-apcu php5-curl php5-gd php5-json php5-memcached php5-mcrypt php5-mysql php5-mysqlnd php5-pgsql php5-readline php5-sqlite php5-xdebug libmcrypt4 redis-server

cat << EOF | sudo tee -a /etc/php5/mods-available/xdebug.ini
xdebug.default_enable = 1
xdebug.scream = 1
xdebug.cli_color = 1
xdebug.show_local_vars = 1
xdebug.remote_enable = 1
xdebug.remote_autostart = 0
xdebug.remote_port = 9000
xdebug.remote_handler = dbgp
xdebug.remote_log = "/var/log/xdebug/xdebug.log"
xdebug.remote_host=192.168.33.1
EOF

# Set Apache ServerName
sudo sed -i "s/#ServerRoot.*/ServerName VagrantBox/" /etc/apache2/apache2.conf

sudo a2enmod rewrite

# Enable PHP Error Reporting
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/apache2/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/apache2/php.ini

sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/cli/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/cli/php.ini
sed -i "s/disable_functions = .*/disable_functions = /" /etc/php5/cli/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php5/cli/php.ini
sed -i "s/;date.timezone.*/date.timezone = America\/New_York/" /etc/php5/cli/php.ini

sudo service apache2 restart

# Install MySQL
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
sudo apt-get -y install mysql-server

# Configure Mcrypt (Ubuntu)
sudo ln -s /etc/php5/conf.d/mcrypt.ini /etc/php5/mods-available
sudo php5enmod mcrypt
sudo service apache2 restart

# Install Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Install PHPUnit
sudo pear config-set auto_discover 1
sudo pear install pear.phpunit.de/phpunit

# Configure & Start Beanstalkd Queue
sudo sed -i "s/#START=yes/START=yes/" /etc/default/beanstalkd
sudo /etc/init.d/beanstalkd start

# Install Fabric & Hipchat Plugin
sudo apt-get install -y python-pip
sudo pip install fabric
sudo pip install python-simple-hipchat

# Install NodeJs
apt-add-repository ppa:chris-lea/node.js
apt-get update
apt-get install nodejs
apt-get install npm

# Install Grunt
sudo npm install -g grunt-cli

# Install Forever
sudo npm install -g forever

# Install Gulp and dependecies
sudo npm install -g gulp

# Build PHP Info Site
echo "<?php phpinfo();" > /vagrant/PhpInfo/phpinfo.php

# Configure Apache Hosts
sudo a2enmod rewrite
echo "127.0.0.1  info.app" | sudo tee -a /etc/hosts
vhost="<VirtualHost *:80>
     ServerName info.app
     DocumentRoot /vagrant/PhpInfo
     <Directory \"/vagrant/PhpInfo\">
          Order allow,deny
          Allow from all
          Require all granted
          AllowOverride All
    </Directory>
</VirtualHost>"
echo "$vhost" | sudo tee /etc/apache2/sites-available/info.app.conf
sudo a2ensite info.app
sudo service apache2 restart

# Install Beanstalkd Console
cd /vagrant
git clone https://github.com/ptrofimov/beanstalk_console.git Beansole
echo "127.0.0.1  beansole.app" | sudo tee -a /etc/hosts
vhost="<VirtualHost *:80>
     ServerName beansole.app
     DocumentRoot /vagrant/Beansole/public
     <Directory \"/vagrant/Beansole/public\">
          Order allow,deny
          Allow from all
          Require all granted
          AllowOverride All
    </Directory>
</VirtualHost>"
echo "$vhost" | sudo tee /etc/apache2/sites-available/beansole.app.conf
sudo a2ensite beansole.app
sudo service apache2 restart

# Install Nagios
sudo apt-get install nagios3 nagios-nrpe-plugin
# To add a user:
sudo htpasswd /etc/nagios3/htpasswd.users rluna

# Final Clean
cd ~
rm -rf tmp/

# Reboot
sudo reboot
