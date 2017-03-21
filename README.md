<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  

- [IBM Bluemix Cloud Object Storage (S3) Tools and Guides](#ibm-bluemix-cloud-object-storage-s3-tools-and-guides)
  - [Overview](#overview)
  - [Windows GUI Backup using Duplicati](#windows-gui-backup-using-duplicati)
    - [Windows Command Line Backup using Duplicati](#windows-command-line-backup-using-duplicati)
  - [Linux](#linux)
    - [Automated Backups in Linux](#automated-backups-in-linux)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# IBM Bluemix Cloud Object Storage (S3) Tools and Guides

## Overview
This repository contains guides for using Open Source tools to backup Linux and Windows Servers to the [IBM Bluemix Cloud Object Storage (S3) service](http://www.softlayer.com/object-storage). The IBM Bluemix Cloud Object Storage (S3) service, sometimes shortened to COS (S3), allows you to store and access your data with our resilient service. With S3 API support, cross-region resiliency, and built-in security using SecureSlice technology, Cloud Object Storage (S3) Standard  allows you to create and manage buckets and provides credentials and endpoints for use with tools, applications, and gateways.

[COS (S3): How it works](https://www.ibm.com/cloud-computing/products/storage/object-storage/how-it-works/)  
[COS (S3): API Guide](https://ibm-public-cos.github.io/crs-docs/)

## Windows GUI Backup using Duplicati
This [Windows guide](https://github.com/greyhoundforty/COSTooling/blob/master/WinDuplicati.md) uses the Open Source tool [Duplicati](https://www.duplicati.com/) (version 2.0) to automate backing up to the IBM Bluemix Cloud Object Storage (S3) service. 

### Windows Command Line Backup using Duplicati 
This [Windows guide](https://github.com/greyhoundforty/COSTooling/blob/master/windowsCommandLineCOS.md) shows how to use the command line version of [Duplicati](https://www.duplicati.com/) to backup and restore your Windows server. 

## Linux 
The [Linux guide](https://github.com/greyhoundforty/COSTooling/blob/master/COSrsnapshot.md) combines [rsnapshot](http://rsnapshot.org/) to backup both local and remote hosts, and [s3cmd](http://s3tools.org) to push the backups to COS (S3). There is also a [KnowledgeLayer](#) guide on how to use `s3cmd` to interact with your buckets.  

### Automated Backups in Linux 
The included `backup_script.sh` is used to automate the process of installing and configuring `s3cmd` and `rsnapshot` for local "hot" backups and off-site "cold" backups. The script also sets up a cron job to compress the current `rsnapshot` backup directory every night at 10pm and push to a bucket in Cloud Object Storage (S3).

The script is broken down in to functions that I will explain here: 

- check_your_privilege: This function will check if you are root or not. If you are not root the script will assign sudo to the commands
- set_install_variables: Determines the underlying OS so that it can set install variables 
- install_tools: Installs s3cmd, rsnapshot, rsync, and wget
- configure_rsnapshot: Downloads our example rsnapshot.conf file and prompts you to set the directory where rsnapshot stores backups. Also downloads the rsnapshot cron file for automated backups. 
- configure_s3cmd: Downloads example s3cmd configuration file and prompts the user for their COS (S3) Access and Secret Keys as well as the COS (S3) endpoint to use. This function also creates a randomly named bucket to test that s3cmd is configured properly. 
- cos_backup_schedule: Downloads a script that will compress your rsnapshot backup directory and send it to COS (S3) using s3cmd. Function also sets up a daily cron to run that script at 10pm evey night. 
- post_install: Prints information about the install

The Script has been tested on the following operating systems:

[Root Install Centos 6](https://asciinema.org/a/ahouyhtvv8tl1z22n7tv8e1tt)

[Sudo Install Centos 6](https://asciinema.org/a/as8hp9xxfnm01lyyfmacvefmh)

[Root Install Centos 7](https://asciinema.org/a/db5pz5am879lnuxes7at6a5v4)

[Sudo Install Centos 7](https://asciinema.org/a/556jfpytp2tt88ysudjxrl4d0)

[Root install Ubuntu 16](https://asciinema.org/a/315kcpilvvtyywb2lv8jc2j0g)

[Sudo install Ubuntu 16](https://asciinema.org/a/5e5r504r64wp8y1l55zocj0wy)

[Root Install Ubuntu 14](https://asciinema.org/a/7wwatcrx2ddyiuacs9uy5pu3l)

[Sudo install Ubuntu 14](https://asciinema.org/a/2wm1y5oyz2w90raxt40pgy7sl)

[Root install Debian 8](https://asciinema.org/a/1i7bmftmz5028i0e7djncqwgy)

[Sudo install Debian 8](https://asciinema.org/a/e9l3x4cjxsxkk40su4nt78h6n)
