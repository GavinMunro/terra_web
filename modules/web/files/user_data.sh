#!/bin/bash
apt-get update -y
apt-get install -y nginx > /var/nginx.log
# This nginx install defaults to serving from /var/www/html
cd /var/www/html     # File permissions restricted here to user 'www-data'
sudo touch index.html  # This will take precedence over the existing index.nignx-debian.html
sudo chmod o+w index.html   # slightly insecure, in prod we'd run as 'www-data'
sudo echo "Hello, World. I'm an EC2." >> index.html
