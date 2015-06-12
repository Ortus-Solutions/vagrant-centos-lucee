#!/bin/bash

echo "================= START install-commandbox.sh $(date +"%r") ================="
echo " "
echo "BEGIN installing CommandBox"

##############################################################################################
## CommandBox Installation
##############################################################################################
CMD_VERSION="2.1.0"

# Check if we have CommandBox Installed
if [ ! -f "/usr/bin/box" ]; then
	
	# Don't download if we've already got it locally
	if [ ! -f "/vagrant/artifacts/commandbox-bin-$CMD_VERSION.zip" ]; then
		echo "... Downloading JDK: $JDK_VERSION, standby ..."
		wget -O /vagrant/artifacts/commandbox-bin-$CMD_VERSION.zip http://integration.stg.ortussolutions.com/artifacts/ortussolutions/commandbox/$CMD_VERSION/commandbox-bin-$CMD_VERSION.zip  &> /dev/null
	fi

	# Unpack it
	sudo unzip /vagrant/artifacts/commandbox-bin-$CMD_VERSION.zip -d /usr/bin/
	chmod +x /usr/bin/box

	echo "CommandBox installed successfully"
	
else
	echo "CommandBox is already installed, skipping"
fi

echo "... END installing JDK."
echo " "
echo "================= FINISH install-commandbox.sh $(date +"%r") ================="
echo " "
