#!/bin/bash
#==========================================================================
# Description:
#   This script was written for flash build from server.
#==========================================================================


####################
# Parameter Flags
####################
# Default: download, no flash, nightly build, no backup
Version_Flag="v1train"
Engineer_Flag=0
Download_Flag=true
Flash_Flag=false
Backup_Flag=false
BackupOnly_Flag=false
RecoverOnly_Flag=false

## helper_config function
function helper_config(){
    echo -e "The config file error."
    echo -e "\tfilename: .autoflash.conf"
    echo -e "\t===== File Content ====="
    echo -e "\tCONF_100_USR_URL=https://path.to.unagi.v1.0.0/latest/"
    echo -e "\tCONF_101_ENG_URL=https://path.to.unagi.v1.0.1-eng/latest/"
    echo -e "\tCONF_101_USR_URL=https://path.to.unagi.v1.0.1/latest/"
    echo -e "\tCONF_110_ENG_URL=https://path.to.unagi.v1.1.0-eng/latest/"
    echo -e "\tCONF_110_USR_URL=https://path.to.unagi.v1.1.0/latest/"
    echo -e "\t# optional section"
    echo -e "\tCONF_VERSION=v1train"
    echo -e "\tCONF_ENGINEER=0"
    echo -e "\t========================"
}

## helper function
## no input arguments, simply print helper descirption to std out
function helper(){
	echo -e "This script will download latest release build from server. (only for unagi now)\n"
	echo -e "Usage: [Environment] ./autoflash.sh [parameters]"
	echo -e "Environment:\n\tHTTP_USER={username} HTTP_PWD={pw} ADB_PATH=adb_path\n"
	# -f, --flash
	echo -e "-f|--flash\tFlash your device (unagi) after downlaod finish."
	echo -e "\t\tYou may have to input root password when you add this argument."
	echo -e "\t\tYour PATH should has adb path, or you can setup the ADB_PATH."
	# -F, --flash-only
    echo -e "-F|--flash-only\tFlash your device from local zipped build(ex: -F{file name}); default: use latest downloaded"
	# -e, --eng
	echo -e "-e|--eng\tchange the target build to engineer build."
    # -v, --version
    echo -e "-v|--version, \t give the target build version, ex: -vtef == -v100; show available version if nothing specified."
	# --tef: tef build v1.0.0
	echo -e "--tef\tchange the target build to tef build v1.0.0."
	# --shira: shira build v1.0.1
	echo -e "--shira\tchange the target build to shira build v1.0.1."
	# --v1train: v1-train build
	echo -e "--v1train\tchange the target build to v1train build."
	# -b, --backup
	echo -e "-b|--backup\tbackup and recover the origin profile."
	echo -e "\t\t(it will work with -f anf -F)"
	# -B, --backup-only
	echo -e "-B|--backup-only:\tbackup the phone to local machine"
	# -R, --recover-only
	echo -e "-R|--recover-only:\trecover the phone from local machine"
	# -h, --help
	echo -e "-h|--help\tDisplay help."
	echo -e "Example:"
	echo -e "  Download build.\t\t./autoflash.sh"
	echo -e "  Download engineer build.\tHTTP_USER=dog@foo.foo HTTP_PWD=foo ./autoflash.sh -e"
	echo -e "  Download and flash build.\t./autoflash.sh -f"
	echo -e "  Flash engineer build.\t\t./autoflash.sh -e -F"
	echo -e "  Flash engineer build, backup profile.\t\t./autoflash.sh -e -F -b"
	echo -e "  Flash engineer build, don't update kernel.\t./autoflash.sh -e -F --no-kernel"
	exit 0
}

## version parsing
## arg1: version for flash, if the version is not specified then default option will be taken
## output: set version to global $Version_Flag
function version(){
    local_ver=$1
    case "$local_ver" in
        100|tef) Version_Flag="tef";;
        101|shira) Version_Flag="shira";;
        110|v1train) Version_Flag="v1train";;
    esac
}

function version_info(){
    echo -e "Available version:"
    echo -e "\t100|tef"
    echo -e "\t101|shira"
    echo -e "\t110|v1train"
}


####################
# Load Config File (before load parameters)
####################
CONFIG_FILE=.autoflash.conf
if [ -f $CONFIG_FILE ]; then
    . $CONFIG_FILE
else
    helper_config
    exit -2
fi
if [ -z $CONF_100_USR_URL ] || [ -z $CONF_101_ENG_URL ] || [ -z $CONF_101_USR_URL ] || [ -z $CONF_110_ENG_URL ] || [ -z $CONF_110_USR_URL ]; then
    helper_config
    exit -2
fi
if ! [ -z $CONF_VERSION ]; then
    version $CONF_VERSION
fi
if ! [ -z $CONF_ENGINEER ]; then
    if [ $CONF_ENGINEER == 0 ] || [ $CONF_ENGINEER == 1 ]; then
        Engineer_Flag=$CONF_ENGINEER
    fi
fi


## show helper if nothing specified
#if [ $# = 0 ]; then echo "Nothing specified"; helper; exit 0; fi

## add getopt argument parsing
TEMP=`getopt -o fF::ebrhv: --long flash,flash-only:,eng,version:,tef,shira,v1train,backup,recover-only,help \
    -n 'error occured' -- "$@"`

if [ $? != 0 ]; then echo "Terminating..." >&2; exit 1; fi

eval set -- "$TEMP"

### TODO: -f can get an optional argument and download with build number or something
### write Filename and prevent for future modification

while true
do
    case "$1" in
        -f|--flash) Download_Flag=true; Flash_Flag=true; shift;;
        -F|--flash-only) Download_Flag=false; Flash_Flag=true;
           case "$2" in
            "") shift 2;;
             *) Filename=$2; shift 2;;
           esac ;;
        -e|--eng) Engineer_Flag=1; shift;;
        -v|--version) 
           case "$2" in
            "") version_info; exit 0; shift 2;;
             *) version $2; shift 2;;
           esac;;
        --tef) version "tef"; shift;;
        --shira) version "shira"; shift;;
        --v1train) version "v1train"; shift;;
        -b|--backup) Backup_Flag=true; shift;;
        -B|--backup-only) BackupOnly_Flag=true; shift;;
        -r|--recover-only) RecoverOnly_Flag=true; shift;;
        -h|--help) helper; exit 0;;
        --) shift;break;;
        *) echo error occured; exit 1;;
    esac
done


####################
# Backup Only task
####################
if [ $BackupOnly_Flag == true ]; then
	if [ ! -d mozilla-profile ]; then
		echo "no backup folder, creating..."
		mkdir mozilla-profile
	fi
	echo -e "Backup your profiles..."
	adb shell stop b2g 2> ./mozilla-profile/backup.log &&\
	rm -rf ./mozilla-profile/* &&\
	mkdir -p mozilla-profile/profile &&\
	adb pull /data/b2g/mozilla ./mozilla-profile/profile 2> ./mozilla-profile/backup.log &&\
	mkdir -p mozilla-profile/data-local &&\
	adb pull /data/local ./mozilla-profile/data-local 2> ./mozilla-profile/backup.log &&\
	rm -rf mozilla-profile/data-local/webapps
	adb shell start b2g 2> ./mozilla-profile/backup.log
	echo -e "Backup done."
	exit 0
fi

####################
# Recover Only task
####################
if [ $RecoverOnly_Flag == true ]; then
	echo -e "Recover your profiles..."
	if [ ! -d mozilla-profile/profile ] || [ ! -d mozilla-profile/data-local ]; then
		echo "no recover files."
		exit -1
	fi
	adb shell stop b2g 2> ./mozilla-profile/recover.log &&\
	adb shell rm -r /data/b2g/mozilla 2> ./mozilla-profile/recover.log &&\
	adb push ./mozilla-profile/profile /data/b2g/mozilla 2> ./mozilla-profile/recover.log &&\
	adb push ./mozilla-profile/data-local /data/local 2> ./mozilla-profile/recover.log &&\
	adb reboot
	sleep 30
	echo -e "Recover done."
	exit 0
fi

####################
# Check date and Files
####################
Yesterday=$(date --date='1 days ago' +%Y-%m-%d)
Today=$(date +%Y-%m-%d)

DownloadFilename=unagi.zip
# tef v1.0.0: only user build
if [ $Version_Flag == "tef" ]; then
	Engineer_Flag=0
	URL=${CONF_100_USR_URL}${DownloadFilename}
# shira v1.0.1: eng/user build
elif [ $Version_Flag == "shira" ] && [ $Engineer_Flag == 1 ]; then
	URL=${CONF_101_ENG_URL}${DownloadFilename}
elif [ $Version_Flag == "shira" ] && [ $Engineer_Flag == 0 ]; then
	URL=${CONF_101_USR_URL}${DownloadFilename}
# v1-train: eng/user build
elif [ $Version_Flag == "v1train" ] && [ $Engineer_Flag == 1 ]; then
	URL=${CONF_110_ENG_URL}${DownloadFilename}
elif [ $Version_Flag == "v1train" ] && [ $Engineer_Flag == 0 ]; then
	URL=${CONF_110_USR_URL}${DownloadFilename}
else
	URL=${CONF_110_USR_URL}${DownloadFilename}
fi

####################
# Download task
####################
if [ $Download_Flag == true ]; then
	# Clean file
	echo -e "Clean..."
	rm -f $DownloadFilename

	# Prepare the authn of web site
	if [ "$HTTP_USER" != "" ]; then
		HTTPUser=$HTTP_USER
	else
		read -p "Enter HTTP Username (LDAP): " HTTPUser
	fi
	if [ "$HTTP_PWD" != "" ]; then
		HTTPPwd=$HTTP_PWD
	else
		read -s -p "Enter HTTP Password (LDAP): " HTTPPwd
	fi
	
	# Download file
	[ $Engineer_Flag == 0 ] && Build_SRT="User" || Build_SRT="Engineer"
	echo -e "\n\nDownload latest ${Version_Flag} ${Build_SRT} build..."
	wget --http-user="${HTTPUser}" --http-passwd="${HTTPPwd}" $URL

	# Check the download is okay
	if [ $? -ne 0 ]; then
		echo -e "Download $URL failed."
		exit 1
	fi

	# Modify the downloaded filename
	filetime=`stat -c %y unagi.zip | sed 's/\s.*$//g'`
	# tef v1.0.0: only user build
	if [ $Version_Flag == "tef" ]; then
		Filename=unagi_${filetime}_tef_usr.zip
	# shira v1.0.1: eng/user build
	elif [ $Version_Flag == "shira" ] && [ $Engineer_Flag == 1 ]; then
		Filename=unagi_${filetime}_shira_eng.zip
	elif [ $Version_Flag == "shira" ] && [ $Engineer_Flag == 0 ]; then
		Filename=unagi_${filetime}_shira_usr.zip
	# v1-train: eng/user build
	elif [ $Version_Flag == "v1train" ] && [ $Engineer_Flag == 1 ]; then
		Filename=unagi_${filetime}_v1train_eng.zip
	elif [ $Version_Flag == "v1train" ] && [ $Engineer_Flag == 0 ]; then
		Filename=unagi_${filetime}_v1train_usr.zip
	fi

	rm -f $Filename
	mv $DownloadFilename $Filename
	echo -e "Download latest ${Version_Flag} ${Build_SRT} build done, saved as \"$Filename\"."

else
	# Setup the filename for -F
	# tef v1.0.0: only user build
    if ! [ -z $Filename ]; then
        echo "File name is $Filename"
    elif [ $Version_Flag == "tef" ]; then
		Filename=`ls -tm unagi_*_tef_usr.zip | sed 's/,.*$//g' | head -1`
	# shira v1.0.1: eng/user build
	elif [ $Version_Flag == "shira" ] && [ $Engineer_Flag == 1 ]; then
		Filename=`ls -tm unagi_*_shira_eng.zip | sed 's/,.*$//g' | head -1`
	elif [ $Version_Flag == "shira" ] && [ $Engineer_Flag == 0 ]; then
		Filename=`ls -tm unagi_*_shira_usr.zip | sed 's/,.*$//g' | head -1`
	# v1-train: eng/user build
	elif [ $Version_Flag == "v1train" ] && [ $Engineer_Flag == 1 ]; then
		Filename=`ls -tm unagi_*_v1train_eng.zip | sed 's/,.*$//g' | head -1`
	elif [ $Version_Flag == "v1train" ] && [ $Engineer_Flag == 0 ]; then
		Filename=`ls -tm unagi_*_v1train_usr.zip | sed 's/,.*$//g' | head -1`
	fi
fi

####################
# Decompress task
####################
# Check the file is exist
if ! [ -z $Filename ]; then
    test ! -f $Filename && echo -e "The file $Filename DO NOT exist." && exit 1
else
    echo -e "The file DO NOT exist." && exit 1
fi

# Delete folder
echo -e "Delete old build folder: b2g-distro"
rm -rf b2g-distro/

# Unzip file
echo -e "Unzip $Filename ..."
unzip $Filename || exit -1


####################
# Flash device task
####################
if [ $Flash_Flag == true ]; then
	# make sure
	read -p "Are you sure you want to flash your device? [y/N]" isFlash
	if [ "$isFlash" != "y" ] && [ "$isFlash" != "Y" ]; then
		echo -e "byebye."
		exit 0
	fi

	# ADB PATH
	if [ "$ADB_PATH" == "" ]; then
		echo -e 'No ADB_PATH, using PATH'
	else
		echo -e "Using ADB_PATH = $ADB_PATH"
		PATH=$PATH:$ADB_PATH
		export PATH
	fi

	####################
	# Backup task
	####################
	if [ $Backup_Flag == true ]; then
		if [ ! -d mozilla-profile ]; then
			echo "no backup folder, creating..."
			mkdir mozilla-profile
		fi
		echo -e "Backup your profiles..."
		adb shell stop b2g 2> ./mozilla-profile/backup.log &&\
		rm -rf ./mozilla-profile/* &&\
		mkdir -p mozilla-profile/profile &&\
		adb pull /data/b2g/mozilla ./mozilla-profile/profile 2> ./mozilla-profile/backup.log &&\
		mkdir -p mozilla-profile/data-local &&\
		adb pull /data/local ./mozilla-profile/data-local 2> ./mozilla-profile/backup.log &&\
		rm -rf mozilla-profile/data-local/webapps
		echo -e "Backup done."
	fi

	echo -e "flash your device..."
	cd ./b2g-distro
	#sudo env PATH=$PATH ./flash.sh
	./flash.sh
	cd ..

	####################
	# Recover task
	####################
	if [ $Backup_Flag == true ] && [ -d mozilla-profile/profile ] && [ -d mozilla-profile/data-local ];  then
		sleep 5
		echo -e "Recover your profiles..."
		adb shell stop b2g 2> ./mozilla-profile/recover.log &&\
		adb shell rm -r /data/b2g/mozilla 2> ./mozilla-profile/recover.log &&\
		adb push ./mozilla-profile/profile /data/b2g/mozilla 2> ./mozilla-profile/recover.log &&\
		adb push ./mozilla-profile/data-local /data/local 2> ./mozilla-profile/recover.log &&\
		adb reboot
		adb wait-for-device
		echo -e "Recover done."
	fi
fi

####################
# Retrieve Version info
####################
#if [ $Engineer_Flag == 1 ]; then
#	grep '^.*path=\"gecko\" remote=\"mozillaorg\" revision=' ./b2g-distro/default.xml | sed 's/^.*path=\"gecko\" remote=\"mozillaorg\" revision=/gecko revision: /g' | sed 's/\/>//g' > VERSION
#	grep '^.*path=\"gaia\" remote=\"mozillaorg\" revision=' ./b2g-distro/default.xml | sed 's/^.*path=\"gaia\" remote=\"mozillaorg\" revision=/gaia revision: /g' | sed 's/\/>//g' >> VERSION
#else
#	grep '^.*path=\"gecko\".*revision=' ./b2g-distro/sources.xml | sed 's/^.*path=\"gecko\".*revision=/gecko revision: /g' | sed 's/\/>//g' > VERSION
#	grep '^.*path=\"gaia\".*revision=' ./b2g-distro/sources.xml | sed 's/^.*path=\"gaia\".*revision=/gaia revision: /g' | sed 's/\/>//g' >> VERSION
#fi

grep '^.*path=\"gecko\".*revision=' ./b2g-distro/sources.xml > VERSION
grep '^.*path=\"gaia\".*revision=' ./b2g-distro/sources.xml >> VERSION

echo -e "===== VERSION ====="
cat VERSION

####################
# Done
####################
echo -e "Done!\nbyebye."

