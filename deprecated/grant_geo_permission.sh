#!/bin/bash
#==========================================================================
# Description:
#   This script was written for grant the geolocation permission of unagi.
#==========================================================================

function helper(){
    echo -e "This script was written for grant the geolocation permission of unagi."
	echo -e "-h, --help\tDisplay help."
    echo -e "-?\t\tDisplay help."
}

for x
do
	# -h, --help, -?: help
	if [ "$x" = "--help" ] || [ "$x" = "-h" ] || [ "$x" = "-?" ]; then
	    helper
		exit 0
	else
		echo -e "'$x' is an invalid command. See '--help'."
		exit 0
	fi
done

adb -s full_unagi shell sqlite3 /data/local/permissions.sqlite "UPDATE moz_hosts SET permission=1 WHERE type='geolocation' AND permission!=1;"
adb -s full_unagi reboot
