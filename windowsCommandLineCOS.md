<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents** 

- [Overview](#overview)
  - [Prerequisites](#prerequisites)
  - [Initial Duplicati Backup](#initial-duplicati-backup)
  - [Automating Duplicati Command line backups](#automating-duplicati-command-line-backups)
  - [Restoring Duplicati Command line backups](#restoring-duplicati-command-line-backups)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Overview

In this guide we will show the process for using the Duplicati command line interface to automate server backups to Cloud Object Storage. 

## Prerequisites 
    - Duplicati downloaded and installed on the Windows Server - [Duplicati Download Link](https://www.duplicati.com/download) (Installation requires elevated priveleges)
    - Cloud Object Storage Account credentials
    - Port 80 (http) and/or 443 (https) open for inbound and outbound communication with the Cloud Object Storage endpoints. Port 443 is required if you choose the SSL option during the backup configuration process. 

So that we can properly automate the backups, first set some global environmental variables. To do this open up a new command line and paste the following, subsituting your backup passphrase and Cloud Object Storage credentials. 

```
setx -m PASSPHRASE "Your backup passphrase"
setx -m COS_ACCESS_KEY "Your Access Key"
setx -m COS_SECRET_KEY "Your Secret Key"
```

In order for the system to pick up these variables close the command line utility and open a new one. To verify that the variables were saved properly run the following command and make sure you get the expected output. 

```
echo %COS_ACCESS_KEY%
```

## Initial Duplicati Backup 
With the variables set we can now run our initial backup command. The first step is to change in to the Duplicati directory. 

```
C:\Users\Administrator>cd "C:\Program Files\Duplicati 2\"
```

Once we are in the correct directory we will invoke the backup command. The syntax is as follows 

```
Duplicati.CommandLine.exe backup BUCKET_URL "X:\Path\to\backup" OPTIONS
```

The OPTIONS in this case will be:

    --passphrase - This is the passphrase that is used to encrypt all data before it is uploaded.
    --s3-server-name - The Cloud Object Storage endpoint. 
    --auth-username - The Cloud Object Storage Access Key. 
    --auth-password - The Cloud Object Storage Secret Key

For example if we wanted to backup the "C:\Users\Administrator\Downloads" directory to the bucket `dupbackup` the command would look like this. If the bucket you specify does not exist, the command will create it for you. 

```
C:\Program Files\Duplicati 2>Duplicati.CommandLine.exe backup s3://dupbackup/ "C:\Users\Administrator\Downloads" --s3-server-name=s3-api.us-geo.objectstorage.softlayer.net --passphrase=%PASSPHRASE% --auth-username=%COS_ACCESS_KEY% --auth-password=%COS_SECRET_KEY%

Backup started at 2/16/2017 2:30:00 PM
Checking remote backup ...
  Listing remote folder ...
Operation List with file  attempt 1 of 5 failed with message: The requested folder does not exist => The requested folder does not exist
  Listing remote folder ...
Scanning local files ...
  51 files need to be examined (20.72 GB)
  48 files need to be examined (20.72 GB)
  Uploading file (49.93 MB) ...
  Uploading file (19.68 KB) ...
  Uploading file (49.94 MB) ...
  Uploading file (21.39 KB) ...
  Uploading file (49.94 MB) ...
  Uploading file (18.06 KB) ...
  Uploading file (49.96 MB) ...
  Uploading file (18.08 KB) ...
  Uploading file (49.98 MB) ...
  Uploading file (18.04 KB) ...
  Uploading file (49.91 MB) ...
```

## Automating Duplicati Command line backups

You can use the built in Task Scheduler in Windows to automate the backup of the server. See this [guide](https://msdn.microsoft.com/en-us/library/windows/desktop/aa383614(v=vs.85).aspx) for a good introduction to Task Scheduler. 

## Restoring Duplicati Command line backups

The syntax for restoring from Duplicati backups is pretty similar to the backup command. 

```
Duplicati.CommandLine.exe restore BUCKET_URL <filename> OPTIONS
```

The OPTIONS in this case will be:

    --passphrase - This is the passphrase that is used to encrypt all data before it is uploaded.
    --s3-server-name - The Cloud Object Storage endpoint. 
    --auth-username - The Cloud Object Storage Access Key. 
    --auth-password - The Cloud Object Storage Secret Key
    --restore-path - The path to restore the files to instead of their original location. 

If choosing to restore to the file/directories original lcoation, <filename> is changed to <filename-timestamp.extension>. To restore all files use "*" or leave empty.

In this example we will be restoring our full backup to the Desktop so that we can inspect the files before replacing the current versions on our system:

```
Duplicati.CommandLine.exe restore s3://dupbackup/ * --restore-path="C:\Users\Administrator\Desktop" --s3-server-name=s3-api.us-geo.objectstorage.softlayer.net --passphrase=%PASSPHRASE% --auth-username=%COS_ACCESS_KEY% --auth-password=%COS_SECRET_KEY%

Restore started at 2/17/2017 12:33:49 PM
Checking remote backup ...
  Listing remote folder ...
Searching backup 0 (2/16/2017 8:30:03 PM) ..
  51 files need to be restored (20.72 GB)
Checking existing target files ...
Scanning local files for needed data ...
  49 files need to be restored (19.69 GB)
  29 files need to be restored (11.00 GB)
  9 files need to be restored (3.74 GB)
28 remote files are required to restore
  Downloading file (49.93 MB) ...
  0 files need to be restored (0 bytes)
  Downloading file (49.91 MB) ...
  Downloading file (49.97 MB) ...
  Downloading file (49.94 MB) ...
  Downloading file (49.94 MB) ...
  Downloading file (49.92 MB) ...
  Downloading file (49.90 MB) ...
```

















