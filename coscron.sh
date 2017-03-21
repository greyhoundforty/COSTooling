#!/usr/bin/env bash

# Author: Ryan Tiffany
# Email: rtiffany@us.ibm.com

# Script Variables
today=$(date "+%F")
RSNAPSHOT_BACKUP_DIR=$(sed -e 's/#.*$//' -e '/^$/d' /etc/rsnapshot.conf | grep snapshot_root | awk '{print $2}')

$(which tar) -czf /"${today}.backup.tar.gz" "${RSNAPSHOT_BACKUP_DIR}"
$(which s3cmd) put /"${today}.backup.tar.gz" s3://COSBUCKET
rm -f /"${today}.backup.tar.gz"
