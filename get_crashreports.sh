#!/bin/bash
#==========================================================================
# Description:
#   This is to get the crash reports of submitted/pending.
#==========================================================================

set -e

if [ -f crashreports.txt ]; then
    rm crashreport.txt
fi

echo -e "Submitted crash reports\n==========" > crashreport.txt
adb shell ls -al /data/b2g/mozilla/Crash\ Reports/submitted >> crashreport.txt

echo -e "\nPending crash reports\n==========" >> crashreport.txt
adb shell ls -al /data/b2g/mozilla/Crash\ Reports/pending >> crashreport.txt

cat crashreport.txt
