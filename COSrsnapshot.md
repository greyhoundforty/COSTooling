# Overview
In this walk through we will be looking at utilizing `rsnapshot` and `s3cmd` to have local "hot" backups, and "cold" backups in Cloud Object Storage (S3). The command rsnapshot will be used to generate the backups of the host system as well as remote linux systems if required. The s3cmd utility is used to push these backups to Cloud Object Storage (S3). 

## Prerequisites
	- One or more linux server with rsnapshot, rsync, and s3cmd installed. 
		- RHEL/CentOS: yum install s3cmd rsnapshot rsync
		- Ubuntu/Debian: apt-get install s3cmd rsnapshot rsync 
	- SSH-Keys generated on your main backup server. In this guide that is referred to as 'Backupserver'
	- SSH port open on your servers firewall. Rsnapshot uses rsync, which in turn uses SSH to pull backups from the remote-hosts so you will want to ensure you have the proper port whitelisted. 

### Servers:
 - Backupserver - main server running rsnapshot. Local and remote backups are stored on File Storage mount and once a day pushed to COS
 - bck1 & bck2 - Two more servers we want to backup. Our Backupserver will pull the backups using rsync. 

### Generate and copy ssh-key to remote hosts

For a guide on generating your servers public ssh-key as well as how to copy it to your remote servers please see our KnowledgeLayer article [Generating and using SSH-Keys for remote host authentication](http://knowledgelayer.softlayer.com/procedure/generating-and-using-ssh-keys-remote-host-authentication). 

## Setting up and Configuring rsnapshot

The rsnapshot utility will be used to backup our local system as well as remote-hosts to a single directory. This will allow us to then compress those backups and send them to Cloud Object Storage (S3) using the `s3cmd` utility. 

We are including an example `rsnapshot.conf` file that you can use as well. The example file has the following defaults: 

 - Backups are stored in the /backups/ directory. Rsnapshot can create the directory if it does not already exist. 
 - The retention scheme is set to keep 6 alpha backups, 7 beta backups, and 4 gamma backups. We'll touch on the syntax a little but further down. 
 - Rsnapshot will backup /home, /etc, and /usr/local. You will need to adjust this to fit your needs. 

[Example rsnapshot.conf](https://gist.githubusercontent.com/greyhoundforty/85686683e4f3b58618d08503da897287/raw/8f3c99a5dc664c44af5abb911c898a38b3e78ba0/rsnapshot.conf) 

**A Note About rsnapshot.conf** - The rsnapshot configuration file is very picky when it comes to tabs vs spaces. Always use tabs when editing the file. If there is an issue running `rsnapshot configtest` will show you the offending line. 

To use the example configuration file run the following commands: 

```
$ mv /etc/rsnapshot.conf{,.bak}
$ wget -O /etc/rsnapshot.conf https://gist.githubusercontent.com/greyhoundforty/85686683e4f3b58618d08503da897287/raw/8f3c99a5dc664c44af5abb911c898a38b3e78ba0/rsnapshot.conf
```

The syntax here breaks down to all local `alpha `backups will go to /backups/alpha.X/localhost and the `alpha` backup for the remote server bck1 will go to /backups/alpha.X/bck1. 

```
root@backuptest:~# grep snapshot_root /etc/rsnapshot.conf
snapshot_root	/backups/

backup	/home/		localhost/
backup	/etc/		localhost/
backup	/usr/local/	localhost/
backup	root@10.176.18.15:/var/	bck1/
```

Test the rsnapshot configuration by running the command `rsnapshot configtest`. You can also do a dry-run backup that will show you what `rsnapshot` will actually do when running the backup job by passing the `-t` flag. 

```
root@backuptest:~# rsnapshot configtest
Syntax OK

root@backuptest:~# rsnapshot -t alpha
echo 14407 > /var/run/rsnapshot.pid
/bin/rm -rf /backups/alpha.5/
mv /backups/alpha.4/ /backups/alpha.5/
mv /backups/alpha.3/ /backups/alpha.4/
mv /backups/alpha.2/ /backups/alpha.3/
mv /backups/alpha.1/ /backups/alpha.2/
/bin/cp -al /backups/alpha.0 /backups/alpha.1
/usr/bin/rsync -a --delete --numeric-ids --relative --delete-excluded \
    /home/ /backups/alpha.0/localhost/
/usr/bin/rsync -a --delete --numeric-ids --relative --delete-excluded /etc/ \
    /backups/alpha.0/localhost/
/usr/bin/rsync -a --delete --numeric-ids --relative --delete-excluded \
    /usr/local/ /backups/alpha.0/localhost/
/usr/bin/rsync -a --delete --numeric-ids --relative --delete-excluded \
    --rsh=/usr/bin/ssh root@10.176.18.15:/var/ /backups/alpha.0/bck1/
touch /backups/alpha.0/
```

### Run a test backup

If the configtest and dry run don't return any errors proceed to run your first `alpha` backup job. *Note:* By default the `rsnapshot` command will not produce any output when running backup jobs. If you would like to see what it is doing in real time pass the `-v` flag.  

```
root@backuptest:~# rsnapshot -v alpha
echo 25845 > /var/run/rsnapshot.pid
/bin/rm -rf /backups/alpha.5/
mv /backups/alpha.4/ /backups/alpha.5/
mv /backups/alpha.3/ /backups/alpha.4/
mv /backups/alpha.2/ /backups/alpha.3/
mv /backups/alpha.1/ /backups/alpha.2/
/bin/cp -al /backups/alpha.0 /backups/alpha.1
/usr/bin/rsync -a --delete --numeric-ids --relative --delete-excluded \
    /home/ /backups/alpha.0/localhost/
/usr/bin/rsync -a --delete --numeric-ids --relative --delete-excluded /etc/ \
    /backups/alpha.0/localhost/
/usr/bin/rsync -a --delete --numeric-ids --relative --delete-excluded \
    /usr/local/ /backups/alpha.0/localhost/
/usr/bin/rsync -a --delete --numeric-ids --relative --delete-excluded \
    --rsh=/usr/bin/ssh root@10.176.18.15:/var/ /backups/alpha.0/bck1/
touch /backups/alpha.0/
rm -f /var/run/rsnapshot.pid

root@backuptest:~# ls -l /backups/alpha.0
total 8
drwxr-xr-x 3 root root 4096 Feb 10 17:01 bck1
drwxr-xr-x 5 root root 4096 Feb  8 00:00 localhost
```

### Add other servers and adjust your schedule

Now that you have tested rsnapshot go ahead and add additional servers to `rsnapshot.conf` and configure your backup frequency. The rsnapshot utility uses the terms `alpha, beta, gamma, and delta` but you can think of them as:

```
alpha = hourly backups
beta = daily backups 
gamma = weekly backups 
delta = monhtly backups
```

By default rsnapshot ships with the following retention scheme.

```
retain	alpha	6
retain	beta	7
retain	gamma	4
#retain	delta	3
```

This means that your server will keep 6 hourly backups, 7 daily backups, and 4 weekly backups. For example: When the `alpha` backup job runs for the 7th time the oldest backup is rotated out and deleted so that it only has 6 `alpha` backups. The rsnapshot utility also ships with a default cron.d file. 

```
# 0 */4		* * *		root	/usr/bin/rsnapshot alpha
# 30 3  	* * *		root	/usr/bin/rsnapshot beta
# 0  3  	* * 1		root	/usr/bin/rsnapshot gamma
# 30 2  	1 * *		root	/usr/bin/rsnapshot delta
```

By default the `alpha` job will run every 4 hours, the beta every day at 03:30am, and so on. This is where you will want to customize to suit your needs and uncomment the lines in the cron file for the backups you would like to run. With rsnapshot taken care of, we will now move on to configuring `s3cmd`.

## Configuring s3cmd

The `s3cmd` python script is an open-source utility that allows a *nix or osx box to talk to S3 compatible services. After the utility is installed all the customer has to do is download our example `.s3cfg` file and update it with their COS Access and Secret Key:

```
 wget -O $HOME/.s3cfg https://gist.githubusercontent.com/greyhoundforty/a4a9d80a942d22a8a7bf838f7abbcab2/raw/05ad584edee4370f4c252e4f747abb118d0075cb/example.s3cfg
```

The 2 lines that need to be updated are 2 and 55 (if they are using our example .s3cfg file). The lines begin with `access_key` and `secret_key` respectively. Once those lines have been updated with the COS details from the Customer portal you can test the connection by issuing the command `s3cmd ls` which will list all the buckets on the account. 

```
$ s3cmd ls                                                                                                                                                  
2017-02-03 14:52  s3://backuptest
2017-02-06 15:04  s3://coldbackups
2017-02-03 21:23  s3://largebackup
2017-02-07 20:49  s3://po9bmbnem531ehdreyfh-winbackup
2017-02-07 17:44  s3://winbackup
```

**A Note About Buckets** - Cloud Object Storage (S3) has a 100 bucket limit per account. Keep this in mind if you set up each backup to create its own bucket or do a per month bucket.  


### Pushing backups to Cloud Object Storage (S3) 

To manually push your backups to Cloud Object Storage (S3) I would recommend using tar to compress the backup directory with a date stamp for easier sorting should you need to pull the backups from Cloud Object Storage (S3) for restoration.

```
tar -czf $(date "+%F").backup.tar.gz /backups/
s3cmd put $(date "+%F").backup.tar.gz s3://coldbackups/
```

To automate this process you would likely want to a use a cron job to commpress the backups and send them to Cloud Object Storage (S3) at regular intervals. 

**A Note About Retention** - Cloud Object Storage (S3) does not currently support a retention scheme. This means that whatever you push to COS (S3) will remain there until you delete it. 

## Restoring Files from Cloud Object Storage (S3) 

To restore a file or directory from Cloud Object Storage (S3) you will need to use the `get` command to pull down the backup. Once the file or directory has been downloaded to your server you can use `cp`, `rsync`, or `mv` to restore the file. If the file was from a remote host backed up using `rsnapshot` you would use `scp` or `rsync` to move it back to the original host system.

### To pull a single file or compressed backup 
By default the file you download from Cloud Object Storage (S3) will be stored in the same directory you are currently in. 

```
$ sc3md get s3://bucket/path/to/file
```

You can also specify the directory you would like the downloaded file stored in: 

```
$ s3cmd get s3://bucket/path/to/file /local/path/ 
```

### To pull a directory 
In order to pull a directory as well as all sub-items, use the `--recursive` flag 

```
$ s3cmd get s3://bucket/ /local/path/ --recursive 
```


