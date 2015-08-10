# Send Gaiatests Reports to Github
#
# Author: Askeing
#
# For Jenkins
#
# setup the Git Repositories URL:
#     https://github.com/Mozilla-TWQA/Gaiatest-Reports.git with identify trusted computer, or
#     https://user:pwd@github.com/Mozilla-TWQA/Gaiatest-Reports.git
#     branch: gh-pages
#
# copy artifacts from upstream jobs (version with BuildID, and html reports)
#     push to smoketest/ and non-smoketest/ folders
#
#
echo "##### SmokeTest Version #####"
cat smoketest/version
echo "#############################"
echo "### Non-SmokeTest Version ###"
cat non-smoketest/version
echo "#############################"

### If two report's version are different, then stop send report.
diff smoketest/version non-smoketest/version && RET=0 || RET=1
if [[ ${RET} -ne 0 ]]; then
    echo "Different Version between two reports."
    exit -1
fi

### Checkout master and pull update
git checkout gh-pages
git stash
git stash clear
git pull


### Print Version Info
echo "Build ID : ${BuildID}"
BuildID_YEAR=${BuildID:0:4}
BuildID_MONTH=${BuildID:4:2}
BuildID_FORMAT=${BuildID:0:4}-${BuildID:4:2}-${BuildID:6:2}-${BuildID:8:2}-${BuildID:10:2}-${BuildID:12:2}


### Create folder of Builds
if [[ ! -d ${BuildID_YEAR}/${BuildID_MONTH}/${BuildID} ]]; then
    mkdir -p ${BuildID_YEAR}/${BuildID_MONTH}/${BuildID}
fi


### Move reports into folder
mv smoketest/index.html ${BuildID_YEAR}/${BuildID_MONTH}/${BuildID}/smoketest.html
mv non-smoketest/index.html ${BuildID_YEAR}/${BuildID_MONTH}/${BuildID}/non-smoketest.html


### Create HTML for Github pages
#### Top Level - Index
grep "${BuildID_YEAR}/index.html" index.html && EXIST_YEAR=0 || EXIST_YEAR=1
if [[ ${EXIST_YEAR} -ne 0 ]]; then
    echo "<a href="./${BuildID_YEAR}/index.html">${BuildID_YEAR} Reports</a><br/>" >> index.html
fi

#### 1st Level - Year
if [[ ! -f ${BuildID_YEAR}/index.html ]]; then
    echo "<a href="../index.html">Parent Directory</a><hr/>" >> ${BuildID_YEAR}/index.html
fi
grep "${BuildID_MONTH}/index.html" ${BuildID_YEAR}/index.html && EXIST_MONTH=0 || EXIST_MONTH=1
if [[ ${EXIST_MONTH} -ne 0 ]]; then
    echo "<a href="./${BuildID_MONTH}/index.html">${BuildID_YEAR}-${BuildID_MONTH} Reports</a><br/>" >> ${BuildID_YEAR}/index.html
fi

#### 2nd Level - Month
if [[ ! -f ${BuildID_YEAR}/${BuildID_MONTH}/index.html ]]; then
    echo "<a href="../index.html">Parent Directory</a><hr/>" >> ${BuildID_YEAR}/${BuildID_MONTH}/index.html
fi
grep "${BuildID_FORMAT} Reports" ${BuildID_YEAR}/${BuildID_MONTH}/index.html && EXIST_BUILD=0 || EXIST_BUILD=1
if [[ ${EXIST_BUILD} -ne 0 ]]; then
    echo "<a href="./${BuildID}/index.html">${BuildID_FORMAT} Reports</a><br/>" >> ${BuildID_YEAR}/${BuildID_MONTH}/index.html
fi

#### 3rd Level - Build
echo "<a href="../index.html">Parent Directory</a><hr/>" > ${BuildID_YEAR}/${BuildID_MONTH}/${BuildID}/index.html
echo "<a href="./smoketest.html">${BuildID_FORMAT} Smoketest Report</a><br/>" >> ${BuildID_YEAR}/${BuildID_MONTH}/${BuildID}/index.html
echo "<a href="./non-smoketest.html">${BuildID_FORMAT} Non-Smoketest Report</a>" >> ${BuildID_YEAR}/${BuildID_MONTH}/${BuildID}/index.html

#exit 0

### Create commit for reports
git add index.html
git add ${BuildID_YEAR}/
git commit -am "HTML Report of Hamachi Master ${BuildID} Build."


### Push to Github
git push origin gh-pages 2>&1 | sed s/"TW-BOT:.*@github.com"/"TW-BOT:****@github.com"/g && \
echo "LINK=http://mozilla-twqa.github.io/Gaiatest-Reports/${BuildID_YEAR}/${BuildID_MONTH}/${BuildID}/index.html"
echo "### Open http://mozilla-twqa.github.io/Gaiatest-Reports/${BuildID_YEAR}/${BuildID_MONTH}/${BuildID}/index.html to get the reports."

