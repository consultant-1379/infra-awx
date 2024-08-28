#!/bin/bash
# Check user is root or in the sudo group

groups $USER | grep -q sudo

if [ $? -eq 0 ] || [ $(id -u) -eq 0 ]; then
	if [ ! -d /dev/mqueue ]; then
		echo "/dev/mqueue directory does not exist. Creating it ..."
		sudo mkdir /dev/mqueue
		echo "Setting ownership of the /dev/mqueue directory to root:root"
		sudo chown root:root /dev/mqueue
		echo "Setting permission on /dev/mqueue directory to 755"
		sudo chmod 755 /dev/mqueue
	else
		echo "/dev/mqueue directory exists - nothing to do"
	fi
fi
