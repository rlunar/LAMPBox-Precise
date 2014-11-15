#!/usr/bin/env bash

# Install Nagios
sudo apt-get install -y nagios3 nagios-nrpe-plugin
# To add a user:
sudo htpasswd /etc/nagios3/htpasswd.users vagrant
