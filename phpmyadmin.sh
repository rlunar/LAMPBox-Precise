sudo add-apt-repository ppa:nijel/phpmyadmin
sudo apt-get update
sudo apt-get install php5-mysqlnd

sudo apt-get remove  phpmyadmin --purge
sudo apt-get install phpmyadmin

phpmyadmin="Include /etc/phpmyadmin/apache.conf"
echo "$phpmyadmin" | sudo tee -a /etc/apache2/apache2.conf

sudo service apache2 restart
