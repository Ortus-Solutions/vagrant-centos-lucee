#!/bin/bash

echo "================= START INSTALL-NGINX.SH $(date +"%r") ================="
echo " "
echo "BEGIN installing and configuring Nginx ..."

#install Nginx
if [ ! -d "/etc/nginx" ]; then
	sudo yum install epel-release -y > /dev/null
	sudo yum install nginx -y > /dev/null
fi

echo "... Configuring Nginx ..."
# copy our modified Nginx config files
/bin/cp -f /vagrant/configs/nginx.conf /etc/nginx/ 

# restart Nginx
service nginx restart > /dev/null

# set Nginx to start at boot
chkconfig nginx on > /dev/null

echo "... End installing and configuring Nginx."
echo " "
echo "================= FINISH INSTALL-NGINX.SH $(date +"%r") ================="
echo " "
