#!/bin/bash

echo "================= START STEP-3-INSTALL-NGINX.SH $(date +"%r") ================="
echo " "
echo "BEGIN installing and configuring apache ..."

#install apache
if [ ! -d "/etc/nginx" ]; then
	sudo yum install epel-release -y > /dev/null
	sudo yum install nginx -y > /dev/null
fi

echo "... Configuring apache ..."
# copy our modified apache config files
cp /vagrant/configs/default.conf /etc/nginx/conf.d/

# restart apache
service nginx restart > /dev/null

# set apache to start at boot
chkconfig nginx on > /dev/null

echo "... End installing and configuring apache."
echo " "
echo "================= FINISH STEP-3-INSTALL-NGINX.SH $(date +"%r") ================="
echo " "
