#!/usr/bin/env bash

# Author: Ryan TIffany
# Email: rtiffany@us.ibm.com

# Script Variables
today=$(date "+%F")

$(which tar) -czf /"${today}.backup.tar.gz" "${RSNAPSHOT_BACKUP_DIR}"
$(which s3cmd) put /"${today}.backup.tar.gz" s3://COSBUCKET
rm -f /"${today}.backup.tar.gz"
