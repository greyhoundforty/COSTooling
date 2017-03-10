#!/usr/bin/env bash

# Author: Ryan TIffany
# Email: rtiffany@us.ibm.com

# Script Variables
hst=$(hostname -s)
today=$(date "+%F")

if [ "$(s3cmd ls | egrep "$hst" | wc -l)" = "0" ];then
  	$(which s3cmd) mb s3://"$hst" 
  	$(which tar) -czf /"${today}.backup.tar.gz" ${RSNAPSHOT_BACKUP_DIR}
  	$(which s3cmd) put /"${today}.backup.tar.gz" s3://"$hst"
  	rm -f /"${today}.backup.tar.gz"
  else
  	$(which tar) -czf "/${today}.backup.tar.gz" ${RSNAPSHOT_BACKUP_DIR}
  	$(which s3cmd) put /"${today}.backup.tar.gz" s3://"$hst"
  	rm -f /"${today}.backup.tar.gz"
  fi