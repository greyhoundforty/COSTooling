#!/bin/bash

## v1 - everything runs as root (current version)
## v1.5 - script detects if you are not root and appends commands with sudo (sometime hopefully soon)

set_install_variables()	{

  # OS specific variables.
  if [ -e /etc/redhat-release ] ; then
    echo "Red Hat based distribution detected..."
    OS_VENDOR=`awk '{print $1}' /etc/redhat-release | tr [a-z] [A-Z]`
    if [ ${OS_VENDOR} = "RED" ]; then
          OS_VENDOR="REDHAT"
    fi
    OS_INSTALL_TOOL="/usr/bin/yum -y install"
  elif [ -e /usr/bin/lsb_release ] ; then
    echo "Debian based distribution detected..."
    OS_VENDOR=`lsb_release -si | tr '[a-z]' '[A-Z]'`
    OS_VERSION_MAJOR=`lsb_release -sr | cut -d. -f1`
    OS_VERSION_MINOR=`lsb_release -sr | cut -d. -f2`
    OS_INSTALL_TOOL="apt-get -y install"
  fi
}

install_tools() {
	$OS_INSTALL_TOOL s3cmd rsync rsnapshot wget 
}

configure_rsnapshot()
{
  mv /etc/rsnapshot.conf{,.bak}
  wget -O /etc/rsnapshot.conf https://gist.githubusercontent.com/greyhoundforty/6b6975d973f5550fce69b71ed8485d34/raw/4091bb17f03dc9b0a3f745b348e686db14b4027e/rsnapshotv2.conf
  echo
  echo
  echo -n "Please supply the directory you would like to use to store your backups. Use the full path with a trailing slash (example: /backups/)"
  read RSNAPSHOT_BACKUP_DIR
  
  sed -i "s|BACKUP_DIR|$RSNAPSHOT_BACKUP_DIR|" /etc/rsnapshot.conf
  echo "Testing rsnapshot configuration"
  rsnapshot configtest
}

configure_s3cmd() { 

	wget -O $HOME/.s3cfg https://gist.githubusercontent.com/greyhoundforty/676814921b8f4367fba7604e622d10f3/raw/f6ce1f2248c415cefac4eec4f1c112ad4a03a0d1/s3cfg
	echo 
	echo 
	echo -n "Please supply your Cloud Object Storage (S3) Access Key"
	read COS_ACCESS_KEY
	sed -i "s|cos_access_key|$COS_ACCESS_KEY|" $HOME/.s3cfg
	echo -n "Please supply your Cloud Object Storage (S3) Secret Key"
	read COS_SECRET_KEY
	sed -i "s|cos_secret_key|$COS_SECRET_KEY|" $HOME/.s3cfg
	echo 
	echo -n "Would you like to use the Public or Private Cloud Object Storage (S3) endpoint?"
	## read
	## if Pub then set PUB_URL
	## sed will need to be global as this is set in 2 locations 
	## else set Private - cos_endpoint
}

cos_backup_schedule() { 

# This is what will determine the cron entries for s3cmd 
# to compress the backups and send them to COS (S3) 

}