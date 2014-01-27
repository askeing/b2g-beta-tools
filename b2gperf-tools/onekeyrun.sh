#!/bin/bash
#==========================================================================
# 
# Description:
#   This is support tool for b2gperf.
#
# Author: Askeing fyen@mozilla.com
# History:
#   2014/01/10 Askeing: v1.0 First release.
#   2014/01/23 Askeing: added failed apps info in summary.
#
#==========================================================================

DELAY=${DELAY:=5}
APPS_LIST_FILE=appslist.txt
OUTPUT_LOG=output.log
SUMMARY_FILE=summary.txt
SUMMARY_CSV=summary.csv

echo "### Clean Result Files..."
rm -f ${OUTPUT_LOG} ${SUMMARY_FILE} ${SUMMARY_CSV}

# run python b2gperf/listapps.py to get the apps list.
if [ ! -f ${APPS_LIST_FILE} ]; then
    echo "There is no ${APPS_LIST_FILE} file. Please create it."
    exit -1
fi

echo "### Apps List:"
cat ${APPS_LIST_FILE} | sed ':a;N;$!ba;s/\n/, /g'

echo -e "\n### Running b2gperf..."
cat ${APPS_LIST_FILE} | xargs --no-run-if-empty -i b2gperf "{}" --delay ${DELAY} 2>&1 | tee -a ${OUTPUT_LOG}
#cat appslist.txt | sed ':a;N;$!ba;s/\n/" "/g' | sed 's/^/"/g' | sed 's/$/"/g' | xargs --no-run-if-empty b2gperf --delay 5 {} 2>&1 | tee -a result.txt

echo -e "\n### Summary:"
cat ${OUTPUT_LOG} | grep "Results for" | sed "s/.*Results for /\[/g" | sed "s/, cold_load_time:/\] \tcold_load_time:/g" | sed "s/, all:.*//g" > ${SUMMARY_FILE}
cat ${SUMMARY_FILE}

echo "Cold_Load_Time,Median,Mean,Std,Max,Min" > ${SUMMARY_CSV}
cat ${SUMMARY_FILE} | sed "s/\[/\"/g" | sed "s/\]\s*/\"/g" | sed "s/\s*cold_load_time:\s*median:\s*/,/g" | sed "s/\s*mean:\s*//g" | sed "s/\s*std:\s*//g" | sed "s/\s*max:\s*//g" | sed "s/\s*min:\s*//g" >> ${SUMMARY_CSV}

echo "### Failures"
while read APPSNAME
do
    grep "${APPSNAME}" ${SUMMARY_FILE} > /dev/null
    if [[ ! $? == "0" ]]; then
        echo "* Can not get the Cold Load Time of App: ${APPSNAME}"
        echo "\"${APPSNAME}\",na,na,na,na,na" >> ${SUMMARY_CSV}
    fi
done < ${APPS_LIST_FILE}

echo "### Finish."
