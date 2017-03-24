#!/usr/bin/env bash

# Author: Ryan Tiffany
# Email: rtiffany@us.ibm.com

# Script Variables
outputLog="$HOME/coscron.log"

today=$(date "+%F")
RSNAPSHOT_BACKUP_DIR=$(sed -e 's/#.*$//' -e '/^$/d' /etc/rsnapshot.conf | grep snapshot_root | awk '{print $2}')

if [[ ! -f "$outputLog" ]]; then
	touch "$outputLog"
fi	

$(which tar) -czvf /"${today}.backup.tar.gz" "${RSNAPSHOT_BACKUP_DIR}" >> "$outputLog"
$(which s3cmd) put /"${today}.backup.tar.gz" s3://COSBUCKET >> "$outputLog"
rm -f /"${today}.backup.tar.gz" 
