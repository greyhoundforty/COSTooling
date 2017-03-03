# IBM Bluemix Cloud Object Storage (S3) Tools and Guides

This repository contains guides for using Open Source tools to backup Linux and Windows Servers to the [IBM Bluemix Cloud Object Storage (S3) service](http://www.softlayer.com/object-storage). The IBM Bluemix Cloud Object Storage (S3) service, sometimes shortened to COS (S3), allows you to store and access your data with our resilient service. With S3 API support, cross-region resiliency, and built-in security using SecureSlice technology, Cloud Object Storage (S3) Standard  allows you to create and manage buckets and provides credentials and endpoints for use with tools, applications, and gateways.

[COS (S3): How it works](https://www.ibm.com/cloud-computing/products/storage/object-storage/how-it-works/)  
[COS (S3): API Guide](https://ibm-public-cos.github.io/crs-docs/)

## Windows
The Windows guide uses the Open Source tool [Duplicati](https://www.duplicati.com/) (version 2.0) to automate backing up to the IBM Bluemix Cloud Object Storage (S3) service. 

## Linux 
The Linux guide combines [rsnapshot](http://rsnapshot.org/) to backup both local and remote hosts, and [s3cmd](http://s3tools.org) to push the backups to COS (S3). There is also a [KnowledgeLayer](#) guide on how to use `s3cmd` to interact with your buckets.  

### Automated Backups in Linux 
The included `backup_script.sh` is used to automate the process of installing and configuring `s3cmd` and `rsnapshot` for local "hot" backups and off-site "cold" backups. The script also sets up a cron job to compress the current `rsnapshot` backup directory every night at 10:30pm and push to the a bucket in Cloud Object Storage (S3).

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
