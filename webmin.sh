#!/usr/bin/env bash

wget http://prdownloads.sourceforge.net/webadmin/webmin_1.710_all.deb

apt-get install -y perl libnet-ssleay-perl openssl libauthen-pam-perl libpam-runtime libio-pty-perl apt-show-versions python

dpkg --install webmin_1.710_all.deb

rm webmin_1.710_all.deb

# deb http://download.webmin.com/download/repository sarge contrib
# deb http://webmin.mirror.somersettechsolutions.co.uk/repository sarge contrib
# /etc/apt/sources.list

cd /root
sudo wget http://www.webmin.com/jcameron-key.asc
sudo apt-key add jcameron-key.asc

sudo apt-get update
sudo apt-get install webmin
