#!/usr/bin/env bash

# Author: Ryan Tiffany
# Email: rtiffany@us.ibm.com

# Script Variables
outputLog="$HOME/coscron.log"
today=$(date "+%F")
RSNAPSHOT_BACKUP_DIR=$(sed -e 's/#.*$//' -e '/^$/d' /etc/rsnapshot.conf | grep snapshot_root | awk '{print $2}')

# Create output log if it does not exist
if [[ ! -f "$outputLog" ]]; then
	touch "$outputLog"
fi	

# Run compress and send and then remove backup archive
$(which tar) -czvf "$HOME/${today}.backup.tar.gz" "${RSNAPSHOT_BACKUP_DIR}" >> "$outputLog"
$(which s3cmd) -c /etc/.s3cfg put "$HOME/${today}.backup.tar.gz" s3://COSBUCKET >> "$outputLog"
rm -f "$HOME/${today}.backup.tar.gz" 
