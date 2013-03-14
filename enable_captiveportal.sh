#!/bin/bash
#==========================================================================
# Description:
#   This script was written for enable captive portal for v1.0.1 and above.
#
# Config file:
#   .enable_captiveportal.conf
#       URL=http://this.is.example/index.html
#       CONTENT=TEST_VALUE\\\n
#
#==========================================================================

function helper_config(){
    echo -e "The config file error."
    echo -e "\tfilename: .enable_captiveportal.conf"
    echo -e "\t===== File Content ====="
    echo -e "\tURL=http://this.is.example/index.html"
    echo -e "\tCONTENT=TEST_VALUE\\\n"
    echo -e "\t========================"
}

cur_dir=$(pwd)

set -e
if [ 'unknown' == $(adb get-state) ]; then
	echo "Unknown device"
	exit -1
fi

####################
# Load Config File
####################
CONFIG_FILE=.enable_captiveportal.conf
if [ -f $CONFIG_FILE ]; then
    . $CONFIG_FILE
else
    helper_config
    exit -2
fi
if [ -z $CONF_URL ] || [ -z $CONF_CONTENT ]; then
    helper_config
    exit -2    
fi


####################
# Start
####################
dir=$(mktemp -d -t captive.XXXXXXXXXXXX)
cd ${dir} 

default_dir=$(adb shell ls /data/b2g/mozilla/ | grep "default" | sed "s/\n//g" | sed "s/\r//g")
prefs_path="/data/b2g/mozilla/${default_dir}/prefs.js"

adb pull ${prefs_path}
cp prefs.js prefs.js.bak

echo -e "user_pref(\"captivedetect.canonicalURL\", \"$CONF_URL\");" >> prefs.js
echo -e "user_pref(\"captivedetect.canonicalContent\", \"$CONF_CONTENT\");" >> prefs.js

adb push prefs.js ${prefs_path}
adb shell stop b2g
sleep 5
adb shell start b2g

cd ${cur_dir}
rm -rf ${dir}
