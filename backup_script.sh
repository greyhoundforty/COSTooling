#!/bin/bash

## v1 - everything runs as root (current version)

check_your_privilege () {
    if [[ "$(id -u)" != 0 ]]; then
        echo -e "\e[91mError: This setup script requires root permissions. Please run the script as root by issuing the command 'sudo ./backup_script.sh .\e[0m" > /dev/stderr
        exit 1
    fi
}

check_your_privilege

set_install_variables()	{

  # OS specific variables.
  if [ -e /etc/redhat-release ] ; then
    echo "Red Hat based distribution detected..."
    OS_VENDOR=$(awk '{print $1}' /etc/redhat-release | tr '[a-z]' '[A-Z]')
    if [ "${OS_VENDOR}" = "RED" ]; then
          OS_VENDOR="REDHAT"
    elif [ "${OS_VENDOR}" = "CENTOS" ]; then
          OS_VENDOR="CENTOS"
    fi
    OS_INSTALL_TOOL="/usr/bin/yum -y install"
    MAJOR_VERSION=$(rpm -qa \*-release | grep -Ei "oracle|redhat|centos" | cut -d"-" -f3)
      if [ "${OS_VENDOR}" = "REDHAT" ] && [ "${MAJOR_VERSION}" = "6" ]; then
        rpm -Uvh http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
      elif [ "${OS_VENDOR}" = "CENTOS" ] && [ "${MAJOR_VERSION}" = "6" ]; then
        rpm -Uvh http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
      elif [ "${OS_VENDOR}" = "REDHAT" ] && [ "${MAJOR_VERSION}" = "7" ]; then
        yum install epel-release -y
      elif [ "${OS_VENDOR}" = "CENTOS" ] && [ "${MAJOR_VERSION}" = "7" ]; then
        yum install epel-release -y
      fi
  elif [ -e /usr/bin/lsb_release ] ; then
    echo "Debian based distribution detected..."
    OS_VENDOR=$(lsb_release -si | tr '[a-z]' '[A-Z]')
    OS_VERSION_MAJOR=$(lsb_release -sr | cut -d. -f1)
    OS_VERSION_MINOR=$(lsb_release -sr | cut -d. -f2)
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
  echo -n "Please supply the directory you would like to use to store your backups. Use the full path with a trailing slash (example: /backups/)  "
  read RSNAPSHOT_BACKUP_DIR
  
  sed -i "s|BACKUP_DIR|$RSNAPSHOT_BACKUP_DIR|" /etc/rsnapshot.conf
  echo "Testing rsnapshot configuration"
  rsnapshot configtest
}

configure_s3cmd() { 

	wget -O "$HOME/.s3cfg" https://gist.githubusercontent.com/greyhoundforty/676814921b8f4367fba7604e622d10f3/raw/f6ce1f2248c415cefac4eec4f1c112ad4a03a0d1/s3cfg
	echo 
	echo 
	echo -en "Please supply your Cloud Object Storage (S3) Access Key:\n:: "
	read -s COS_ACCESS_KEY
	sed -i "s|cos_access_key|$COS_ACCESS_KEY|" "$HOME"/.s3cfg
  echo ""
	echo -en "Please supply your Cloud Object Storage (S3) Secret Key:\n:: "
	read -s COS_SECRET_KEY
	sed -i "s|cos_secret_key|$COS_SECRET_KEY|" "$HOME/.s3cfg"
	echo 
	echo -en "Would you like to use the Public or Private Cloud Object Storage S3 endpoint?\n:: "
	read ENDPOINT 
	case "$ENDPOINT" in  
  		public|Public) sed -i "s|cos_endpoint|s3-api.us-geo.objectstorage.softlayer.net|g" "$HOME/.s3cfg";; 
  		private|Private) sed -i "s|cos_endpoint|s3-api.us-geo.objectstorage.service.networklayer.com|g" "$HOME/.s3cfg" ;; 
  		*) echo "Did not set an endpoint, you will need to manually update the ~/.s3cfg config file." ;; 
	esac
  echo "We will now test our config file by creating a test bucket"
  s3cmd mb s3://testbckt
  if [ $(s3cmd ls | egrep 'testbckt' | wc -l) = "1" ];then
    echo "s3cmd configuration test passed"
    echo "Removing test bucket"
    nohup s3cmd rb s3://testbckt/ & disown 
  else
    echo "Bucket creation did not succeed, double check your HOME/.s3cfg configuration file."
  fi
  
}

#cos_backup_schedule() { 

# This is what will determine the cron entries for s3cmd 
# to compress the backups and send them to COS (S3) 

#}

# tar -czf $(date "+%F").backup.tar.gz ${RSNAPSHOT_BACKUP_DIR}

set_install_variables
install_tools
configure_rsnapshot
configure_s3cmd