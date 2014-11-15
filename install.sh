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

sudo apt-get install -y build-essential dkms re2c apache2 beanstalkd memcached postgresql libapache2-mod-php5 php5 php-pear php5-common php5-dev php5-curl php5-gd php5-json php5-memcached php5-mcrypt php5-mysqlnd php5-pgsql php5-readline php5-xdebug libmcrypt4 redis-server

cat << EOF | sudo tee -a /etc/php5/mods-available/xdebug.ini
xdebug.default_enable = 1
xdebug.idekey = "vagrant"
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

# Installing SQLite
sudo apt-get install -y sqlite3 libsqlite3-dev
sudo apt-get install -y php5-sqlite

# Install CouchDB
sudo apt-get install -y couchdb

# Install
sudo pecl install -f xhprof

xhprof="extension=xhprof.so
xhprof.output_dir=\"/var/tmp/xhprof\""
echo "$xhprof" | sudo tee -a /etc/php5/apache2/php.ini

# Set Apache ServerName
sudo sed -i "s/#ServerRoot.*/ServerName VagrantBox/" /etc/apache2/apache2.conf

sudo a2enmod rewrite

# Enable PHP Error Reporting
sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/apache2/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/apache2/php.ini

sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/cli/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/cli/php.ini
sudo sed -i "s/disable_functions = .*/disable_functions = /" /etc/php5/cli/php.ini
sudo sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php5/cli/php.ini
sudo sed -i "s/;date.timezone.*/date.timezone = America\/New_York/" /etc/php5/cli/php.ini

# Installing APC
sudo pecl install apc

apc="extension = apc.so
apc.shm_size = 64
apc.stat = 0"
echo "$apc" | sudo tee -a /etc/php5/apache2/php.ini

# Installing Imagemagick
sudo apt-get install -y imagemagick php5-imagick

# Install ApacheBench
sudo apt-get install -y apache2-utils
# Example:
# ab -n 1000 -c 100 http://localhost/

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
wget https://phar.phpunit.de/phpunit.phar
chmod +x phpunit.phar
sudo mv phpunit.phar /usr/local/bin/phpunit

# Install Copy/Paste Detector (CPD) for PHP code
wget https://phar.phpunit.de/phpcpd.phar
chmod +x phpcpd.phar
sudo mv phpcpd.phar /usr/local/bin/phpcpd

# Install PHPLOC - A tool for quickly measuring the size of a PHP project.
wget https://phar.phpunit.de/phploc.phar
chmod +x phploc.phar
sudo mv phploc.phar /usr/local/bin/phploc

# Configure & Start Beanstalkd Queue
sudo sed -i "s/#START=yes/START=yes/" /etc/default/beanstalkd
sudo /etc/init.d/beanstalkd start

# Install Fabric & Hipchat Plugin
sudo apt-get install -y python-pip
sudo pip install fabric
sudo pip install python-simple-hipchat

# Install NodeJs
sudo apt-add-repository -y ppa:chris-lea/node.js
sudo apt-get update
sudo apt-get install -y nodejs
sudo apt-get install -y npm

# Install Grunt
sudo npm install -g grunt-cli

# Install Forever
sudo npm install -g forever

# Install Gulp and dependecies
sudo npm install -g gulp

# Build PHP Info Site
mkdir /vagrant/PhpInfo
echo "<?php phpinfo();" > /vagrant/PhpInfo/phpinfo.php
cp /usr/share/php/apc.php /vagrant/PhpInfo/

# Configure Apache Hosts
echo "127.0.0.1  info.app" | sudo tee -a /etc/hosts
vhost="<VirtualHost *:80>
     ServerName info.app
     DocumentRoot /vagrant/PhpInfo
     <Directory \"/vagrant/PhpInfo\">
          Order allow,deny
          Allow from all
          # Require all granted
          AllowOverride All
    </Directory>
</VirtualHost>"
echo "$vhost" | sudo tee /etc/apache2/sites-available/info.app.conf
sudo a2ensite info.app.conf
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
          # Require all granted
          AllowOverride All
    </Directory>
</VirtualHost>"
echo "$vhost" | sudo tee /etc/apache2/sites-available/beansole.app.conf
sudo a2ensite beansole.app.conf
sudo service apache2 restart

# Final Clean
cd ~
rm -rf tmp/

# Reboot
sudo reboot
