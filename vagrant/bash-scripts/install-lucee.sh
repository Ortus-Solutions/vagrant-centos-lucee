#!/bin/bash

echo "================= START INSTALL-LUCEE.SH $(date +"%r") ================="
echo " "
echo "BEGIN setting up Lucee"

##############################################################################################
## Lucee Installation
##############################################################################################
LUCEE_VERSION="4.5.1.000"

if [ ! -d "/opt/lucee" ]; then
	
	# Don't download if we've already got it locally
	if [ ! -f "/vagrant/artifacts/lucee-$LUCEE_VERSION-pl0-linux-x64-installer.run" ]; then
		echo "... Downloading the Lucee installer, standby ..."
		wget -O /vagrant/artifacts/lucee-$LUCEE_VERSION-pl0-linux-x64-installer.run http://downloads.ortussolutions.com/lucee/lucee/$LUCEE_VERSION/lucee-$LUCEE_VERSION-pl0-linux-x64-installer.run  &> /dev/null
	fi

	echo "... Copying Lucee installer ..."
	sudo cp /vagrant/artifacts/lucee-$LUCEE_VERSION-pl0-linux-x64-installer.run /root
	
	echo "... Installing Lucee ..."
	chmod +x /root/lucee-$LUCEE_VERSION-pl0-linux-x64-installer.run
	cp /vagrant/configs/lucee-options.txt /root
	/root/lucee-$LUCEE_VERSION-pl0-linux-x64-installer.run --mode unattended --optionfile /root/lucee-options.txt
else
	echo "Lucee setup already, skipping"
fi

##############################################################################################
## Patch lucee
###############################################################################################
PATCH_VERSION="4.5.1.020"
PATCH_FILE="$PATCH_VERSION.lco"
PATCH_FORCE=0

echo "BEGIN Lucee Patching: $PATCH_FILE";

# Don't patch if already patched
if [ ! -f /opt/lucee/lib/lucee-server/patches/$PATCH_FILE ] || [ $PATCH_FORCE -eq 1 ]; then
	# Don't download if we've already got it locally
	if [ ! -f "/vagrant/artifacts/lucee-$PATCH_FILE" ]; then
		echo "... Downloading the Lucee patch v$PATCH_VERSION, standby ..."
		wget -O /vagrant/artifacts/lucee-$PATCH_FILE http://downloads.ortussolutions.com/lucee/lucee/$PATCH_VERSION/lucee-$PATCH_FILE  &> /dev/null
	fi

	echo "... Copying Lucee Patch ..."
	sudo cp /vagrant/artifacts/lucee-$PATCH_FILE /opt/lucee/lib/lucee-server/patches/$PATCH_FILE
else 
	echo "Lucee patched already, skipping"
fi

##############################################################################################
## Lucee Configuration
##############################################################################################
echo "... Copying the Lucee config files into place ..."
sudo /bin/cp -f /vagrant/configs/setenv.sh /opt/lucee/tomcat/bin
sudo /bin/cp -f /vagrant/configs/lucee-server.xml /opt/lucee/lib/lucee-server/context
#sudo cp /vagrant/configs/server.xml /opt/lucee/tomcat/conf/server.xml

##############################################################################################
## Restarting
##############################################################################################
echo "... Restarting Lucee ..."
service lucee_ctl restart > /dev/null

echo "... END setting up Lucee."
echo " "
echo "================= FINISH INSTALL-LUCEE.SH $(date +"%r") ================="
echo " "
