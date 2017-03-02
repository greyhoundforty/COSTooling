#!/usr/bin/env bash

# Author: Ryan TIffany
# Email: rtiffany@us.ibm.com

# Script Variables
DIALOG='\033[0;36m' 
WARNING='\033[0;31m'
LINKY='\033[0;41m'
NC='\033[0m'
today=$(date "+%F")
hst=$(hostname -s)

# Short description 
overview() { 
  echo -e "${DIALOG}mThis script will install s3cmd and rsnapshot on your server and help with some basic backup configurations.${NC}"
  echo -e "${DIALOG}By default rsnapshot is configured to only backup this system, but can be configured to backup remote systems as well.${NC}\n"
}

overview 

# If user is not root, the script will warn them that they will need to use sudo for the install and sed commands. 
check_your_privilege() {
SUDO=''
if [[ "$(id -u)" != 0 ]]; then
	echo -e "${WARNING}Note: This setup script requires root permissions. You will be prompted for your sudo password.${NC}"
    SUDO='sudo'
fi
}

check_your_privilege

# Set OS specific variables.
set_install_variables()	{

  if [ -e /etc/redhat-release ] ; then
    echo -e "${DIALOG}Red Hat based distribution detected...${NC}"
    OS_VENDOR=$(awk '{print $1}' /etc/redhat-release | tr '[:lower:]' '[:upper:]')
    if [ "${OS_VENDOR}" = "RED" ]; then
          OS_VENDOR="REDHAT"
    elif [ "${OS_VENDOR}" = "CENTOS" ]; then
          OS_VENDOR="CENTOS"
    fi
    OS_INSTALL_TOOL="yum -y install"
    MAJOR_VERSION=$(rpm -qa \*-release | grep -Ei "oracle|redhat|centos" | cut -d"-" -f3)
      if [ "${OS_VENDOR}" = "REDHAT" ] && [ "${MAJOR_VERSION}" = "6" ]; then
        "$SUDO" rpm -Uvh http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm >/dev/null
      elif [ "${OS_VENDOR}" = "CENTOS" ] && [ "${MAJOR_VERSION}" = "6" ]; then
        "$SUDO" rpm -Uvh http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm >/dev/null 
      elif [ "${OS_VENDOR}" = "REDHAT" ] && [ "${MAJOR_VERSION}" = "7" ]; then
        "$SUDO" yum install epel-release -y >/dev/null 
      elif [ "${OS_VENDOR}" = "CENTOS" ] && [ "${MAJOR_VERSION}" = "7" ]; then
        "$SUDO" yum install epel-release -y >/dev/null 
      fi
  elif [ -e /usr/bin/lsb_release ] ; then
    echo -e "\r\033[K\e[36mDebian based distribution detected...\e[0m"
    OS_INSTALL_TOOL="apt-get -y install"
  fi
}

set_install_variables

# Install the needed packages for our backup configuration 
install_tools() {
  echo "$OS_INSTALL_TOOL"
  "$SUDO" "$OS_INSTALL_TOOL" s3cmd rsync rsnapshot wget >/dev/null 
}
install_tools