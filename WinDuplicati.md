
## Overview

This guide will walk you through using [Duplicati](https://www.duplicati.com/) to perform schedule backups of your Windows Server to Cloud Object Storage. We will also show how to restore files from Cloud Object Storage using Duplicati. 

### Prerequisites 
	- Duplicati downloaded and installed on the Windows Server - [Duplicati Download Link](https://www.duplicati.com/download) (Installation requires elevated priveleges)
	- Cloud Object Storage Account credentials
	- Port 80 (http) and/or 443 (https) open for inbound and outbound communication with the Cloud Object Storage endpoints. Port 443 is required if you choose the SSL option during the backup configuration process. 
	- Firefox or Google Chrome installed if you would like to use SSL. Internet Explorer has an issue which prevents you from changing a key Advanced Option that is needed for SSL to work properly. 

### Running Duplicati for the first time 

The first time you launch Duplicati the program will open up the URL http://127.0.0.1:8200/ngax/index.html in your default browser. For this guide we will be focusing on the Web GUI interaction with Duplicati but it also has a command line interface for those customers interested in being able to script it during deployment. 

### Creating a Backup Job 

To create a backup job click on 'Add backup', provide the backup job a name and set an encryption passphrase. While it is not necessary to encrypt the backups it is highly recommended. Once those are set click Next. 

![Create Backup Job](http://i.imgur.com/AcAIQvB.png) 

On the subsequent page you will choose 'S3 Compatible' from the drop-down next to Storage Type click the 'Use SSL' checkbox and in the Server drop-down choose Custom URL. This will provide you with an additional box to specify the US Geo Cloud Object Storage endpoint. In this example I am using the Private network endpoint (s3-api.us-geo.objectstorage.service.networklayer.com). Provide a name for the bucket you would like the backups to go to. Duplicati will create the bucket if it does not already exist. You can leave both 'Bucket create region' and 'Storage class' set to Default and then specify a sub-folder for your backups to reside in if you so desire. In the bottom 2 boxes provide your 'Access Key ID' and 'Secret Access Key'. Due to incompatibility with SSLv3 and TLS1 we will need to make one more adjustment. To do this click on 'Advanced options', select 'allowed-ssl-versions' from the drop-down, and set the version to either TLS1.1 or TLS1.2. 

![Set COS Credentials](http://i.imgur.com/xM1VcZ6.png)

Click 'Test Connection' and you will likely be greeted with the message 'The bucket name should start with your username, prepend automatically?'. Click Yes and have Duplicati create the Bucket. If everything went smoothly you should now see a box that says 'Connection worked!', click Ok and scroll to the bottom of the page and click Next. 

![Test Connection](http://i.imgur.com/UvjRyle.png)

On this page you will select the files and/or the directories you would like to backup to Cloud Object Storage. The configuration supports filtering and the ability to exlude certain files based on specific attributes. When you have selected the files/directories to backup click Next to set your backup schedule. 

![Choose Files and Directories to backup](http://i.imgur.com/nUcK0b6.png)

![Choose schedule](http://i.imgur.com/t5E3Irt.png)

With your schedule set click Next and set the 'Upload' (chunk) size for the backups as well as the retention scheme and click Save. Your backup job is not set up and ready to go. You can click 'Run now' to trigger a manual run of the backup job. 

![Backup Running](http://i.imgur.com/kLr677P.png)

### Restoring Files

The first time you start a restore process in Duplicati you will be prompted for your Cloud Object Storage credentials again. Follow the same steps as you did when first creating the backup including changing the Allowed SSL Versions under the Advanced Options settings. Test the connection and if everything worked, click Next. 

![Set restore credentials](http://i.imgur.com/BVdFBRy.png)

On the subsequent page enter the encryption password used when you created the backups or leave the box blank and click Next. On the following page you will see a box labeled 'Restore from' where you can select the specific backup you would like to restore from as as well as which files and directories you would like restored. After you have made your selections click Continue. 

![Choose Files and Directories to restore](http://i.imgur.com/fG0vYDv.png)

When restoring files you have the option of restoring them to their original location or a new location if you would like to compare them before making a change. If you choose to restore them to their original location you can also have Duplicato prepend the filenames with a timestamp to distinguish them from the files currently on your server. You can also choose to restore the original file permissions. Once you have everything set click Restore to start the process. 

![Location to restore files](http://i.imgur.com/dUV6fhl.png)

This will start the restore process and give you a progress indicator along with an ETA on when the restore will be completed. 
